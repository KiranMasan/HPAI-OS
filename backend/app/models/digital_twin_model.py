from sqlalchemy import Column
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy import Float
from sqlalchemy import Text

from app.database.db import Base

class DigitalTwin(Base):

    __tablename__ = "digital_twins"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    user_id = Column(Integer)

    learning_style = Column(String)

    focus_level = Column(Float)

    consistency_score = Column(Float)

    stress_level = Column(Float)

    productivity_score = Column(Float)

    weak_subjects = Column(Text)

    strong_subjects = Column(Text)

    career_goal = Column(String)

    personality_type = Column(String)