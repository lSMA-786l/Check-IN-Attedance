import jwt
from datetime import datetime, timezone, timedelta
from app.config import settings
from app.database import SessionLocal
from app.models import User

def generate_token():
    # Load users from database using the connection string in .env
    db = SessionLocal()
    try:
        users = db.query(User).filter(User.is_active == True).all()
        if not users:
            print("No active users found in the public.users database. Please check your Supabase connection and tables.")
            return
        
        print("\n--- Available Users for Testing ---")
        for idx, u in enumerate(users):
            print(f"[{idx}] {u.full_name} ({u.email}) - Role: {u.role} - Type: {u.work_type}")
            
        choice = input("\nEnter the index of the user to generate a token for [0]: ").strip()
        idx = int(choice) if choice.isdigit() else 0
        if idx < 0 or idx >= len(users):
            idx = 0
            
        selected_user = users[idx]
        
        # JWT payload following standard Supabase Auth structure
        payload = {
            "sub": str(selected_user.id),
            "email": selected_user.email,
            "role": "authenticated",
            "aud": "authenticated",
            "exp": int((datetime.now(timezone.utc) + timedelta(days=7)).timestamp())
        }
        
        # Sign the token using your project's secret
        token = jwt.encode(payload, settings.SUPABASE_JWT_SECRET, algorithm="HS256")
        
        print("\n======================================================================")
        print(f"Generated JWT Token for: {selected_user.full_name} ({selected_user.email})")
        print("======================================================================")
        print(token)
        print("======================================================================\n")
        print("1. Copy the entire token string printed above.")
        print("2. In Swagger UI, click the 'Authorize' button (or click 'Logout' first if already authorized).")
        print("3. Paste the token in the Value box and click 'Authorize'.")
        
    except Exception as e:
        print(f"Failed to generate token: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    generate_token()
