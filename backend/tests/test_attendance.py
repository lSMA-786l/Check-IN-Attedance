import pytest
from fastapi.testclient import TestClient
from fastapi import HTTPException
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import uuid
from datetime import datetime, time, date, timezone
from decimal import Decimal

from app.main import app
from app.database import Base, get_db
from app.routes.auth import get_current_user
from app import models

from sqlalchemy.pool import StaticPool

# In-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create tables in the testing database
Base.metadata.create_all(bind=engine)

# Contextual mock user for authentication overriding
current_mock_user = None

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

def override_get_current_user():
    if current_mock_user is None:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return current_mock_user

# Apply overrides to app
app.dependency_overrides[get_db] = override_get_db
app.dependency_overrides[get_current_user] = override_get_current_user

client = TestClient(app)

@pytest.fixture(autouse=True)
def setup_db_and_clean():
    # Clear tables and re-create for clean state per test
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    # Insert initial mock data (Shifts, Departments, etc.)
    db = TestingSessionLocal()
    
    # 1. Shifts
    day_shift = models.Shift(
        id=uuid.uuid4(),
        name="Day Shift",
        start_time=time(9, 0, 0),
        end_time=time(17, 0, 0),
        grace_period_minutes=15
    )
    night_shift = models.Shift(
        id=uuid.uuid4(),
        name="Night Shift",
        start_time=time(22, 0, 0),
        end_time=time(6, 0, 0),
        grace_period_minutes=15
    )
    db.add(day_shift)
    db.add(night_shift)
    
    # 2. Departments
    hq_dept = models.Department(
        id=uuid.uuid4(),
        name="HQ",
        location="Main Office",
        geofence_lat=Decimal("40.712800"),
        geofence_lng=Decimal("-74.006000"),
        allowed_radius_meters=100
    )
    db.add(hq_dept)
    
    db.commit()
    db.close()
    
    global current_mock_user
    current_mock_user = None
    yield

def get_test_entities():
    db = TestingSessionLocal()
    shifts = db.query(models.Shift).all()
    depts = db.query(models.Department).all()
    db.close()
    return shifts, depts

def test_health_check():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_auth_me_without_token():
    # Overrides should raise 401 if current_mock_user is None
    response = client.get("/api/auth/me")
    assert response.status_code == 401

def test_auth_me_with_user():
    global current_mock_user
    db = TestingSessionLocal()
    
    user = models.User(
        id=uuid.uuid4(),
        email="test_user@gmail.com",
        full_name="Test User",
        role="EMPLOYEE",
        work_type="REMOTE",
        is_active=True
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    
    current_mock_user = user
    
    response = client.get("/api/auth/me", headers={"Authorization": "Bearer fake_token"})
    assert response.status_code == 200
    assert response.json()["email"] == "test_user@gmail.com"
    db.close()

def test_office_worker_check_in_in_bounds():
    global current_mock_user
    db = TestingSessionLocal()
    shifts, depts = get_test_entities()
    
    # Create office user
    user = models.User(
        id=uuid.uuid4(),
        email="office@gmail.com",
        full_name="Office Staff",
        role="EMPLOYEE",
        work_type="OFFICE",
        department_id=depts[0].id,
        shift_id=shifts[0].id,
        is_active=True
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    
    current_mock_user = user
    
    # Coordinates match HQ department (40.712800, -74.006000)
    payload = {
        "latitude": 40.712800,
        "longitude": -74.006000,
        "location_name": "At Desk"
    }
    
    response = client.post("/api/attendance/check-in", json=payload, headers={"Authorization": "Bearer fake"})
    assert response.status_code == 200
    data = response.json()
    assert data["is_out_of_bounds"] is False
    assert data["verification_status"] == "APPROVED"
    db.close()

def test_office_worker_check_in_out_of_bounds():
    global current_mock_user
    db = TestingSessionLocal()
    shifts, depts = get_test_entities()
    
    # Create office user
    user = models.User(
        id=uuid.uuid4(),
        email="office_out@gmail.com",
        full_name="Office Staff Out",
        role="EMPLOYEE",
        work_type="OFFICE",
        department_id=depts[0].id,
        shift_id=shifts[0].id,
        is_active=True
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    
    current_mock_user = user
    
    # Coordinates far from HQ (e.g. 40.800000, -74.100000)
    payload = {
        "latitude": 40.800000,
        "longitude": -74.100000,
        "location_name": "Coffee Shop"
    }
    
    response = client.post("/api/attendance/check-in", json=payload, headers={"Authorization": "Bearer fake"})
    assert response.status_code == 200
    data = response.json()
    assert data["is_out_of_bounds"] is True
    assert data["verification_status"] == "PENDING_APPROVAL"
    db.close()

def test_field_worker_check_in_and_activity_logging():
    global current_mock_user
    db = TestingSessionLocal()
    shifts, depts = get_test_entities()
    
    user = models.User(
        id=uuid.uuid4(),
        email="field@gmail.com",
        full_name="Field Staff",
        role="EMPLOYEE",
        work_type="FIELD",
        department_id=depts[0].id,
        shift_id=shifts[0].id,
        is_active=True
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    
    current_mock_user = user
    
    # Check-in from anywhere
    payload = {
        "latitude": 34.052200,
        "longitude": -118.243700,
        "location_name": "Field Office"
    }
    
    response = client.post("/api/attendance/check-in", json=payload, headers={"Authorization": "Bearer fake"})
    assert response.status_code == 200
    data = response.json()
    assert data["is_out_of_bounds"] is False
    assert data["verification_status"] == "APPROVED"
    assert len(data["activity_logs"]) == 1
    assert data["activity_logs"][0]["activity_type"] == "TRAVEL"
    
    # Start a new activity: MEETING
    activity_payload = {
        "activity_type": "MEETING",
        "latitude": 34.060000,
        "longitude": -118.250000,
        "location_name": "Client Site A",
        "notes": "Meeting with Client"
    }
    
    act_response = client.post("/api/attendance/activity", json=activity_payload, headers={"Authorization": "Bearer fake"})
    assert act_response.status_code == 200
    act_data = act_response.json()
    assert act_data["activity_type"] == "MEETING"
    assert act_data["notes"] == "Meeting with Client"
    
    # Verify that status returns the active session with updated activity logs
    status_response = client.get("/api/attendance/status", headers={"Authorization": "Bearer fake"})
    assert status_response.status_code == 200
    status_data = status_response.json()
    # There should be 2 activity logs: TRAVEL (closed) and MEETING (active/open)
    assert len(status_data["activity_logs"]) == 2
    
    # Clock-out
    checkout_response = client.post("/api/attendance/check-out", headers={"Authorization": "Bearer fake"})
    assert checkout_response.status_code == 200
    checkout_data = checkout_response.json()
    assert checkout_data["clock_out"] is not None
    db.close()
