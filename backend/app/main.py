from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import settings
from .routes import auth, attendance

# Initialize FastAPI App
app = FastAPI(
    title="AttendNova API",
    description="REST API Backend for AttendNova Attendance and Leave Tracking System",
    version="1.0.0"
)

# Set up CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router)
app.include_router(attendance.router)

@app.get("/", tags=["health"])
def health_check():
    """
    Service health check endpoint.
    """
    return {
        "status": "healthy",
        "service": "AttendNova API Backend",
        "version": "1.0.0"
    }
