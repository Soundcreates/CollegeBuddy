from pydantic import BaseModel

class TextClassificationRequest(BaseModel):
    text: list[str]


