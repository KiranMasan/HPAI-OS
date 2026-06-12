import os
import time

from fastapi import APIRouter
from fastapi import Depends
from fastapi import UploadFile
from fastapi import File
from fastapi import HTTPException
from fastapi import Request
from fastapi.responses import FileResponse
from pydantic import BaseModel

from app.voice.voice_pipeline import process_voice, process_text
from app.core.security import get_current_user

router = APIRouter()

VOICE_DIR = "voice_uploads"
AUDIO_DIR = os.path.join(VOICE_DIR, "responses")

os.makedirs(AUDIO_DIR, exist_ok=True)


class VoiceTextRequest(BaseModel):
    text: str


@router.post("/voice-chat")
async def voice_chat(request: Request, file: UploadFile = File(...), user=Depends(get_current_user)):
    try:
        if not file.filename:
            raise HTTPException(status_code=400, detail="File name is required")

        # save uploaded file with timestamp prefix to avoid collisions
        safe_name = f"{int(time.time())}_{file.filename}"
        file_path = os.path.join(VOICE_DIR, safe_name)

        contents = await file.read()
        with open(file_path, "wb") as buffer:
            buffer.write(contents)

        # log saved file info
        try:
            size = os.path.getsize(file_path)
            print(f"[voice_chat] Saved upload: {file_path} ({size} bytes)")
        except Exception:
            print(f"[voice_chat] Saved upload: {file_path}")

        result = process_voice(file_path)

        if not result or 'transcription' not in result or 'response' not in result:
            raise HTTPException(status_code=500, detail="Failed to process voice message")

        if result.get('audio_path'):
            result['audio_url'] = str(request.base_url).rstrip('/') + result['audio_path']

        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send voice message: {str(e)}")


@router.post("/voice-chat-text")
async def voice_chat_text(request: Request, payload: VoiceTextRequest, user=Depends(get_current_user)):
    try:
        text = payload.text.strip()
        if not text:
            raise HTTPException(status_code=400, detail="Text is required")

        print(f"[voice_chat_text] Received text: {text[:200]}")
        result = process_text(text)

        if not result or 'transcription' not in result or 'response' not in result:
            raise HTTPException(status_code=500, detail="Failed to process text voice message")

        if result.get('audio_path'):
            result['audio_url'] = str(request.base_url).rstrip('/') + result['audio_path']

        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send text voice message: {str(e)}")


@router.get("/voice-chat/audio/{audio_filename}")
def get_voice_audio(audio_filename: str):
    if ".." in audio_filename or audio_filename.startswith("/"):
        raise HTTPException(status_code=400, detail="Invalid audio filename")

    file_path = os.path.join(AUDIO_DIR, audio_filename)

    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Audio file not found")

    return FileResponse(file_path, media_type="audio/wav")


@router.get("/voice-chat/last-upload")
def get_last_upload(user=Depends(get_current_user)):
    """Return the most recent uploaded file for debugging purposes."""
    try:
        files = [
            os.path.join(VOICE_DIR, f)
            for f in os.listdir(VOICE_DIR)
            if os.path.isfile(os.path.join(VOICE_DIR, f))
        ]
        if not files:
            raise HTTPException(status_code=404, detail="No uploads found")

        latest = max(files, key=os.path.getmtime)
        return {
            "last_upload": os.path.basename(latest),
            "size": os.path.getsize(latest),
            "path": latest,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
