from fastapi import APIRouter
from fastapi import Depends

from app.core.security import get_current_user
from app.utils.cache import ttl_cache

router = APIRouter()


@router.get("/profile")
@ttl_cache(ttl=3.0)
def get_profile(user=Depends(get_current_user)):

    return {
        "name": user.username,
        "learning_style": "Visual Learner",
        "focus_score": "88%",
        "career_goal": "AI Engineer"
    }
