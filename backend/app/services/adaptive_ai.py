def generate_adaptive_prompt(
    twin
):

    prompt = f"""

    User Profile:

    Learning Style:
    {twin.learning_style}

    Productivity:
    {twin.productivity_score}

    Stress Level:
    {twin.stress_level}

    Weak Subjects:
    {twin.weak_subjects}

    Career Goal:
    {twin.career_goal}

    Adapt teaching style accordingly.
    """

    return prompt