from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException
from pydantic import BaseModel
from uuid import uuid4

from app.database.db import SessionLocal
from app.models.chat_model import ChatHistory

from app.agents.router import route_agent
from app.core.security import get_current_user

router = APIRouter()

class ChatRequest(BaseModel):
    message: str
    session_id: str | None = None

@router.post("/chat")
def chat(request: ChatRequest, user=Depends(get_current_user)):
    db = SessionLocal()
    try:
        if not request.message or request.message.strip() == "":
            raise HTTPException(status_code=400, detail="Message cannot be empty")

        session_id = request.session_id or str(uuid4())

        # Fetch previous chats
        previous_chats = db.query(ChatHistory)\
            .filter(ChatHistory.session_id == session_id)\
            .order_by(ChatHistory.timestamp.desc())\
            .limit(5)\
            .all()

        memory_context = ""

        for chat in reversed(previous_chats):
            memory_context += f"""
        User: {chat.user_message}
        AI: {chat.ai_response}
        """

        enhanced_message = f"""
Previous Conversation:
{memory_context}

Current User Message:
{request.message}
"""

        response = route_agent(enhanced_message)

        if not response or response.strip() == "":
            raise HTTPException(status_code=500, detail="Failed to generate response")

        chat_entry = ChatHistory(
            session_id=session_id,
            user_message=request.message,
            ai_response=response
        )

        db.add(chat_entry)
        db.commit()

        return {
            "session_id": session_id,
            "response": response
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    finally:
        db.close()
