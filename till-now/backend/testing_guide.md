# Testing & Verification Guide

This document describes how the automated unit test suite is architected, how dependencies are mocked, and how to verify the API endpoints.

---

## 1. Automated Test Architecture (`tests/test_attendance.py`)

To ensure we can run tests rapidly and reliably without polluting your production Supabase database, the test suite uses an isolated, in-memory **SQLite database**.

### Dependency Overriding in FastAPI:
FastAPI has native support for overriding injected dependencies at test time. We take advantage of this to redirect database calls and authentication checks:

```python
from app.main import app
from app.database import get_db
from app.routes.auth import get_current_user

# 1. Override the DB session to use SQLite instead of Postgres
app.dependency_overrides[get_db] = override_get_db

# 2. Override JWT validation to return a mock logged-in user context
app.dependency_overrides[get_current_user] = override_get_current_user
```

### Static Connection Pooling:
SQLite in-memory databases (`sqlite:///:memory:`) delete all tables the instant their connection closes. To prevent SQLite from destroying the tables between different API request threads, we use SQLAlchemy's `StaticPool`:
```python
from sqlalchemy.pool import StaticPool

engine = create_engine(
    "sqlite:///:memory:",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool  # Keeps a single connection open for the whole process
)
```

---

## 2. Test Cases Covered

The test suite in [test_attendance.py](file:///d:/NOVA/flutter_st/attendnova_3/backend/tests/test_attendance.py) covers 6 crucial verification scenarios:

1.  **`test_health_check`**: 
    Verifies that the base API (`GET /`) is responsive and returns `status: healthy`.
2.  **`test_auth_me_without_token`**: 
    Verifies that requesting `/api/auth/me` without a valid token correctly returns a `401 Unauthorized` block.
3.  **`test_auth_me_with_user`**: 
    Verifies that providing a valid token returns the correct authenticated user profile.
4.  **`test_office_worker_check_in_in_bounds`**: 
    Simulates checking in exactly at the department's coordinates (HQ). Verifies that the check-in succeeds with `is_out_of_bounds = False` and `verification_status = 'APPROVED'`.
5.  **`test_office_worker_check_in_out_of_bounds`**: 
    Simulates checking in far away from the department's HQ. Verifies that the check-in succeeds but flags the session as `is_out_of_bounds = True` and `verification_status = 'PENDING_APPROVAL'`.
6.  **`test_field_worker_check_in_and_activity_logging`**: 
    Simulates checking in, automatically starting the `TRAVEL` log, swapping activities to `MEETING`, checking status updates, and clocking out to verify hours calculation.

---

## 3. Running the Test Suite

Execute the following command in your terminal from the `backend/` directory:
```bash
python -m pytest
```

### Expected Output:
```text
======================== test session starts ========================
platform win32 -- Python 3.13.9, pytest-9.0.3, pluggy-1.6.0
rootdir: D:\NOVA\flutter_st\attendnova_3\backend
plugins: anyio-4.13.0
collected 6 items                                                    

tests\test_attendance.py ......                                [100%]

=================== 6 passed, 1 warning in 1.11s ====================
```

---

## 4. Live Manual Verification (Swagger UI)

To manually test the API with your live Supabase database:

1.  Start the dev server:
    ```bash
    python -m uvicorn app.main:app --reload
    ```
2.  Open **[http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)**.
3.  Run the token generator utility in another terminal window to sign a test JWT:
    ```bash
    python generate_test_token.py
    ```
4.  Select a user, copy the printed JWT token.
5.  Click the **Authorize** button in Swagger UI, type `Bearer <token>` (or just the raw token as we use HTTPBearer), and click **Authorize**.
6.  Expand any endpoint, click **Try it out**, fill in parameters, and click **Execute** to view live database responses.
