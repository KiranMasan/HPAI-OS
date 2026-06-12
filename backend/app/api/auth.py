from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.exc import IntegrityError

from app.schemas.user_schema import UserRegister, UserLogin
from app.database.db import SessionLocal
from app.models.user_model import User
from app.core.security import hash_password, verify_password, create_access_token, get_current_user

router = APIRouter()


@router.post("/register")
def register(user: UserRegister):
    db = SessionLocal()
    try:
        existing_user = (
            db.query(User)
            .filter((User.email == user.email) | (User.username == user.username))
            .first()
        )

        if existing_user:
            raise HTTPException(status_code=400, detail="Username or email already exists")

        hashed_pw = hash_password(user.password)

        new_user = User(
            username=user.username,
            email=user.email,
            password=hashed_pw,
        )

        db.add(new_user)
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
            raise HTTPException(status_code=400, detail="Username or email already exists")

        return {"message": "User registered successfully"}
    finally:
        db.close()


@router.post("/login")
def login(user: UserLogin):
    db = SessionLocal()
    try:
        db_user = (
            db.query(User)
            .filter(User.email == user.email)
            .first()
        )

        if not db_user:
            raise HTTPException(status_code=401, detail="Invalid credentials")

        valid_password = verify_password(user.password, db_user.password)

        if not valid_password:
            raise HTTPException(status_code=401, detail="Invalid credentials")

        token = create_access_token({"sub": db_user.email})

        return {
            "access_token": token,
            "token_type": "bearer",
            "username": db_user.username,
        }
    finally:
        db.close()


@router.get("/verify-token")
def verify_token(user=Depends(get_current_user)):
    return {
        "valid": True,
        "email": user.email,
        "username": user.username,
    }
