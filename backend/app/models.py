import uuid
from sqlalchemy import Column, String, Integer, Numeric, Boolean, Date, Time, DateTime, ForeignKey, text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from .database import Base

class Department(Base):
    __tablename__ = "departments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    name = Column(String(100), nullable=False, unique=True)
    location = Column(String(255))
    geofence_lat = Column(Numeric(9, 6))
    geofence_lng = Column(Numeric(9, 6))
    allowed_radius_meters = Column(Integer, default=100)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    users = relationship("User", back_populates="department")

class Shift(Base):
    __tablename__ = "shifts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    name = Column(String(100), nullable=False)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    grace_period_minutes = Column(Integer, default=15)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    users = relationship("User", back_populates="shift")
    attendance_sessions = relationship("AttendanceSession", back_populates="shift")

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True)  # References auth.users(id)
    email = Column(String(255), nullable=False, unique=True)
    full_name = Column(String(150), nullable=False)
    phone = Column(String(20))
    role = Column(String(50), nullable=False)  # ADMIN, MANAGER, EMPLOYEE
    work_type = Column(String(50), nullable=False)  # FIELD, OFFICE, REMOTE
    department_id = Column(UUID(as_uuid=True), ForeignKey("departments.id", ondelete="SET NULL"))
    manager_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    shift_id = Column(UUID(as_uuid=True), ForeignKey("shifts.id", ondelete="SET NULL"))
    profile_photo_url = Column(TEXT := String)
    is_active = Column(Boolean, default=True, nullable=False)
    deleted_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationships
    department = relationship("Department", back_populates="users")
    shift = relationship("Shift", back_populates="users")
    manager = relationship("User", remote_side=[id], back_populates="subordinates")
    subordinates = relationship("User", back_populates="manager")
    attendance_sessions = relationship("AttendanceSession", back_populates="user")
    leave_balances = relationship("LeaveBalance", back_populates="user")
    leaves = relationship("Leave", foreign_keys="Leave.user_id", back_populates="user")

class LeaveBalance(Base):
    __tablename__ = "leave_balances"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    year = Column(Integer, nullable=False)
    leave_type = Column(String(50), nullable=False)  # SICK, CASUAL, ANNUAL
    total_days = Column(Integer, nullable=False)
    used_days = Column(Integer, default=0, nullable=False)
    pending_days = Column(Integer, default=0, nullable=False)

    user = relationship("User", back_populates="leave_balances")

class AttendanceSession(Base):
    __tablename__ = "attendance_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    shift_id = Column(UUID(as_uuid=True), ForeignKey("shifts.id"), nullable=False)
    shift_date = Column(Date, nullable=False)
    clock_in = Column(DateTime(timezone=True), nullable=False)
    clock_out = Column(DateTime(timezone=True))
    total_hours = Column(Numeric(4, 2))
    status = Column(String(50), default="PRESENT", nullable=False)  # PRESENT, HALF_DAY, ABSENT
    is_out_of_bounds = Column(Boolean, default=False, nullable=False)
    verification_status = Column(String(50), default="APPROVED", nullable=False)  # APPROVED, PENDING_APPROVAL, REJECTED
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationships
    user = relationship("User", back_populates="attendance_sessions")
    shift = relationship("Shift", back_populates="attendance_sessions")
    activity_logs = relationship("ActivityLog", back_populates="session", cascade="all, delete-orphan")

class ActivityLog(Base):
    __tablename__ = "activity_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    session_id = Column(UUID(as_uuid=True), ForeignKey("attendance_sessions.id", ondelete="CASCADE"), nullable=False)
    activity_type = Column(String(50), nullable=False)  # TRAVEL, MEETING, WORK, BREAK
    start_time = Column(DateTime(timezone=True), nullable=False)
    end_time = Column(DateTime(timezone=True))
    latitude = Column(Numeric(9, 6), nullable=False)
    longitude = Column(Numeric(9, 6), nullable=False)
    location_name = Column(String(255))
    notes = Column(String)

    session = relationship("AttendanceSession", back_populates="activity_logs")

class Leave(Base):
    __tablename__ = "leaves"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    leave_type = Column(String(50), nullable=False)  # SICK, CASUAL, ANNUAL
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    total_days = Column(Integer, nullable=False)
    reason = Column(String, nullable=False)
    attachment_url = Column(String)
    status = Column(String(50), default="PENDING", nullable=False)  # PENDING, APPROVED, REJECTED
    approved_by = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    manager_comments = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    user = relationship("User", foreign_keys=[user_id], back_populates="leaves")
    approver = relationship("User", foreign_keys=[approved_by])
