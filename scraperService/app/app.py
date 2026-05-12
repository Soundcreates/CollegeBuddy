import logging
from typing import Any

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException

from app.email_filter_service import EmailFilterService
from app.inference import TARGET_CATEGORIES
from app.model import classify_and_filter_emails
from app.schemas import (
    BatchEmailFilterRequest,
    BatchEmailFilterResponse,
    TextClassificationRequest,
)

load_dotenv()
logging.basicConfig(level=logging.INFO)

app = FastAPI(title="CollegeBuddy Email Filter", version="1.0.0")
logger = logging.getLogger(__name__)

# Mount RAG pipeline router
from app.rag.router import router as rag_router

app.include_router(rag_router)


@app.post("/text-classification")
async def classify_text(request: TextClassificationRequest):
    logger.info(
        "Received request for text classification with %d items", len(request.text)
    )
    try:
        filtered_mails: Any = classify_and_filter_emails(
            request.text, TARGET_CATEGORIES
        )
        if filtered_mails is None:
            filtered_mails = []

        return {"filtered": filtered_mails}

    except Exception as e:
        logger.exception("Error during classification")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/filter-emails", response_model=BatchEmailFilterResponse)
async def filter_emails_batch(
    request: BatchEmailFilterRequest,
) -> BatchEmailFilterResponse:
    """
    Filter a batch of emails for a specific day using AI classification.

    Returns organized filtered emails by category for mobile display.

    Args:
        request: BatchEmailFilterRequest with list of emails and optional date

    Returns:
        BatchEmailFilterResponse with emails organized by category
    """
    logger.info(
        "Received email filter request for %d emails (date: %s)",
        len(request.emails),
        request.date,
    )

    try:
        if not request.emails:
            logger.warning("Empty email list received")
            return BatchEmailFilterResponse(
                success=True,
                date=request.date,
                total_emails=0,
                filtered_count=0,
                by_category={},
                all_filtered=[],
            )

        # Use the email filter service for batch processing
        result = EmailFilterService.filter_emails_batch(request.emails)
        result.date = request.date

        logger.info(
            "Email filtering completed: %d/%d emails retained",
            result.filtered_count,
            result.total_emails,
        )

        return result

    except Exception as e:
        logger.exception("Error during email filtering")
        raise HTTPException(status_code=500, detail=f"Error filtering emails: {str(e)}")


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}
