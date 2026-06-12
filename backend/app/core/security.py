from passlib.context import CryptContext

from jose import JWTError
from jose import jwt

from datetime import datetime
from datetime import timedelta

from fastapi import Depends
from fastapi import HTTPException
from fastapi import Request

from app.database.db import SessionLocal
from app.models.user_model import User

SECRET_KEY = "hpai_secret_key"

ALGORITHM = "HS256"

ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

def hash_password(password: str):

    password = password[:72]

    return pwd_context.hash(password)


def verify_password(
    plain_password: str,
    hashed_password: str
):

    plain_password = plain_password[:72]

    return pwd_context.verify(
        plain_password,
        hashed_password
    )


def create_access_token(data: dict):

    to_encode = data.copy()

    expire = datetime.utcnow() + timedelta(
        minutes=ACCESS_TOKEN_EXPIRE_MINUTES
    )

    to_encode.update({"exp": expire})

    encoded_jwt = jwt.encode(
        to_encode,
        SECRET_KEY,
        algorithm=ALGORITHM
    )

    return encoded_jwt


def _extract_token(request: Request):
    auth_header = request.headers.get("Authorization")
    if auth_header:
        auth_parts = auth_header.split()
        if len(auth_parts) == 2 and auth_parts[0].lower() == "bearer":
            return auth_parts[1]

    query_token = request.query_params.get("token")
    if query_token:
        return query_token

    raise HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"}
    )


def get_current_user(request: Request, token: str = Depends(_extract_token)):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"}
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        sub = payload.get("sub")
        if not sub:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    db = SessionLocal()
    user = db.query(User).filter(User.email == sub).first()
    if not user:
        raise credentials_exception

    return user

