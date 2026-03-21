import requests
import os
import time
import logging
from typing import TypedDict, cast


hf_token = os.getenv("HUGGING_TOKEN")
API_URL="https://router.huggingface.co/hf-inference/models/valhalla/distilbart-mnli-12-1"
HF_TIMEOUT_SECONDS = float(os.getenv("HF_TIMEOUT_SECONDS", "20"))
CLASSIFY_BUDGET_SECONDS = float(os.getenv("CLASSIFY_BUDGET_SECONDS", "45"))

logger = logging.getLogger(__name__)

class ZeroShotResponse(TypedDict):
    sequence: str
    labels: list[str]
    scores: list[float]

def zero_shot_classify(sequence : str, labels : list[str], read_timeout_seconds: float) -> ZeroShotResponse:
    if not hf_token:
        raise RuntimeError("HUGGING_TOKEN is not set")

    headers = {"Authorization": f"Bearer {hf_token}"}
    payload = {
        "inputs": sequence,
        "parameters": {"candidate_labels": labels}
    }
    response = requests.post(
        API_URL,
        headers=headers,
        json=payload,
        timeout=(5, read_timeout_seconds),
    )
    if response.status_code != 200:
        raise RuntimeError(f"HuggingFace API error {response.status_code}: {response.text}")

    data  = response.json()
    if isinstance(data, dict):
        if "labels" not in data or "scores" not in data:
            raise RuntimeError(f"Unexpected HuggingFace response: {data}")
        return cast(ZeroShotResponse, data)

    if isinstance(data, list) and all(isinstance(item, dict) for item in data):
        parsed_labels: list[str] = []
        parsed_scores: list[float] = []
        for item in data:
            label = item.get("label")
            score = item.get("score")
            if not isinstance(label, str) or not isinstance(score, (int, float)):
                raise RuntimeError(f"Unexpected HuggingFace response item: {item}")
            parsed_labels.append(label)
            parsed_scores.append(float(score))
        return {
            "sequence": sequence,
            "labels": parsed_labels,
            "scores": parsed_scores,
        }

    raise RuntimeError(f"Unexpected HuggingFace response: {data}")


def classify_and_filter_emails(emails,TARGET_CATEGORIES):
    logger.info("Classifying %d emails", len(emails))
    filtered = []
    started_at = time.monotonic()

    for email in emails:
        elapsed = time.monotonic() - started_at
        if elapsed >= CLASSIFY_BUDGET_SECONDS:
            logger.warning("Classification budget reached after %.2fs; returning partial results", elapsed)
            break

        remaining_budget = CLASSIFY_BUDGET_SECONDS - elapsed
        per_call_timeout = min(HF_TIMEOUT_SECONDS, max(5.0, remaining_budget))

        try:
            result = zero_shot_classify(email, TARGET_CATEGORIES, per_call_timeout)
        except requests.exceptions.Timeout:
            logger.warning("Timed out while classifying one email; skipping")
            continue
        except requests.exceptions.RequestException as e:
            logger.warning("Network error while classifying one email: %s", e)
            continue
        except RuntimeError as e:
            logger.warning("Classifier runtime error for one email: %s", e)
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
    


