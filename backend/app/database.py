from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from .config import settings

# Create database engine
# pool_pre_ping=True automatically tests the connection health before executing commands
engine = create_engine(settings.DATABASE_URL, pool_pre_ping=True)

# Create a local session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for SQLAlchemy ORM models
Base = declarative_base()

# FastAPI dependency to get the database session per request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
