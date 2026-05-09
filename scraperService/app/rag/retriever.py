"""
retriever.py
Retrieves the most relevant chunks for a given query using cosine similarity.
Implements a simple in-memory vector store (no external DB needed).
"""

import logging
from typing import List, Tuple
import numpy as np

from app.rag.embedder import embed_texts, embed_query

logger = logging.getLogger(__name__)


def retrieve_relevant_chunks(
    chunks: List[str],
    query: str,
    top_k: int = 5,
) -> List[Tuple[str, float]]:
    """
    Retrieve the top-k most relevant chunks for a query.
    
    Args:
        chunks: List of text chunks
        query: The query string (auto-generated from assignment context)
        top_k: Number of chunks to return
        
    Returns:
        List of (chunk_text, similarity_score) tuples, sorted by relevance
    """
    if not chunks:
        return []

    # Embed all chunks
    chunk_embeddings = embed_texts(chunks)
    
    # Embed the query
    query_embedding = embed_query(query)

    # Compute cosine similarity (embeddings are already normalized)
    similarities = np.dot(chunk_embeddings, query_embedding)

    # Get top-k indices
    top_indices = np.argsort(similarities)[::-1][:top_k]

    results = []
    for idx in top_indices:
        score = float(similarities[idx])
        if score > 0.1:  # Minimum relevance threshold
            results.append((chunks[idx], score))

    logger.info(f"Retrieved {len(results)} relevant chunks (top_k={top_k})")
    return results


def build_context(chunks: List[str], query: str, max_context_length: int = 3000) -> str:
    """
    Build a context string from the most relevant chunks.
    Truncates if the combined text exceeds max_context_length.
    """
    relevant = retrieve_relevant_chunks(chunks, query, top_k=8)
    
    context_parts = []
    current_length = 0
    
    for chunk_text, score in relevant:
        if current_length + len(chunk_text) > max_context_length:
            break
        context_parts.append(chunk_text)
        current_length += len(chunk_text)

    return "\n\n---\n\n".join(context_parts)
