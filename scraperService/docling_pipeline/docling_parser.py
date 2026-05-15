"""Docling parser wrapper with OCR fallback."""

from __future__ import annotations

from typing import Any, Dict, List
import logging

logger = logging.getLogger(__name__)

try:
    from docling.document_converter import DocumentConverter
except Exception:  # pragma: no cover
    DocumentConverter = None


def _export_pages_markdown(doc: Any) -> List[str]:
    pages: List[str] = []
    if hasattr(doc, "export_to_markdown"):
        md = doc.export_to_markdown() or ""
        if "<PAGE>" in md:
            pages = [p.strip() for p in md.split("<PAGE>")]
        else:
            pages = [md]
    elif hasattr(doc, "pages"):
        for p in doc.pages:
            if hasattr(p, "export_to_markdown"):
                pages.append((p.export_to_markdown() or "").strip())
            else:
                pages.append((getattr(p, "text", "") or "").strip())
    return [p for p in pages if p is not None]


def _convert(converter: Any, source: str, force_ocr: bool = False):
    if force_ocr:
        try:
            return converter.convert(source, pipeline="ocr")
        except TypeError:
            return converter.convert(source, pipeline_options={"force_ocr": True})
    return converter.convert(source)


def parse_document(source: str, force_ocr: bool = False) -> Dict[str, Any]:
    if DocumentConverter is None:
        raise RuntimeError("docling is not installed; install with pip install docling")

    converter = DocumentConverter()
    conv = _convert(converter, source, force_ocr=False)
    doc = getattr(conv, "document", conv)
    pages_markdown = _export_pages_markdown(doc)

    short_pages = len(pages_markdown) == 0 or all((not p or len(p.strip()) < 80) for p in pages_markdown)
    if short_pages or force_ocr:
        logger.info("Docling parse low-text detected; retrying with OCR mode")
        try:
            conv2 = _convert(converter, source, force_ocr=True)
            doc2 = getattr(conv2, "document", conv2)
            pages2 = _export_pages_markdown(doc2)
            if any(len((p or "").strip()) > len((q or "").strip()) for p, q in zip(pages2 + [""], pages_markdown + [""])):
                doc = doc2
                pages_markdown = pages2
        except Exception:
            logger.exception("OCR fallback failed; using initial docling output")

    return {
        "doc": doc,
        "pages_markdown": pages_markdown,
        "raw": getattr(doc, "to_dict", lambda: None)(),
        "metadata": getattr(doc, "metadata", {}) or {},
    }
