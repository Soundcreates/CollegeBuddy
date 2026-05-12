"""
router.py
FastAPI router for the RAG pipeline endpoints.
Mounted under /rag in the main application.
"""

import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

from app.rag.pipeline import run_rag_pipeline, extract_questions_and_answers

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/rag", tags=["RAG Pipeline"])


class AnalyzeRequest(BaseModel):
    title: str = ""
    description: str = ""
    file_url: Optional[str] = ""
    file_content_base64: Optional[str] = ""
    file_content_type: Optional[str] = ""


class SectionResponse(BaseModel):
    header: str
    points: list[str]


class AnalyzeResponse(BaseModel):
    success: bool
    raw_markdown: str = ""
    sections: list[dict] = []
    error: str = ""


class AssignmentHelpResponse(BaseModel):
    success: bool
    questions_answers: dict = {}  # {question: answer}
    error: str = ""


@router.post("/analyze", response_model=AnalyzeResponse)
async def analyze_assignment(request: AnalyzeRequest) -> AnalyzeResponse:
    """
    Analyze an assignment template and generate structured content suggestions.
    
    Accepts:
    - title: Assignment title
    - description: Assignment description
    - file_content_base64: Base64-encoded PDF content (sent by Go backend)
    - file_content_type: MIME type of the file
    
    Returns:
    - Structured sections with headers and bullet points
    """
    logger.info(f"RAG analyze request: title='{request.title}'")

    if not request.title and not request.description and not request.file_content_base64:
        raise HTTPException(
            status_code=400,
            detail="At least one of title, description, or file_content_base64 is required",
        )

    try:
        result = run_rag_pipeline(
            title=request.title,
            description=request.description,
            file_content_base64=request.file_content_base64 or "",
            file_content_type=request.file_content_type or "",
        )

        return AnalyzeResponse(
            success=result.get("success", False),
            raw_markdown=result.get("raw_markdown", ""),
            sections=result.get("sections", []),
            error=result.get("error", ""),
        )

    except Exception as e:
        logger.exception("RAG pipeline error")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/assignment-help", response_model=AssignmentHelpResponse)
async def get_assignment_help(request: AnalyzeRequest) -> AssignmentHelpResponse:
    """
    Extract questions from an assignment and generate answers.
    
    This endpoint specifically handles:
    1. Extracting questions from the assignment content
    2. Generating detailed answers based on the assignment context
    3. Returning a dictionary of {question: answer} pairs
    
    Accepts:
    - title: Assignment title
    - description: Assignment description
    - file_content_base64: Base64-encoded PDF content
    - file_content_type: MIME type of the file
    
    Returns:
    - Dictionary mapping questions to answers
    """
    logger.info(f"Assignment help request: title='{request.title}'")

    if not request.title and not request.description and not request.file_content_base64:
        raise HTTPException(
            status_code=400,
            detail="At least one of title, description, or file_content_base64 is required",
        )

    try:
        result = extract_questions_and_answers(
            title=request.title,
            description=request.description,
            file_content_base64=request.file_content_base64 or "",
            file_content_type=request.file_content_type or "",
        )

        return AssignmentHelpResponse(
            success=result.get("success", False),
            questions_answers=result.get("questions_answers", {}),
            error=result.get("error", ""),
        )

    except Exception as e:
        logger.exception("Assignment help error")
        raise HTTPException(status_code=500, detail=str(e))

