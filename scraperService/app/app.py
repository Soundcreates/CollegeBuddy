
from fastapi import FastAPI
from pydantic import BaseModel
from app.inference import classify_and_filter_emails

class TextClassificationRequest(BaseModel):
    text: list[str]

app = FastAPI()

@app.post("/text-classification")
async def classify_text(request: TextClassificationRequest):
    filtered = classify_and_filter_emails(request.text)
    return {"filtered": filtered}




