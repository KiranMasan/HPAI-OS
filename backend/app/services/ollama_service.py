import ollama
from ollama import ResponseError

from app.core.config import OLLAMA_MODEL
from app.core.config import SYSTEM_PROMPT

def generate_response(message: str):

    try:
        response = ollama.chat(
            model=OLLAMA_MODEL,
            messages=[
                {
                    "role": "system",
                    "content": SYSTEM_PROMPT
                },
                {
                    "role": "user",
                    "content": message
                }
            ]
        )

        return response["message"]["content"]
    except ResponseError as exc:
        return (
            "I reached the local AI service, but the configured model is not ready. "
            f"Please run `ollama pull {OLLAMA_MODEL}` and try again. Details: {exc}"
        )
    except Exception as exc:
        return (
            "The HPAI-OS backend is running, but I could not reach Ollama right now. "
            "Start Ollama with `ollama serve`, make sure the model is pulled, and try again. "
            f"Details: {exc}"
        )
