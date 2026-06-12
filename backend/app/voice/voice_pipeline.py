import os
import uuid

from app.voice.speech_to_text import transcribe_audio
from app.voice.text_to_speech import save_text_to_file

from app.agents.router import route_agent

VOICE_DIR = "voice_uploads"
AUDIO_DIR = os.path.join(VOICE_DIR, "responses")

os.makedirs(AUDIO_DIR, exist_ok=True)


def process_voice(audio_path):

    print(f"[voice_pipeline] process_voice called with: {audio_path}")

    # Convert speech to text
    user_text = transcribe_audio(audio_path)
    print(f"[voice_pipeline] transcription: {user_text[:200]}")

    # AI response
    ai_response = route_agent(user_text)
    print(f"[voice_pipeline] agent response (truncated): {ai_response[:200]}")

    audio_path_url = None
    try:
        filename = f"response_{uuid.uuid4().hex}.wav"
        output_path = os.path.join(AUDIO_DIR, filename)
        save_text_to_file(ai_response, output_path)

        print("[voice_pipeline] TTS OUTPUT PATH:", output_path)
        print("[voice_pipeline] FILE EXISTS AFTER TTS:", os.path.exists(output_path))

        audio_path_url = f"/voice-chat/audio/{filename}"
    except Exception as e:
        print(f"[voice_pipeline] TTS ERROR: {e}")
        audio_path_url = None

    return {
        "transcription": user_text,
        "response": ai_response,
        "audio_path": audio_path_url,
    }


def process_text(user_text):
    print(f"[voice_pipeline] process_text called with: {user_text[:200]}")

    ai_response = route_agent(user_text)
    print(f"[voice_pipeline] process_text response (truncated): {ai_response[:200]}")

    audio_path_url = None
    try:
        filename = f"response_{uuid.uuid4().hex}.wav"
        output_path = os.path.join(AUDIO_DIR, filename)
        save_text_to_file(ai_response, output_path)
        audio_path_url = f"/voice-chat/audio/{filename}"
    except Exception:
        print("[voice_pipeline] failed to save TTS audio for text request")
        audio_path_url = None

    return {
        "transcription": user_text,
        "response": ai_response,
        "audio_path": audio_path_url,
    }
