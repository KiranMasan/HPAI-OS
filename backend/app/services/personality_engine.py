def determine_learning_style(
    user_behavior
):

    if user_behavior["focus_level"] > 7:
        return "Deep Focus Learner"

    elif user_behavior["stress_level"] > 0.7:
        return "Needs Motivational Guidance"

    else:
        return "Balanced Learner"