# AttendNova REST API Backend

This is the production-ready REST API backend for the **AttendNova** Attendance and Leave Tracking system. Built with **FastAPI** and **SQLAlchemy 2.0**, it integrates with Supabase PostgreSQL and handles the geofencing calculations, check-in bounds checking, and activity timeline logging.

## Tech Stack & Libraries
- **FastAPI**: Asynchronous web framework for high-performance REST APIs.
- **SQLAlchemy 2.0 ORM**: Type-safe and expressive database mappings.
- **Pydantic V2**: Request payload validations and schema serialization.
- **PyJWT**: Validates Supabase JWT signatures on incoming API requests.
- **Pytest**: Automated unit testing environment.

---

## Directory Structure
```
backend/
├── app/
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── auth.py          # Supabase JWT decoding & user profile fetch
│   │   └── attendance.py    # Check-in, check-out, geofence, and activity logs
│   ├── __init__.py
│   ├── config.py            # Configuration settings loader
│   ├── database.py          # SQLAlchemy engine and session factory
│   ├── main.py              # FastAPI application entrypoint
│   ├── models.py            # Database tables ORM definitions
│   └── schemas.py           # Pydantic schemas for API request/response
├── tests/
│   ├── __init__.py
│   └── test_attendance.py   # Full suite of unit tests using SQLite in-memory
├── requirements.txt         # Production and development dependencies
└── README.md                # Documentation guide
```

---

## Local Setup Instructions

Please follow the commands below in your command prompt / powershell to set up the development environment.

### 1. Create a Virtual Environment
Initialize a clean Python virtual environment inside the `backend/` directory:
```bash
python -m venv venv
```

### 2. Activate the Virtual Environment
- **Windows (PowerShell):**
  ```powershell
  .\venv\Scripts\Activate.ps1
  ```
- **Windows (Command Prompt):**
  ```cmd
  .\venv\Scripts\activate.bat
  ```
- **macOS / Linux:**
  ```bash
  source venv/bin/activate
  ```

### 3. Install Dependencies
Install all required packages from `requirements.txt`:
```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables
Create a `.env` file in the `backend/` directory (ensure it matches `.env.example`).
> [!IMPORTANT]
> - Do not commit your `.env` file to Git repository.
> - Populate it with your database connection details and Supabase JWT Secret:
```ini
DATABASE_URL=postgresql://postgres:[password]@[host]:5432/postgres
SUPABASE_JWT_SECRET=your_supabase_jwt_secret_here
ALLOWED_ORIGINS=*
```

---

## Running Automated Tests

A complete suite of tests is implemented using SQLite in-memory so you do not need database credentials to run them.

Run the tests inside your terminal with:
```bash
pytest
```

---

## Starting the Server Locally

Start the local development server using Uvicorn with auto-reload:
```bash
uvicorn app.main:app --reload
```

Once the server has started successfully, you can view:
- **API Base URL:** http://127.0.0.1:8000
- **Interactive Documentation (Swagger UI):** http://127.0.0.1:8000/docs
- **Alternative Documentation (Redoc):** http://127.0.0.1:8000/redoc
