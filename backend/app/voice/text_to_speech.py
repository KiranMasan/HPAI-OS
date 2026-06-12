"""Text-to-speech.

This module is imported during app startup. Some environments may not have
optional TTS dependencies installed (e.g., `pyttsx3`). We try `pyttsx3`
first; if unavailable we fall back to `gTTS` + `ffmpeg` to produce a WAV.
"""

from __future__ import annotations
import os
import subprocess
import tempfile

DEVNULL = subprocess.DEVNULL

try:
    import pyttsx3  # type: ignore

    _engine = pyttsx3.init()
    _engine.setProperty('rate', 170)

    def speak_text(text: str) -> None:
        _engine.say(text)
        _engine.runAndWait()

    def save_text_to_file(text: str, audio_path: str) -> None:
        _engine.save_to_file(text, audio_path)
        _engine.runAndWait()

except Exception:
    # fallback using gTTS -> mp3 -> ffmpeg -> wav
    try:
        from gtts import gTTS  # type: ignore

        def speak_text(text: str) -> None:
            # best-effort: generate mp3, convert to wav, play is not implemented here
            tmp_mp3 = tempfile.mktemp(suffix='.mp3')
            try:
                gTTS(text=text, lang='en').save(tmp_mp3)
                # transient convert to wav then remove mp3
                tmp_wav = tempfile.mktemp(suffix='.wav')
                subprocess.run(['ffmpeg', '-y', '-i', tmp_mp3, '-ar', '16000', '-ac', '1', tmp_wav], check=True, stdout=DEVNULL, stderr=DEVNULL)
                try:
                    if os.path.exists(tmp_wav):
                        # platform-specific playback not provided here
                        pass
                finally:
                    try:
                        os.remove(tmp_wav)
                    except Exception:
                        pass
            finally:
                try:
                    if os.path.exists(tmp_mp3):
                        os.remove(tmp_mp3)
                except Exception:
                    pass

        def save_text_to_file(text: str, audio_path: str) -> None:
            tmp_mp3 = tempfile.mktemp(suffix='.mp3')
            try:
                gTTS(text=text, lang='en').save(tmp_mp3)
                # convert mp3 to wav using ffmpeg
                subprocess.run(['ffmpeg', '-y', '-i', tmp_mp3, '-ar', '16000', '-ac', '1', audio_path], check=True, stdout=DEVNULL, stderr=DEVNULL)
            finally:
                try:
                    if os.path.exists(tmp_mp3):
                        os.remove(tmp_mp3)
                except Exception:
                    pass

    except Exception:
        def speak_text(text: str) -> None:
            return

        def save_text_to_file(text: str, audio_path: str) -> None:
            raise RuntimeError("Text-to-speech is unavailable: missing pyttsx3 and gTTS/ffmpeg fallback.")

