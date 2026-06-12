from fastapi import APIRouter
from fastapi import Depends

from app.core.security import get_current_user
from app.utils.cache import ttl_cache

router = APIRouter()


@router.get("/dashboard")
@ttl_cache(ttl=3.0)
def get_dashboard(user=Depends(get_current_user)):

    return {
        "study_streak": 12,
        "focus_hours": 4.5,
        "tasks_completed": 18,
        "progress_score": 87
    }
