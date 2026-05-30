"""
embedder.py
Creates embeddings for text chunks using sentence-transformers.
Uses a lightweight model suitable for semantic similarity.
"""

import logging
from typing import List
import numpy as np

logger = logging.getLogger(__name__)

_model = None


def get_model():
    """Lazy-load the sentence-transformer model."""
    global _model
    if _model is None:
        from sentence_transformers import SentenceTransformer
        logger.info("Loading sentence-transformer model...")
        _model = SentenceTransformer("all-MiniLM-L6-v2")
        logger.info("Model loaded successfully")
    return _model


def embed_texts(texts: List[str]) -> np.ndarray:
    """
    Generate embeddings for a list of text chunks.
    
    Returns:
        numpy array of shape (n_texts, embedding_dim)
    """
    if not texts:
        return np.array([])

    model = get_model()
    embeddings = model.encode(texts, show_progress_bar=False, normalize_embeddings=True)
    logger.info(f"Generated embeddings for {len(texts)} chunks, dim={embeddings.shape[1]}")
    return embeddings


def embed_query(query: str) -> np.ndarray:
    """Generate embedding for a single query string."""
    model = get_model()
    embedding = model.encode([query], show_progress_bar=False, normalize_embeddings=True)
    return embedding[0]
