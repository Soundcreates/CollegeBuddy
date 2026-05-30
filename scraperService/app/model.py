import os
import time
import logging
from typing import TypedDict, cast
from sentence_transformers import SentenceTransformer, util

logger = logging.getLogger(__name__)

CLASSIFY_BUDGET_SECONDS = float(os.getenv("CLASSIFY_BUDGET_SECONDS", "45"))
MODEL_NAME = "all-MiniLM-L6-v2"

# Global model instance (cached after first load)
_model_instance = None

class SimilarityResponse(TypedDict):
    sequence: str
    labels: list[str]
    scores: list[float]

def get_model():
    """Get or initialize the sentence transformer model"""
    global _model_instance
    if _model_instance is None:
        logger.info(f"Loading sentence transformer model: {MODEL_NAME}")
        _model_instance = SentenceTransformer(MODEL_NAME)
        # Move to CPU for better compatibility
        _model_instance.to("cpu")
        logger.info("Model loaded successfully")
    return _model_instance

def semantic_classify(sequence: str, labels: list[str]) -> SimilarityResponse:
    """
    Classify text using semantic similarity with sentence transformers.
    
    Args:
        sequence: Email text to classify (subject + body)
        labels: List of category labels to compare against
        
    Returns:
        SimilarityResponse with ranked labels and similarity scores
    """
    if not sequence or not labels:
        raise ValueError("sequence and labels must not be empty")
    
    model = get_model()
    
    # Encode email and labels
    email_embedding = model.encode(sequence, convert_to_tensor=True)
    label_embeddings = model.encode(labels, convert_to_tensor=True)
    
    # Calculate cosine similarities
    similarities = util.pytorch_cos_sim(email_embedding, label_embeddings)[0]
    
    # Convert to list and sort by similarity (highest first)
    scores_list = similarities.cpu().numpy().tolist()
    sorted_pairs = sorted(enumerate(scores_list), key=lambda x: x[1], reverse=True)
    
    # Extract sorted labels and scores
    sorted_indices = [i for i, _ in sorted_pairs]
    sorted_labels = [labels[i] for i in sorted_indices]
    sorted_scores = [score for _, score in sorted_pairs]
    
    return {
        "sequence": sequence,
        "labels": sorted_labels,
        "scores": sorted_scores,
    }

def classify_and_filter_emails(emails, TARGET_CATEGORIES):
    """Legacy function for backward compatibility"""
    logger.info("Classifying %d emails with sentence transformers", len(emails))
    filtered = []
    started_at = time.monotonic()

    for email in emails:
        elapsed = time.monotonic() - started_at
        if elapsed >= CLASSIFY_BUDGET_SECONDS:
            logger.warning("Classification budget reached after %.2fs; returning partial results", elapsed)
            break

        try:
            result = semantic_classify(email, TARGET_CATEGORIES)
        except Exception as e:
            logger.warning("Classifier error for one email: %s", e)
            continue
        
        if not result["labels"] or not result["scores"]:
            continue

        top_label = result['labels'][0]
        confidence = result['scores'][0]
        if top_label in TARGET_CATEGORIES:
            filtered.append({
                "text": email,
                "label": top_label,
                "confidence": confidence
            })

    logger.info("Filtered %d/%d emails", len(filtered), len(emails))
    return filtered
    


