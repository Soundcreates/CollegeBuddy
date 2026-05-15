"""Question extraction with page locality and table linkage."""

from __future__ import annotations

from typing import Any, Dict, List
import re
import uuid

QUESTION_START_PATTERNS = [
    r"^\s*Q(?:uestion)?\s*\d+[\).:\-]?\s+",
    r"^\s*\d+[\).]\s+",
    r"^\s*(?:Explain|Discuss|Describe|Calculate|Compute|Derive|Implement|Write\s+a\s+program|Prove|Design)\b",
]


def _looks_like_question_start(line: str) -> bool:
    s = (line or "").strip()
    if not s:
        return False
    if any(re.match(p, s, flags=re.IGNORECASE) for p in QUESTION_START_PATTERNS):
        return True
    if s.endswith("?"):
        return True
    return False


def _classify_question_type(text: str, section: str = "") -> str:
    t = (text or "").lower()
    s = (section or "").lower()

    if any(k in s for k in ["theory", "background"]):
        return "theory"
    if any(k in t for k in ["algorithm", "banker", "round robin", "fcfs", "sjf", "priority scheduling"]):
        return "algorithmic"
    if any(k in t for k in ["write a program", "implement", "code", "function", "pseudo-code", "pseudocode"]):
        return "coding"
    if any(k in t for k in ["calculate", "compute", "derive", "matrix", "table", "find", "solve"]):
        return "numerical"
    if any(k in t for k in ["explain", "describe", "discuss", "compare", "differentiate"]):
        return "descriptive"
    return "conceptual"


def _attach_related_tables(q_pages: List[int], tables: List[Dict[str, Any]]) -> List[int]:
    related = []
    page_set = set(q_pages)
    for i, t in enumerate(tables):
        tp = t.get("page")
        if tp is None:
            continue
        if tp in page_set or tp in {p + 1 for p in page_set} or tp in {p - 1 for p in page_set}:
            related.append(i)
    return related


def extract_questions(structured_doc: Dict[str, Any]) -> List[Dict[str, Any]]:
    pages = structured_doc.get("pages", [])
    tables = structured_doc.get("tables", [])
    sections = structured_doc.get("sections", [])

    section_by_page: Dict[int, str] = {}
    for sec in sections:
        sid = sec.get("id") or "SECTION"
        for p in sec.get("pages", []):
            section_by_page[p] = sid

    questions: List[Dict[str, Any]] = []

    active_q = None
    for p in pages:
        page_idx = p.get("page_index")
        lines = (p.get("markdown") or "").splitlines()

        for line in lines:
            stripped = line.strip()
            if not stripped:
                continue

            if _looks_like_question_start(stripped):
                if active_q is not None:
                    active_q["question_text"] = active_q["question_text"].strip()
                    questions.append(active_q)

                active_q = {
                    "question_id": str(uuid.uuid4()),
                    "question_text": stripped,
                    "question_type": "conceptual",
                    "related_pages": [page_idx],
                    "related_tables": [],
                    "section": section_by_page.get(page_idx),
                    "context_refs": [],
                }
                continue

            if active_q is not None:
                # Continue current question until next question marker.
                active_q["question_text"] += "\n" + stripped
                if page_idx not in active_q["related_pages"]:
                    active_q["related_pages"].append(page_idx)

        # If question spills across pages and no new marker appears,
        # keep it active; it will be finalized later.

    if active_q is not None:
        active_q["question_text"] = active_q["question_text"].strip()
        questions.append(active_q)

    # Fallback: if no explicit markers found, create inferred prompts from post-lab section.
    if not questions:
        for sec in sections:
            sid = (sec.get("id") or "").upper()
            if "QUESTION" in sid or "POST LAB" in sid:
                blob = sec.get("text", "").strip()
                if blob:
                    questions.append(
                        {
                            "question_id": str(uuid.uuid4()),
                            "question_text": blob[:3000],
                            "question_type": "descriptive",
                            "related_pages": sec.get("pages", [])[:],
                            "related_tables": [],
                            "section": sid,
                            "context_refs": [],
                        }
                    )

    for q in questions:
        q["question_type"] = _classify_question_type(q.get("question_text", ""), q.get("section", ""))
        q["related_tables"] = _attach_related_tables(q.get("related_pages", []), tables)
        q["context_refs"] = [f"page:{p}" for p in q.get("related_pages", [])]

    return questions
