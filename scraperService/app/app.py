
from fastapi import FastAPI
from pydantic import BaseModel
from app.inference import classify_and_filter_emails
from dotenv import load_dotenv
import os

load_dotenv()
hf_token = os.getenv("HF_TOKEN")
class TextClassificationRequest(BaseModel):
    text: list[str]

app = FastAPI()

@app.post("/text-classification")
async def classify_text(request: TextClassificationRequest):
    filtered = classify_and_filter_emails(request.text)
    return {"filtered": filtered}




