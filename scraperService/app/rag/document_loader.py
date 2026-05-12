"""
document_loader.py
Handles loading and extracting text content from assignment PDFs or raw text.
Supports both base64-encoded file content and plain text descriptions.
"""

import base64
import io
import logging

from PyPDF2 import PdfReader

logger = logging.getLogger(__name__)


def extract_text_from_pdf_bytes(pdf_bytes: bytes) -> str:
    """Extract text from a PDF file given as raw bytes."""
    try:
        reader = PdfReader(io.BytesIO(pdf_bytes))
        text_parts = []
        for page in reader.pages:
            page_text = page.extract_text()
            if page_text:
                text_parts.append(page_text.strip())
        return "\n\n".join(text_parts)
    except Exception as e:
        logger.error(f"Failed to extract text from PDF: {e}")
        return ""


def load_document(
    title: str = "",
    description: str = "",
    file_content_base64: str = "",
    file_content_type: str = "",
) -> str:
    """
    Load and combine all available document content into a single text string.

    Priority:
    1. PDF file content (decoded from base64)
    2. Title + description text
    """
    parts = []

    # Add title context
    if title:
        parts.append(f"Assignment Title: {title}")

    # Add description context
    if description:
        parts.append(f"Assignment Description:\n{description}")

    # Decode and extract file content if provided
    if file_content_base64:
        try:
            file_bytes = base64.b64decode(file_content_base64)

            if file_content_type and "pdf" in file_content_type.lower():
                pdf_text = extract_text_from_pdf_bytes(file_bytes)
                if pdf_text:
                    parts.append(f"Document Content:\n{pdf_text}")
                else:
                    logger.warning("PDF extraction returned empty text")
            else:
                # Try to decode as plain text
                try:
                    text = file_bytes.decode("utf-8")
                    parts.append(f"Document Content:\n{text}")
                except UnicodeDecodeError:
                    # Might still be a PDF without proper content type
                    pdf_text = extract_text_from_pdf_bytes(file_bytes)
                    if pdf_text:
                        parts.append(f"Document Content:\n{pdf_text}")
        except Exception as e:
            logger.error(f"Failed to decode file content: {e}")

    full_text = "\n\n".join(parts)
    logger.info(f"Document loaded: {len(full_text)} characters")
    return full_text


def parse_topic(file_content_base64: str):
    print("Parsing topic from base64 content...")
    if "base64," in file_content_base64:
        file_content_base64 = file_content_base64.split("base64,")[1]

    pdfbytes = base64.b64decode(file_content_base64)
    reader = PdfReader(io.BytesIO(pdfbytes))

    text = []
    for page in reader.pages:
        text.append(page.extract_text() or "")

    return "\n".join(text)
