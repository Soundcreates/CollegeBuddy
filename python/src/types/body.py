from pydantic import BaseModel


class filterBody(BaseModel):
    id: str
    threadId: str
    subject: str
    sender: str
    to: str
    date: str
