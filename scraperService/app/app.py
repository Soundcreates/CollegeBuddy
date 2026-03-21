from typing import Any
from fastapi import FastAPI, HTTPException
from app.schemas import TextClassificationRequest
from app.model import classify_and_filter_emails 
from dotenv import load_dotenv
from app.inference import TARGET_CATEGORIES
import logging


load_dotenv()
logging.basicConfig(level=logging.INFO)

app = FastAPI()
logger = logging.getLogger(__name__)

@app.post("/text-classification")
async def classify_text(request: TextClassificationRequest):
    logger.info("Received request for text classification with %d items", len(request.text))
    try:
        filtered_mails: Any = classify_and_filter_emails(request.text, TARGET_CATEGORIES)
        if filtered_mails is None:
            filtered_mails = []

        return {"filtered": filtered_mails}


    except Exception as e: 
            logger.exception("Error during classification")
            raise HTTPException(status_code=500, detail=str(e))
    



