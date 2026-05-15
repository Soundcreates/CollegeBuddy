"""Hybrid retrieval (BM25 + dense embeddings) for structured docs."""

from __future__ import annotations

from typing import Any, Dict, List
import logging

logger = logging.getLogger(__name__)

try:
    from rank_bm25 import BM25Okapi
except Exception:
    BM25Okapi = None

try:
    from sentence_transformers import SentenceTransformer
    from sklearn.metrics.pairwise import cosine_similarity
except Exception:
    SentenceTransformer = None
    cosine_similarity = None


class HybridIndex:
    def __init__(self, docs: List[Dict[str, Any]]):
        self.docs = docs
        self.corpus = [d.get("text", "") for d in docs]
        self.bm25 = BM25Okapi([c.split() for c in self.corpus]) if BM25Okapi and self.corpus else None
        self.model = SentenceTransformer("all-MiniLM-L6-v2") if SentenceTransformer and self.corpus else None
        self.embeddings = self.model.encode(self.corpus, convert_to_numpy=True) if self.model else None

    def bm25_query(self, query: str, top_k: int = 6) -> List[Dict[str, Any]]:
        if not self.bm25:
            return []
        scores = self.bm25.get_scores(query.split())
        idxs = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)[:top_k]
        return [self.docs[i] for i in idxs]

    def dense_query(self, query: str, top_k: int = 6) -> List[Dict[str, Any]]:
        if self.model is None or self.embeddings is None or cosine_similarity is None:
            return []
        q = self.model.encode([query], convert_to_numpy=True)
        sims = cosine_similarity(q, self.embeddings)[0]
        idxs = sorted(range(len(sims)), key=lambda i: sims[i], reverse=True)[:top_k]
        return [self.docs[i] for i in idxs]

    def hybrid_query(self, query: str, top_k: int = 8) -> List[Dict[str, Any]]:
        merged: List[Dict[str, Any]] = []
        seen = set()
        for d in self.bm25_query(query, top_k) + self.dense_query(query, top_k):
            uid = d.get("id") or f"{d.get('kind','')}:{d.get('page','')}:{hash(d.get('text',''))}"
            if uid in seen:
                continue
            seen.add(uid)
            merged.append(d)
            if len(merged) >= top_k:
                break
        return merged


def build_retrieval_docs(structured_doc: Dict[str, Any]) -> List[Dict[str, Any]]:
    docs: List[Dict[str, Any]] = []

    for sec in structured_doc.get("sections", []):
        docs.append(
            {
                "id": f"section:{sec.get('id')}:{','.join(map(str, sec.get('pages', [])))}",
                "kind": "section",
                "page": sec.get("pages", [None])[0],
                "text": (sec.get("title", "") + "\n" + sec.get("text", "")).strip(),
                "meta": {"section": sec.get("id"), "pages": sec.get("pages", [])},
            }
        )

    for idx, t in enumerate(structured_doc.get("tables", [])):
        table_text = " | ".join(t.get("headers", [])) + "\n" + "\n".join(" | ".join(map(str, r)) for r in t.get("rows", []))
        docs.append(
            {
                "id": f"table:{idx}",
                "kind": "table",
                "page": t.get("page"),
                "text": table_text,
                "meta": {"table_index": idx},
            }
        )

    for p in structured_doc.get("pages", []):
        docs.append(
            {
                "id": f"page:{p.get('page_index')}",
                "kind": "page",
                "page": p.get("page_index"),
                "text": p.get("markdown", ""),
                "meta": {},
            }
        )

    return docs
