from faster_whisper import WhisperModel
import os
import subprocess
import tempfile

# initialize model once
model = WhisperModel(
    "base",
    device="cpu",
    compute_type="int8"
)


def _ensure_wav(input_path: str) -> str:
    """Ensure audio is WAV. If input is already WAV return it, otherwise convert with ffmpeg.

    Returns path to WAV file (may be a temp file). Caller should not delete original.
    """
    if input_path.lower().endswith('.wav'):
        return input_path

    # create temp wav file
    fd, out_path = tempfile.mkstemp(suffix='.wav')
    os.close(fd)

    try:
        # ffmpeg must be available on the host
        subprocess.run([
            'ffmpeg', '-y', '-i', input_path, '-ar', '16000', '-ac', '1', out_path
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return out_path
    except Exception:
        # conversion failed, cleanup and raise
        try:
            if os.path.exists(out_path):
                os.remove(out_path)
        except Exception:
            pass
        raise


def transcribe_audio(audio_path):
    # convert to WAV if needed
    wav_path = None
    try:
        wav_path = _ensure_wav(audio_path)
    except Exception as exc:
        # If conversion fails, try transcribing the original file — model may still handle it
        try:
            segments, info = model.transcribe(audio_path)
        except Exception:
            return ""
        text = "".join([s.text for s in segments])
        return text

    try:
        segments, info = model.transcribe(wav_path)
        text = "".join([s.text for s in segments])
        return text
    finally:
        # remove temporary wav if we created one
        if wav_path and wav_path != audio_path and os.path.exists(wav_path):
            try:
                os.remove(wav_path)
            except Exception:
                pass