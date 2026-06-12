import warnings

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.gzip import GZipMiddleware

# Suppress noisy PyTorch/pynvml deprecation warning.
# Message example:
# "The pynvml package is deprecated. Please install nvidia-ml-py instead."
warnings.filterwarnings(
    "ignore",
    message=r".*pynvml package is deprecated.*",
    category=FutureWarning,
)

from app.api.chat import router as chat_router
from app.api.pdf_chat import router as pdf_router
from app.api.voice_chat import router as voice_router

from app.database.init_db import create_tables

from app.api.auth import router as auth_router

from app.api.stream_chat import (
    router as stream_router
)

from app.api.digital_twin import (
    router as twin_router
)

from app.api.dashboard import (
    router as dashboard_router
)

from app.api.profile import (
    router as profile_router
)

from app.api.planner import (
    router as planner_router
)



app = FastAPI(

    title="HPAI-OS Backend",
    version="5.0.0"
)

create_tables()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Compress responses to reduce bandwidth and improve client perceived latency
app.add_middleware(GZipMiddleware, minimum_size=1000)

app.include_router(chat_router)
app.include_router(pdf_router)
app.include_router(voice_router)
app.include_router(auth_router)
app.include_router(stream_router)
app.include_router(twin_router)
app.include_router(dashboard_router)
app.include_router(planner_router)
app.include_router(profile_router)

@app.get("/")
def root():
    return {
        "message": "HPAI-OS Running 🚀"
    }