"""
pipeline.py
Orchestrates the full RAG pipeline:
  1. Load document (PDF / text)
  2. Chunk into segments
  3. Embed and retrieve relevant chunks
  4. Generate structured content via LLM
"""

import logging
from app.rag.document_loader import load_document
from app.rag.chunker import chunk_by_sections
from app.rag.retriever import build_context
from app.rag.generator import generate_content, extract_and_answer_questions

logger = logging.getLogger(__name__)


def run_rag_pipeline(
    title: str = "",
    description: str = "",
    file_content_base64: str = "",
    file_content_type: str = "",
) -> dict:
    """
    Execute the full RAG pipeline for an assignment.
    
    Steps:
    1. Load and extract text from all provided sources
    2. Chunk the text into meaningful segments
    3. Build retrieval context from the most relevant chunks
    4. Generate structured content using the LLM
    
    Args:
        title: Assignment title
        description: Assignment description text
        file_content_base64: Base64-encoded file (usually PDF)
        file_content_type: MIME type of the file
        
    Returns:
        Dict with generated content sections
    """
    logger.info(f"Starting RAG pipeline for: {title}")

    # Step 1: Load document
    full_text = load_document(
        title=title,
        description=description,
        file_content_base64=file_content_base64,
        file_content_type=file_content_type,
    )

    if not full_text.strip():
        logger.warning("No document content available, generating from title only")
        # Even without document content, we can generate from title/description
        result = generate_content(
            context="",
            title=title,
            description=description,
        )
        return result

    # Step 2: Chunk the document
    chunks = chunk_by_sections(full_text)
    logger.info(f"Document chunked into {len(chunks)} pieces")

    # Step 3: Build retrieval context
    # The query is derived from the assignment title and description
    query = f"{title}. {description}" if description else title
    if not query.strip():
        query = "What content does this assignment template require?"

    context = build_context(chunks, query)
    logger.info(f"Built context: {len(context)} characters from {len(chunks)} chunks")

    # Step 4: Generate content
    result = generate_content(
        context=context,
        title=title,
        description=description,
    )

    logger.info(f"Pipeline completed. Success: {result.get('success', False)}")
    return result


def extract_questions_and_answers(
    title: str = "",
    description: str = "",
    file_content_base64: str = "",
    file_content_type: str = "",
) -> dict:
    """
    Extract questions from an assignment and generate answers.
    
    Steps:
    1. Load and extract text from all provided sources
    2. Chunk the text into meaningful segments
    3. Build retrieval context from the most relevant chunks
    4. Extract questions and generate answers using the LLM
    
    Args:
        title: Assignment title
        description: Assignment description text
        file_content_base64: Base64-encoded file (usually PDF)
        file_content_type: MIME type of the file
        
    Returns:
        Dict with {question: answer} pairs
    """
    logger.info(f"Starting question extraction for: {title}")

    # Step 1: Load document
    full_text = load_document(
        title=title,
        description=description,
        file_content_base64=file_content_base64,
        file_content_type=file_content_type,
    )

    if not full_text.strip():
        logger.warning("No document content available for question extraction")
        # Try to generate from title/description anyway
        result = extract_and_answer_questions(
            context="",
            title=title,
            description=description,
        )
        return result

    # Step 2: Chunk the document
    chunks = chunk_by_sections(full_text)
    logger.info(f"Document chunked into {len(chunks)} pieces")

    # Step 3: Build retrieval context
    query = f"{title}. {description}" if description else title
    if not query.strip():
        query = "What are the questions in this assignment?"

    context = build_context(chunks, query, max_context_length=6000)
    logger.info(f"Built context: {len(context)} characters from {len(chunks)} chunks")

    # Step 4: Extract questions and generate answers
    result = extract_and_answer_questions(
        context=context,
        title=title,
        description=description,
    )

    logger.info(f"Question extraction completed. Success: {result.get('success', False)}")
    return result

