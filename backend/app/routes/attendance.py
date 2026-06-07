import math
from datetime import datetime, date, time, timedelta, timezone
from decimal import Decimal
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from .auth import get_current_user
from .. import models, schemas

router = APIRouter(prefix="/api/attendance", tags=["attendance"])

def calculate_haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Computes the great-circle distance between two points on Earth
    using the Haversine formula. Returns distance in meters.
    """
    # Earth's radius in meters
    R = 6371000.0

    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (math.sin(delta_phi / 2.0) ** 2 +
         math.cos(phi1) * math.cos(phi2) *
         math.sin(delta_lambda / 2.0) ** 2)
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))

    return R * c

def calculate_shift_date(clock_in_time: datetime, shift: Optional[models.Shift]) -> date:
    """
    Maps clock-in timestamp to logical shift date.
    For overnight shifts (e.g. 10 PM to 6 AM), a clock-in between midnight and 8 AM
    is logically treated as starting on the previous calendar date.
    """
    if not shift:
        return clock_in_time.date()

    # If shift spans overnight (end_time is earlier in day than start_time)
    if shift.end_time < shift.start_time:
        # Clocking in early morning counts as previous day's shift
        if clock_in_time.hour < 8:
            return (clock_in_time - timedelta(days=1)).date()

    return clock_in_time.date()

@router.get("/status", response_model=Optional[schemas.AttendanceSessionOut])
def get_attendance_status(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Returns the active (not checked out) attendance session for the current logged-in user,
    or None if the user is not currently checked in.
    """
    session = db.query(models.AttendanceSession).filter(
        models.AttendanceSession.user_id == current_user.id,
        models.AttendanceSession.clock_out == None
    ).order_by(models.AttendanceSession.clock_in.desc()).first()

    return session

