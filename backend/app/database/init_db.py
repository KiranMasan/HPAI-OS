from app.database.db import engine
from app.models.chat_model import ChatHistory
from app.database.db import Base
from app.models.user_model import User

def create_tables():
    Base.metadata.create_all(bind=engine)