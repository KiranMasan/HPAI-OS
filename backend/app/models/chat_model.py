from sqlalchemy import Column, Integer, String, Text, DateTime
from datetime import datetime

from app.database.db import Base

class ChatHistory(Base):

    __tablename__ = "chat_history"

    id = Column(Integer, primary_key=True, index=True)

    session_id = Column(String, index=True)

    user_message = Column(Text)

    ai_response = Column(Text)

    timestamp = Column(DateTime, default=datetime.utcnow)