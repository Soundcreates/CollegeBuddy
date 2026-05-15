"""Document loader for Docling pipeline.

Loads assignment source from:
- Google Drive/URL download
- base64 payload
Then materializes a temp file for Docling parsing while preserving metadata.
"""

from __future__ import annotations

import base64
import logging
import os
import re
import tempfile
from typing import Any, Dict, Tuple

import requests

logger = logging.getLogger(__name__)


def _extract_drive_file_id(file_url: str) -> str:
    patterns = [
        r"/files/([a-zA-Z0-9_-]+)",
        r"/d/([a-zA-Z0-9_-]+)",
        r"[?&]id=([a-zA-Z0-9_-]+)",
    ]
    for pattern in patterns:
        m = re.search(pattern, file_url or "")
        if m:
            return m.group(1)
    return ""


def _content_ext(content_type: str) -> str:
    ct = (content_type or "").lower()
    if "pdf" in ct:
        return ".pdf"
    if "word" in ct or "docx" in ct:
        return ".docx"
    if "text" in ct:
        return ".txt"
    return ".bin"


def _download_from_drive_api(file_url: str, file_access_token: str) -> Tuple[bytes, str]:
    file_id = _extract_drive_file_id(file_url)
    if not file_id or not file_access_token:
        return b"", ""

    headers = {"Authorization": f"Bearer {file_access_token}"}
    meta_url = f"https://www.googleapis.com/drive/v3/files/{file_id}?fields=id,name,mimeType"
    meta_resp = requests.get(meta_url, headers=headers, timeout=45)
    if meta_resp.status_code != 200:
        logger.warning("Drive metadata fetch failed (%s)", meta_resp.status_code)
        return b"", ""

    mime_type = str((meta_resp.json() or {}).get("mimeType", ""))
    if mime_type.startswith("application/vnd.google-apps"):
        export_url = f"https://www.googleapis.com/drive/v3/files/{file_id}/export?mimeType=application/pdf"
        export_resp = requests.get(export_url, headers=headers, timeout=60)
        export_resp.raise_for_status()
        return export_resp.content, "application/pdf"

    media_url = f"https://www.googleapis.com/drive/v3/files/{file_id}?alt=media"
    media_resp = requests.get(media_url, headers=headers, timeout=60)
    media_resp.raise_for_status()
    return media_resp.content, media_resp.headers.get("Content-Type", "")


def _download_from_url(file_url: str, file_access_token: str = "") -> Tuple[bytes, str]:
    headers = {}
    if file_access_token:
        headers["Authorization"] = f"Bearer {file_access_token}"
    resp = requests.get(file_url, headers=headers, timeout=60)
    resp.raise_for_status()
    return resp.content, resp.headers.get("Content-Type", "")


def _write_temp_file(content: bytes, content_type: str) -> str:
    fd, path = tempfile.mkstemp(prefix="docling_assignment_", suffix=_content_ext(content_type))
    with os.fdopen(fd, "wb") as f:
        f.write(content)
    return path


def load_document_source(
    title: str = "",
    description: str = "",
    file_url: str = "",
    file_access_token: str = "",
    file_content_base64: str = "",
    file_content_type: str = "",
) -> Dict[str, Any]:
    """Load assignment source and return structured source metadata.

    Returns:
      {
        "source_path": str,
        "source_kind": "file_url"|"base64"|"text_only",
        "title": str,
        "description": str,
        "metadata": {...}
      }
    """
    metadata: Dict[str, Any] = {
        "title": title,
        "description": description,
        "file_url": file_url,
    }

    if file_url:
        try:
            content, ct = _download_from_drive_api(file_url, file_access_token)
            if not content:
                content, ct = _download_from_url(file_url, file_access_token)
            source_path = _write_temp_file(content, ct or file_content_type)
            metadata.update({"content_type": ct or file_content_type, "byte_size": len(content)})
            return {
                "source_path": source_path,
                "source_kind": "file_url",
                "title": title,
                "description": description,
                "metadata": metadata,
            }
        except Exception as e:
            logger.exception("Failed to load source from file_url")
            metadata["file_url_error"] = str(e)

    if file_content_base64:
        try:
            payload = file_content_base64
            if "base64," in payload:
                payload = payload.split("base64,")[1]
            content = base64.b64decode(payload)
            source_path = _write_temp_file(content, file_content_type)
            metadata.update({"content_type": file_content_type, "byte_size": len(content)})
            return {
                "source_path": source_path,
                "source_kind": "base64",
                "title": title,
                "description": description,
                "metadata": metadata,
            }
        except Exception as e:
            logger.exception("Failed to load source from base64")
            metadata["base64_error"] = str(e)

    return {
        "source_path": "",
        "source_kind": "text_only",
        "title": title,
        "description": description,
        "metadata": metadata,
    }


def cleanup_source(source: Dict[str, Any]) -> None:
    path = source.get("source_path") or ""
    if path and os.path.exists(path):
        try:
            os.remove(path)
        except Exception:
            logger.warning("Failed to cleanup temp source file: %s", path)
