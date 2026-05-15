"""Docling-based structured academic document intelligence pipeline."""

from __future__ import annotations

from typing import Any, Dict
import logging

from .document_loader import load_document_source, cleanup_source
from .docling_parser import parse_document
from .document_structurer import structure_document
from .table_extractor import extract_tables_from_doc
from .question_extractor import extract_questions
from .retrieval_engine import build_retrieval_docs, HybridIndex
from .context_builder import build_context
from .answer_generator import generate_answer

logger = logging.getLogger(__name__)


def run_assignment_pipeline(
    title: str = "",
    description: str = "",
    file_url: str = "",
    file_access_token: str = "",
    file_content_base64: str = "",
    file_content_type: str = "",
) -> Dict[str, Any]:
    source = load_document_source(
        title=title,
        description=description,
        file_url=file_url,
        file_access_token=file_access_token,
        file_content_base64=file_content_base64,
        file_content_type=file_content_type,
    )

    try:
        if not source.get("source_path"):
            return {
                "success": False,
                "error": "No parseable assignment source available",
                "structured_document": {
                    "pages": [],
                    "sections": [],
                    "tables": [],
                    "questions": [],
                    "metadata": source.get("metadata", {}),
                },
                "questions_answers": {},
                "document_titles": [title] if title else [],
                "core_concepts": [],
            }

        parsed = parse_document(source["source_path"])
        structured = structure_document(parsed, title=title, description=description)

        tables = extract_tables_from_doc(parsed, structured)
        structured["tables"] = tables

        questions = extract_questions(structured)
        structured["questions"] = questions

        retrieval_docs = build_retrieval_docs(structured)
        index = HybridIndex(retrieval_docs)

        qa = {}
        for q in questions:
            retrieved = index.hybrid_query(q.get("question_text", ""), top_k=8)
            q_context = build_context(structured, q, retrieved_docs=retrieved)
            ans = generate_answer(q_context)
            answer_text = ans.get("answer", "")
            if answer_text:
                qa[q.get("question_text", "Question")] = answer_text

        document_titles = [s.get("title", "") for s in structured.get("sections", []) if s.get("title")][:10]
        core_concepts = [
            s.get("title", "")
            for s in structured.get("sections", [])
            if any(k in (s.get("id", "") or "").upper() for k in ["THEORY", "AIM", "IMPLEMENTATION", "ALGORITHM", "QUESTIONS"])
        ][:12]

        return {
            "success": True,
            "questions_answers": qa,
            "document_titles": [d for d in document_titles if d],
            "core_concepts": [c for c in core_concepts if c],
            "structured_document": structured,
            "observability": {
                "page_count": len(structured.get("pages", [])),
                "section_count": len(structured.get("sections", [])),
                "question_count": len(structured.get("questions", [])),
                "table_count": len(structured.get("tables", [])),
                "source_kind": source.get("source_kind"),
            },
        }
    finally:
        cleanup_source(source)


__all__ = [
    "load_document_source",
    "parse_document",
    "structure_document",
    "extract_questions",
    "extract_tables_from_doc",
    "build_retrieval_docs",
    "HybridIndex",
    "build_context",
    "generate_answer",
    "run_assignment_pipeline",
]
