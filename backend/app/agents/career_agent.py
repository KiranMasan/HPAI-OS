from __future__ import annotations

from app.services.ollama_service import generate_response


def career_agent(message: str) -> str:

    """Career/placement/resume/interview assistant."""

    prompt = f"""
You are a career coaching assistant.
Style:
- Speak like a friendly voice assistant (Astra, Siri, Alexa).
- Keep the tone natural and easy to listen to.
- Use short, encouraging phrases and make advice sound conversational.

Help the user with career guidance such as: career planning, job search, resumes, interviews, and placement.

User message:
{message}

Return a helpful, structured answer.
""".strip()

    return generate_response(prompt)

