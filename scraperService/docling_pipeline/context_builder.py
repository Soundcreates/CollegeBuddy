"""Build question-specific structured contexts."""

from __future__ import annotations

from typing import Any, Dict, List


def build_context(
    structured_doc: Dict[str, Any],
    question: Dict[str, Any],
    retrieved_docs: List[Dict[str, Any]] | None = None,
) -> Dict[str, Any]:
    metadata = structured_doc.get("metadata", {})
    title = metadata.get("title", "")

    q_pages = set(question.get("related_pages", []))

    theory_parts: List[str] = []
    impl_parts: List[str] = []

    for sec in structured_doc.get("sections", []):
        sid = (sec.get("id") or "").upper()
        spages = set(sec.get("pages", []))
        if not (spages & q_pages):
            continue
        if any(k in sid for k in ["THEORY", "AIM", "PRE LAB"]):
            theory_parts.append((sec.get("title", "") + "\n" + sec.get("text", "")).strip())
        if any(k in sid for k in ["IMPLEMENTATION", "ALGORITHM", "PROCEDURE"]):
            impl_parts.append((sec.get("title", "") + "\n" + sec.get("text", "")).strip())

    tables = []
    for t_idx in question.get("related_tables", []):
        if 0 <= t_idx < len(structured_doc.get("tables", [])):
            tables.append(structured_doc["tables"][t_idx])

    retrieved_context = []
    for d in (retrieved_docs or []):
        txt = (d.get("text") or "").strip()
        if txt:
            retrieved_context.append(txt[:1800])

    return {
        "title": title,
        "question": question.get("question_text", ""),
        "question_type": question.get("question_type", "conceptual"),
        "theory": "\n\n".join(theory_parts)[:8000],
        "implementation": "\n\n".join(impl_parts)[:8000],
        "tables": tables,
        "retrieved_context": "\n\n---\n\n".join(retrieved_context)[:12000],
        "metadata": {
            "pages": sorted(list(q_pages)),
            "section": question.get("section"),
            "question_id": question.get("question_id"),
        },
    }
