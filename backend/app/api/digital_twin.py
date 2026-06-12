from fastapi import APIRouter

from app.services.memory_engine import (
    create_or_update_twin
)
from app.utils.cache import invalidate_functions

router = APIRouter()

@router.post("/update-twin")
def update_twin():

    twin = create_or_update_twin(

        user_id=1,

        learning_style="Visual Learner",

        focus_level=8.2,

        consistency_score=84,

        stress_level=0.3,

        productivity_score=91,

        weak_subjects="DSA",

        strong_subjects="AI",

        career_goal="AI Engineer"
    )

    return {
        "message":
            "Digital Twin Updated",
    }
    # Invalidate related cached GET endpoints (profile, dashboard)
    try:
        invalidate_functions(["get_profile", "get_dashboard"])
    except Exception:
        pass