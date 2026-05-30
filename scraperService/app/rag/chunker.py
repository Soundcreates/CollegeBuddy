"""
chunker.py
Splits large documents into smaller, semantically meaningful chunks
for embedding and retrieval.
"""

import re
import logging
from typing import List

logger = logging.getLogger(__name__)

DEFAULT_CHUNK_SIZE = 500
DEFAULT_OVERLAP = 50


def chunk_by_sections(text: str) -> List[str]:
    """
    Split text into chunks based on natural section boundaries.
    Falls back to fixed-size chunking if no clear sections are found.
    """
    if not text.strip():
        return []

    # Try splitting by common section patterns
    section_pattern = r'\n(?=(?:[A-Z][A-Z\s]{2,}:|\d+\.\s|#{1,3}\s|[A-Z][a-z]+:))'
    sections = re.split(section_pattern, text)
    
    # Filter out empty sections
    sections = [s.strip() for s in sections if s.strip()]

    if len(sections) <= 1:
        # Fall back to paragraph-based chunking
        return chunk_by_paragraphs(text)

    # Merge very small sections with their neighbors
    merged = []
    buffer = ""
    for section in sections:
        if len(buffer) + len(section) < DEFAULT_CHUNK_SIZE:
            buffer += "\n\n" + section if buffer else section
        else:
            if buffer:
                merged.append(buffer.strip())
            buffer = section
    if buffer:
        merged.append(buffer.strip())

    logger.info(f"Chunked document into {len(merged)} sections")
    return merged


def chunk_by_paragraphs(text: str) -> List[str]:
    """Split text by paragraph breaks, merging small paragraphs."""
    paragraphs = re.split(r'\n\s*\n', text)
    paragraphs = [p.strip() for p in paragraphs if p.strip()]

    if not paragraphs:
        return chunk_fixed_size(text)

    chunks = []
    buffer = ""
    for para in paragraphs:
        if len(buffer) + len(para) < DEFAULT_CHUNK_SIZE:
            buffer += "\n\n" + para if buffer else para
        else:
            if buffer:
                chunks.append(buffer.strip())
            buffer = para
    if buffer:
        chunks.append(buffer.strip())

    logger.info(f"Chunked document into {len(chunks)} paragraph groups")
    return chunks


def chunk_fixed_size(
    text: str,
    chunk_size: int = DEFAULT_CHUNK_SIZE,
    overlap: int = DEFAULT_OVERLAP,
) -> List[str]:
    """Fixed-size character chunking with overlap."""
    if not text.strip():
        return []

    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunk = text[start:end].strip()
        if chunk:
            chunks.append(chunk)
        start += chunk_size - overlap

    logger.info(f"Fixed-size chunked into {len(chunks)} chunks")
    return chunks
