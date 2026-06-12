from app.database.db import SessionLocal

from app.models.digital_twin_model import (
    DigitalTwin
)

def create_or_update_twin(
    user_id,
    learning_style=None,
    focus_level=None,
    consistency_score=None,
    stress_level=None,
    productivity_score=None,
    weak_subjects=None,
    strong_subjects=None,
    career_goal=None,
):

    db = SessionLocal()

    twin = db.query(DigitalTwin)\
        .filter(
            DigitalTwin.user_id == user_id
        ).first()

    if not twin:

        twin = DigitalTwin(
            user_id=user_id
        )

        db.add(twin)

    if learning_style:
        twin.learning_style = learning_style

    if focus_level:
        twin.focus_level = focus_level

    if consistency_score:
        twin.consistency_score = consistency_score

    if stress_level:
        twin.stress_level = stress_level

    if productivity_score:
        twin.productivity_score = productivity_score

    if weak_subjects:
        twin.weak_subjects = weak_subjects

    if strong_subjects:
        twin.strong_subjects = strong_subjects

    if career_goal:
        twin.career_goal = career_goal

    db.commit()

    return twin