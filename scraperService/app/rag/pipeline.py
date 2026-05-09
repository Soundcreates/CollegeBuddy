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
from app.rag.generator import generate_content

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
