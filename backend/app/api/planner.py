from fastapi import APIRouter
from pydantic import BaseModel

from app.agents.router import route_agent
from app.utils.cache import invalidate_functions

router = APIRouter()

class PlannerRequest(BaseModel):

    goal: str
    level: str
    hours: str
    target: str


@router.post("/generate-plan")
def generate_plan(request: PlannerRequest):

    prompt = f"""
You are HPAI-OS Planner Agent.

Create a personalized roadmap and daily tasks.

Goal: {request.goal}
Current Level: {request.level}
Daily Study Time: {request.hours}
Target Timeline: {request.target}

Return ONLY in this format:

ROADMAP:
1.
2.
3.
4.
5.
6.

TASKS:
1.
2.
3.
4.

RECOMMENDATION:
One recommendation.
"""

    response = route_agent(prompt)

    # Plan generated — invalidate profile/dashboard caches so clients see updated data
    try:
        invalidate_functions(["get_profile", "get_dashboard"])
    except Exception:
        pass

    return {
        "plan": response
    }