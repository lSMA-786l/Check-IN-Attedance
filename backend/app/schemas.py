from pydantic import BaseModel, Field, EmailStr
from uuid import UUID
from datetime import datetime, date, time
from typing import List, Optional
from decimal import Decimal

# Department schemas
class DepartmentBase(BaseModel):
    name: str
    location: Optional[str] = None
    geofence_lat: Optional[Decimal] = None
    geofence_lng: Optional[Decimal] = None
    allowed_radius_meters: int = 100

class DepartmentOut(DepartmentBase):
    id: UUID
    created_at: datetime

    model_config = {
        "from_attributes": True
    }

# Shift schemas
class ShiftBase(BaseModel):
    name: str
    start_time: time
    end_time: time
    grace_period_minutes: int = 15

class ShiftOut(ShiftBase):
    id: UUID
    created_at: datetime

    model_config = {
        "from_attributes": True
    }

# User schemas
class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    phone: Optional[str] = None
    role: str # ADMIN, MANAGER, EMPLOYEE
    work_type: str # FIELD, OFFICE, REMOTE
    profile_photo_url: Optional[str] = None

class UserOut(UserBase):
    id: UUID
    department_id: Optional[UUID] = None
    manager_id: Optional[UUID] = None
    shift_id: Optional[UUID] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = {
        "from_attributes": True
    }

class UserWithRelations(UserOut):
    department: Optional[DepartmentOut] = None
    shift: Optional[ShiftOut] = None

    model_config = {
        "from_attributes": True
    }

# Attendance Session schemas
class CheckInRequest(BaseModel):
    latitude: Decimal = Field(..., ge=-90, le=90)
    longitude: Decimal = Field(..., ge=-180, le=180)
    location_name: Optional[str] = None

class ActivityLogCreate(BaseModel):
    activity_type: str = Field(..., description="TRAVEL, MEETING, WORK, BREAK")
    latitude: Decimal = Field(..., ge=-90, le=90)
    longitude: Decimal = Field(..., ge=-180, le=180)
    location_name: Optional[str] = None
    notes: Optional[str] = None

class ActivityLogOut(BaseModel):
    id: UUID
    session_id: UUID
    activity_type: str
    start_time: datetime
    end_time: Optional[datetime] = None
    latitude: Decimal
    longitude: Decimal
    location_name: Optional[str] = None
    notes: Optional[str] = None

    model_config = {
        "from_attributes": True
    }

class AttendanceSessionOut(BaseModel):
    id: UUID
    user_id: UUID
    shift_id: UUID
    shift_date: date
    clock_in: datetime
    clock_out: Optional[datetime] = None
    total_hours: Optional[Decimal] = None
    status: str
    is_out_of_bounds: bool
    verification_status: str
    created_at: datetime
    activity_logs: List[ActivityLogOut] = []

    model_config = {
        "from_attributes": True
    }

# Leave Balance schemas
class LeaveBalanceOut(BaseModel):
    id: UUID
    user_id: UUID
    year: int
    leave_type: str # SICK, CASUAL, ANNUAL
    total_days: int
    used_days: int
    pending_days: int

    model_config = {
        "from_attributes": True
    }

# Leave schemas
class LeaveCreate(BaseModel):
    leave_type: str # SICK, CASUAL, ANNUAL
    start_date: date
    end_date: date
    reason: str
    attachment_url: Optional[str] = None

class LeaveOut(BaseModel):
    id: UUID
    user_id: UUID
    leave_type: str
    start_date: date
    end_date: date
    total_days: int
    reason: str
    attachment_url: Optional[str] = None
    status: str # PENDING, APPROVED, REJECTED
    approved_by: Optional[UUID] = None
    manager_comments: Optional[str] = None
    created_at: datetime

    model_config = {
        "from_attributes": True
    }