@router.post("/check-in", response_model=schemas.AttendanceSessionOut)
def check_in(
    req: schemas.CheckInRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Clock-in endpoint:
    - Office workers: Validates geofence coordinates against department location. If out of bounds,
      flags the session as is_out_of_bounds and PENDING_APPROVAL.
    - Field workers: Allows clock-in from anywhere and automatically creates initial TRAVEL timeline log.
    - Remote workers: Allows clock-in from anywhere without out-of-bounds flag.
    - Admin/CEO: Allowed clock-in from anywhere without shift restriction.
    """
    now_utc = datetime.now(timezone.utc)

    # 1. Determine shift date based on assigned shift (admins may not have a shift)
    shift_date = calculate_shift_date(now_utc, current_user.shift)

    # 2. Check if already checked in for this shift date
    existing_session = db.query(models.AttendanceSession).filter(
        models.AttendanceSession.user_id == current_user.id,
        models.AttendanceSession.shift_date == shift_date
    ).first()

    if existing_session:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Already checked in for shift date {shift_date}."
        )

    # 3. Handle specific work type logic
    is_out_of_bounds = False
    verification_status = "APPROVED"

    if current_user.work_type == "OFFICE":
        dept = current_user.department
        if not dept or dept.geofence_lat is None or dept.geofence_lng is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User department is not configured with geofencing coordinates."
            )
        
        # Calculate distance
        distance = calculate_haversine_distance(
            float(req.latitude), float(req.longitude),
            float(dept.geofence_lat), float(dept.geofence_lng)
        )

        if distance > dept.allowed_radius_meters:
            is_out_of_bounds = True
            verification_status = "PENDING_APPROVAL"

    # 4. Create attendance session
    session = models.AttendanceSession(
        user_id=current_user.id,
        shift_id=current_user.shift_id, # Can be None for Admin
        shift_date=shift_date,
        clock_in=now_utc,
        is_out_of_bounds=is_out_of_bounds,
        verification_status=verification_status,
        status="PRESENT"
    )
    db.add(session)
    db.flush() # Populates session.id for relation use

    # 5. Field staff get an automatic first activity log: TRAVEL
    if current_user.work_type == "FIELD":
        initial_activity = models.ActivityLog(
            session_id=session.id,
            activity_type="TRAVEL",
            start_time=now_utc,
            latitude=req.latitude,
            longitude=req.longitude,
            location_name=req.location_name or "Check-in Location",
            notes="Auto-created upon check-in"
        )
        db.add(initial_activity)

    db.commit()
    db.refresh(session)
    return session

@router.post("/check-out", response_model=schemas.AttendanceSessionOut)
def check_out(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Clock-out endpoint:
    - Finds the active session, calculates worked hours and daily status.
    - Closes any active timeline activity logs for field staff.
    """
    now_utc = datetime.now(timezone.utc)

    # 1. Fetch current open session
    session = db.query(models.AttendanceSession).filter(
        models.AttendanceSession.user_id == current_user.id,
        models.AttendanceSession.clock_out == None
    ).order_by(models.AttendanceSession.clock_in.desc()).first()

    if not session:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No active attendance session found. Please check in first."
        )

    # 2. Update session clock-out details
    session.clock_out = now_utc
    
    # SQLite retrieves datetime fields as timezone-naive, while PostgreSQL returns timezone-aware.
    # We normalize both to naive by stripping the timezone info to prevent subtraction TypeError.
    clock_in_naive = session.clock_in.replace(tzinfo=None) if session.clock_in.tzinfo else session.clock_in
    clock_out_naive = now_utc.replace(tzinfo=None) if now_utc.tzinfo else now_utc
    
    delta = clock_out_naive - clock_in_naive
    total_hours = Decimal(delta.total_seconds() / 3600.0).quantize(Decimal("0.01"))
    session.total_hours = total_hours

    # 3. Categorize attendance status
    if total_hours >= Decimal("8.00"):
        session.status = "PRESENT"
    elif total_hours >= Decimal("4.00"):
        session.status = "HALF_DAY"
    else:
        session.status = "ABSENT"

    # 4. If field worker, close any open activity logs
    if current_user.work_type == "FIELD":
        open_activity = db.query(models.ActivityLog).filter(
            models.ActivityLog.session_id == session.id,
            models.ActivityLog.end_time == None
        ).first()
        if open_activity:
            open_activity.end_time = now_utc

    db.commit()
    db.refresh(session)
    return session

@router.post("/activity", response_model=schemas.ActivityLogOut)
def log_activity(
    req: schemas.ActivityLogCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Timeline activity toggle endpoint (Field workers only):
    - Closes current open activity (sets end_time to now).
    - Starts the new activity block.
    """
    # 1. Verification of user and session
    if current_user.work_type != "FIELD":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Activity timeline logging is only allowed for FIELD workers."
        )

    session = db.query(models.AttendanceSession).filter(
        models.AttendanceSession.user_id == current_user.id,
        models.AttendanceSession.clock_out == None
    ).order_by(models.AttendanceSession.clock_in.desc()).first()

    if not session:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No active attendance session found to log activity. Please check in first."
        )

    # 2. Validate activity type
    valid_types = ["TRAVEL", "MEETING", "WORK", "BREAK"]
    if req.activity_type not in valid_types:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid activity_type. Must be one of {valid_types}."
        )

    now_utc = datetime.now(timezone.utc)

    # 3. Terminate current active activity
    current_active = db.query(models.ActivityLog).filter(
        models.ActivityLog.session_id == session.id,
        models.ActivityLog.end_time == None
    ).first()

    if current_active:
        current_active.end_time = now_utc

    # 4. Initialize new activity
    new_activity = models.ActivityLog(
        session_id=session.id,
        activity_type=req.activity_type,
        start_time=now_utc,
        latitude=req.latitude,
        longitude=req.longitude,
        location_name=req.location_name,
        notes=req.notes
    )

    db.add(new_activity)
    db.commit()
    db.refresh(new_activity)
    return new_activity
