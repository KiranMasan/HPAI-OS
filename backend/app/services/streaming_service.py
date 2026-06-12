import ollama
from ollama import ResponseError

from app.core.config import (
    OLLAMA_MODEL
)

def stream_response(message: str):

    try:
        stream = ollama.chat(
            model=OLLAMA_MODEL,

            messages=[
                {
                    "role": "user",
                    "content": message
                }
            ],

            stream=True
        )

        for chunk in stream:

            content = chunk["message"]["content"]

            yield content
    except ResponseError as exc:
        yield (
            "I reached Ollama, but the configured model is not ready. "
            f"Run `ollama pull {OLLAMA_MODEL}` and try again. Details: {exc}"
        )
    except Exception as exc:
        yield (
            "The backend is running, but Ollama is not reachable right now. "
            "Start it with `ollama serve` and try again. "
            f"Details: {exc}"
        )
