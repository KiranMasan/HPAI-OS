def analyze_user_behavior(
    study_hours,
    completed_tasks,
    stress_signals,
):

    productivity_score = (
        study_hours * 10
    ) + (
        completed_tasks * 5
    )

    if stress_signals > 5:
        stress_level = 0.8
    else:
        stress_level = 0.3

    consistency_score = min(
        productivity_score / 10,
        100
    )

    return {
        "productivity_score":
            productivity_score,

        "stress_level":
            stress_level,

        "consistency_score":
            consistency_score,
    }