from fastapi import APIRouter
from fastapi import WebSocket
from fastapi import Query
from jose import JWTError
from typing import Optional
from starlette.websockets import WebSocketDisconnect

from app.services.streaming_service import (
    stream_response
)
from app.core.security import SECRET_KEY
from app.core.security import ALGORITHM
from app.core.security import ACCESS_TOKEN_EXPIRE_MINUTES
from jose import jwt

router = APIRouter()


def _validate_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        sub = payload.get("sub")
        if not sub:
            return None
        return sub
    except JWTError:
        return None


@router.websocket("/ws/chat")
async def websocket_chat(
    websocket: WebSocket,
    token: Optional[str] = Query(None)
):

    await websocket.accept()

    if token is None or not _validate_token(token):
        await websocket.close(code=1008)
        return

    try:
        while True:
            try:
                user_message = await websocket.receive_text()
            except WebSocketDisconnect:
                break
            
            if not user_message or user_message.strip() == "":
                await websocket.send_text("Error: Empty message")
                continue

            try:
                for chunk in stream_response(user_message):
                    await websocket.send_text(chunk)
                await websocket.send_text("[END]")
            except Exception as e:
                await websocket.send_text(f"Error: {str(e)}")
                
    except Exception as e:
        try:
            await websocket.close(code=1011, reason=str(e))
        except:
            pass
