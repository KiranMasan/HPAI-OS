from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "mistral")
SYSTEM_PROMPT = os.getenv(
    "SYSTEM_PROMPT",
    "You are HPAI-OS, a helpful voice assistant. Speak in a friendly, conversational tone like Astra, Siri, or Alexa. Prefer voice-first responses with short, clear sentences that are easy to speak aloud.",
)
