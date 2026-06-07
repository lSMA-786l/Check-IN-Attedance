# Backend Code File Mappings & Roles

This document describes the role, imports, and inner workings of every source file inside the `backend/` project folder.

---

## 1. Core Config & Database

### `app/config.py`
*   **Role**: Loads configurations from environment variables (using `python-dotenv`). It serves as a single source of truth for settings, preventing secret values from being hardcoded.
*   **Key Fields**:
    *   `DATABASE_URL`: Connection string for Supabase PostgreSQL.
    *   `SUPABASE_JWT_SECRET`: Signing secret key to verify user login tokens.
    *   `ALLOWED_ORIGINS`: Decoded list of domains allowed to bypass CORS blocks (allows mobile apps to connect).

### `app/database.py`
*   **Role**: Initializes the SQLAlchemy database engine and connection pool. It also provides the dependency injection function `get_db()`.
*   **Core Concepts**:
    *   `create_engine(..., pool_pre_ping=True)`: Creates the database connector. `pool_pre_ping=True` sends a lightweight SQL command to test the connection health before every request, automatically recycling stale connections.
    *   `SessionLocal`: Session factory configured with `autocommit=False` (changes are explicitly saved using `db.commit()`) and `autoflush=False`.
    *   `get_db()`: Yields a database session instance per API request and safely terminates/closes it when the request is complete, preventing connection leaks.

---

## 2. Models & Schemas

### `app/models.py`
*   **Role**: Defines SQLAlchemy ORM models matching our 7 database tables.
*   **Key Relations**:
    *   **Self-referential joins**: The `User` model references itself via `manager_id`. It exposes `manager = relationship("User", remote_side=[id], back_populates="subordinates")` and `subordinates = relationship("User", back_populates="manager")` to easily query company structure.
    *   **Database-Agnostic Defaults**: To support unit testing, fields use SQLAlchemy's `func.now()` (which maps to `now()` on Postgres and `CURRENT_TIMESTAMP` on SQLite) and Python's `uuid.uuid4` for default IDs.

### `app/schemas.py`
*   **Role**: Houses Pydantic V2 models for validating request payloads and filtering response bodies (serialization).
*   **Core Features**:
    *   Uses Pydantic's `model_config = {"from_attributes": True}` to automatically translate database ORM objects into JSON response payloads.
    *   Includes validation constraints, such as coordinates constraints `ge=-90, le=90` (for Latitude) and `ge=-180, le=180` (for Longitude).

---

## 3. API Routers

### `app/routes/auth.py`
*   **Role**: Authenticates users and handles the `/api/auth/me` profile route.
*   **Core Functions**:
    *   `get_current_user(...)`: A security dependency that extracts the Bearer token from the `Authorization` header, decodes the Supabase JWT using `jwt.decode()` (with `verify_aud=False` to handle multi-tenant environments), extracts the `sub` UUID claim, queries `public.users`, checks if the user `is_active`, and returns the profile.
    *   `GET /me`: Injects `get_current_user` to return the logged-in user's profile with their department and shift nested objects.

### `app/routes/attendance.py`
*   **Role**: Manages the check-in/out and activity logs logic.
*   **Core Endpoints**:
    *   `GET /status`: Returns the current active attendance session (where `clock_out` is `NULL`) or `None` if the employee is not checked in.
    *   `POST /check-in`: Accepts check-in coordinates, runs work-type specific logic (geofence math, initial activity logging), and records the session.
    *   `POST /check-out`: Closes the current session, calculates elapsed worked hours, closes active activity blocks, and flags daily status.
    *   `POST /activity`: Allows field staff to post activity transitions (e.g., swapping from `TRAVEL` to `MEETING` or `BREAK`).

---

## 4. Entrypoint & Utilities

### `app/main.py`
*   **Role**: The main FastAPI application entrypoint.
*   **Core Tasks**:
    *   Initializes `app = FastAPI()`.
    *   Registers `CORSMiddleware` with allowed origins from configuration.
    *   Includes routers: `auth.router` and `attendance.router`.
    *   Defines a lightweight `GET /` health-check route.

### `generate_test_token.py`
*   **Role**: A development utility script.
*   **Details**: Reads active profiles directly from your Supabase database via SQLAlchemy, lets you choose a user, and prints a signed JWT token containing their UUID. This allows testing authenticated routes in Swagger UI or Postman without having to write authentication screens in Flutter first.
