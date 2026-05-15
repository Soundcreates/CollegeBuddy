"""Groq answer generator with question-type-aware prompting."""

from __future__ import annotations

from typing import Any, Dict
import json
import logging
import os

from groq import Groq

logger = logging.getLogger(__name__)

_client = None


def _get_client() -> Groq:
    global _client
    if _client is None:
        api_key = os.getenv("GROQ_API_KEY")
        if not api_key:
            raise ValueError("GROQ_API_KEY environment variable is required")
        _client = Groq(api_key=api_key)
    return _client


def _instruction_for_type(question_type: str) -> str:
    qt = (question_type or "conceptual").lower()
    if qt == "numerical":
        return "Show all calculations step-by-step. If data is missing, explicitly state assumptions needed."
    if qt == "algorithmic":
        return "Solve algorithmically step-by-step and present intermediate states clearly."
    if qt == "coding":
        return "Provide concise, correct code or pseudocode exactly matching the ask."
    if qt == "descriptive":
        return "Give a structured explanatory answer with clear points and brief rationale."
    if qt == "theory":
        return "Answer with core theory definitions/principles tied to the prompt."
    return "Answer precisely and only what is asked."


def build_prompt(context: Dict[str, Any]) -> str:
    return f"""
You are solving a university assignment question.

Assignment Title:
{context.get('title', '')}

Question Type:
{context.get('question_type', 'conceptual')}

Relevant Theory:
{context.get('theory', '')}

Implementation Details:
{context.get('implementation', '')}

Retrieved Context:
{context.get('retrieved_context', '')}

Question:
{context.get('question', '')}

Related Tables (JSON):
{json.dumps(context.get('tables', []), ensure_ascii=False)}

Instructions:
- {_instruction_for_type(context.get('question_type', 'conceptual'))}
- Use table values exactly when present.
- Do not hallucinate missing data.
- Keep answer focused on this question only.
""".strip()


def generate_answer(context: Dict[str, Any], model: str = "llama-3.3-70b-versatile") -> Dict[str, Any]:
    prompt = build_prompt(context)
    try:
        client = _get_client()
        completion = client.chat.completions.create(
            model=model,
            messages=[
                {
                    "role": "system",
                    "content": "You are a precise academic problem-solving assistant. Keep answers exact and grounded in provided context.",
                },
                {"role": "user", "content": prompt},
            ],
            temperature=0.2,
            max_tokens=1600,
        )
        answer = completion.choices[0].message.content.strip()
        return {
            "answer": answer,
            "prompt": prompt,
            "model": model,
        }
    except Exception as e:
        logger.exception("Groq generation failed in docling pipeline")
        return {
            "answer": "",
            "prompt": prompt,
            "error": str(e),
            "model": model,
        }
