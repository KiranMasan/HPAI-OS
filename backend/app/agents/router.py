from app.agents.tutor_agent import tutor_agent
from app.agents.planner_agent import planner_agent
from app.agents.career_agent import career_agent
from app.agents.motivation_agent import motivation_agent

def route_agent(message: str):

    lower_message = message.lower()

    # Tutor Agent
    if any(word in lower_message for word in [
        "explain",
        "teach",
        "what is",
        "learn",
        "study"
    ]):
        return tutor_agent(message)

    # Planner Agent
    elif any(word in lower_message for word in [
        "plan",
        "schedule",
        "routine",
        "timetable"
    ]):
        return planner_agent(message)

    # Career Agent
    elif any(word in lower_message for word in [
        "career",
        "placement",
        "job",
        "resume",
        "interview"
    ]):
        return career_agent(message)

    # Motivation Agent
    elif any(word in lower_message for word in [
        "stress",
        "motivate",
        "sad",
        "depressed",
        "focus"
    ]):
        return motivation_agent(message)

    # Default
    return tutor_agent(message)