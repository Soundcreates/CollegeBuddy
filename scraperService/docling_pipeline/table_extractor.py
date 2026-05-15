"""Table extractor preserving structure and page locality."""

from __future__ import annotations

from typing import Any, Dict, List
import re


def _parse_markdown_table_block(block: str) -> Dict[str, Any] | None:
    lines = [l.strip() for l in block.splitlines() if l.strip()]
    if len(lines) < 2:
        return None
    if "|" not in lines[0] or "|" not in lines[1]:
        return None

    headers = [h.strip() for h in lines[0].strip("|").split("|")]
    rows = []
    for row in lines[2:]:
        if "|" not in row:
            continue
        rows.append([c.strip() for c in row.strip("|").split("|")])
    if not headers:
        return None
    return {"headers": headers, "rows": rows}


def extract_tables_from_doc(parsed_doc: Dict[str, Any], structured_doc: Dict[str, Any] | None = None) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    doc = parsed_doc.get("doc")

    # Prefer native docling tables when available.
    if doc is not None and hasattr(doc, "tables"):
        try:
            for t in doc.tables:
                headers = list(getattr(t, "headers", []) or [])
                rows = list(getattr(t, "rows", []) or [])
                page = int(getattr(t, "page", 0) or 0)
                out.append({"headers": headers, "rows": rows, "page": page if page > 0 else None})
            if out:
                return out
        except Exception:
            pass

    pages = (structured_doc or {}).get("pages") or []
    if not pages:
        pages_md = parsed_doc.get("pages_markdown", []) or []
        pages = [{"page_index": i + 1, "markdown": md or ""} for i, md in enumerate(pages_md)]

    for p in pages:
        page_idx = p.get("page_index")
        md = p.get("markdown", "")
        blocks = re.split(r"\n\s*\n", md)
        for blk in blocks:
            if "|" not in blk:
                continue
            parsed = _parse_markdown_table_block(blk)
            if parsed:
                out.append({
                    "headers": parsed["headers"],
                    "rows": parsed["rows"],
                    "page": page_idx,
                })

    return out
