"""Build structured document representation from Docling output."""

from __future__ import annotations

from typing import Any, Dict, List
import logging
import re

logger = logging.getLogger(__name__)

SECTION_MATCHERS = [
    ("TITLE", [r"^title\b", r"^experiment\b", r"^assignment\b"]),
    ("AIM", [r"^aim\b", r"^objective\b"]),
    ("THEORY", [r"^theory\b", r"^background\b", r"^concept\b"]),
    ("PRE LAB", [r"^pre\s*-?\s*lab\b"]),
    ("IMPLEMENTATION", [r"^implementation\b", r"^procedure\b", r"^algorithm\b"]),
    ("CONCLUSION", [r"^conclusion\b", r"^result\b"]),
    ("POST LAB QUESTIONS", [r"^post\s*-?\s*lab\b", r"^questions?\b", r"^viva\b"]),
]


def _detect_heading(line: str) -> bool:
    s = (line or "").strip()
    if not s:
        return False
    if s.startswith("#"):
        return True
    if re.match(r"^[A-Z][A-Z\s\-/]{2,}$", s):
        return True
    if re.match(r"^(\d+(?:\.\d+)*)\s+[A-Za-z]", s):
        return True
    if s.endswith(":") and len(s.split()) <= 8:
        return True
    for _, pats in SECTION_MATCHERS:
        if any(re.match(p, s, flags=re.IGNORECASE) for p in pats):
            return True
    return False


def _section_id_from_heading(heading: str) -> str:
    h = (heading or "").strip().strip("#").strip()
    for sid, patterns in SECTION_MATCHERS:
        if any(re.match(p, h, flags=re.IGNORECASE) for p in patterns):
            return sid
    return "SECTION"


def structure_document(parsed_doc: Dict[str, Any], title: str = "", description: str = "") -> Dict[str, Any]:
    pages_md = parsed_doc.get("pages_markdown", []) or []

    pages: List[Dict[str, Any]] = []
    sections: List[Dict[str, Any]] = []

    current = None
    for idx, md in enumerate(pages_md, start=1):
        lines = [ln.rstrip() for ln in (md or "").splitlines()]
        page_headings = [ln.strip() for ln in lines if _detect_heading(ln)]
        pages.append(
            {
                "page_index": idx,
                "markdown": md or "",
                "headings": page_headings,
                "semantic_blocks": [{"kind": "text", "line": i + 1, "text": ln} for i, ln in enumerate(lines) if ln.strip()],
            }
        )

        for ln in lines:
            if _detect_heading(ln):
                if current is not None:
                    sections.append(current)
                hid = _section_id_from_heading(ln)
                current = {
                    "id": hid,
                    "title": ln.strip().strip("#").strip(),
                    "pages": [idx],
                    "text": "",
                    "children": [],
                }
                continue

            if current is None:
                current = {
                    "id": "PREFACE",
                    "title": "PREFACE",
                    "pages": [idx],
                    "text": "",
                    "children": [],
                }

            current["text"] += (ln + "\n")
            if idx not in current["pages"]:
                current["pages"].append(idx)

    if current is not None:
        sections.append(current)

    metadata = dict(parsed_doc.get("metadata", {}) or {})
    metadata.update(
        {
            "title": title or metadata.get("title") or "",
            "description": description or "",
            "page_count": len(pages),
            "section_count": len(sections),
        }
    )

    return {
        "pages": pages,
        "sections": sections,
        "tables": [],
        "questions": [],
        "metadata": metadata,
    }
