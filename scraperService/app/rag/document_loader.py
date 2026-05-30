"""
document_loader.py
Handles loading and extracting text content from assignment PDFs or raw text.
Supports both base64-encoded file content and plain text descriptions.
"""

import base64
import io
import logging
import re
import requests
import zipfile
import xml.etree.ElementTree as ET

from PyPDF2 import PdfReader

logger = logging.getLogger(__name__)


# ──────────────────────────────────────────────
#  Validation helpers
# ──────────────────────────────────────────────


def _is_likely_pdf(data: bytes) -> bool:
    """Check if bytes look like a PDF by inspecting the magic header."""
    if not data or len(data) < 5:
        return False
    # PDF files start with %PDF (possibly preceded by a BOM or whitespace)
    header = data[:1024]
    return b"%PDF" in header


def _is_likely_docx(data: bytes) -> bool:
    """Check if bytes look like a DOCX (ZIP archive)."""
    if not data or len(data) < 4:
        return False
    # ZIP magic bytes
    return data.startswith(b"PK\x03\x04")


def _is_html_content(data: bytes) -> bool:
    """Detect if the downloaded bytes are actually an HTML page (error page / login redirect)."""
    if not data:
        return False
    try:
        snippet = data[:512].decode("utf-8", errors="ignore").strip().lower()
        return (
            snippet.startswith("<!doctype html")
            or snippet.startswith("<html")
            or "<head>" in snippet
        )
    except Exception:
        return False


def _strip_html_to_text(data: bytes) -> str:
    """Best-effort extraction of visible text from an HTML page."""
    try:
        html = data.decode("utf-8", errors="ignore")
        # Remove script/style blocks
        html = re.sub(r"<(script|style)[^>]*>.*?</\1>", "", html, flags=re.DOTALL | re.IGNORECASE)
        # Remove tags
        text = re.sub(r"<[^>]+>", " ", html)
        # Collapse whitespace
        text = re.sub(r"\s+", " ", text).strip()
        return text
    except Exception:
        return ""


# ──────────────────────────────────────────────
#  PDF extraction
# ──────────────────────────────────────────────


def extract_text_from_pdf_bytes(pdf_bytes: bytes) -> str:
    """Extract text from a PDF file given as raw bytes."""
    if not _is_likely_pdf(pdf_bytes):
        logger.warning(
            "Bytes do not appear to be a valid PDF (missing %%PDF header), "
            "skipping PdfReader. First 100 bytes: %r",
            pdf_bytes[:100],
        )
        return ""

    try:
        reader = PdfReader(io.BytesIO(pdf_bytes))
        text_parts = []
        for page in reader.pages:
            page_text = page.extract_text()
            if page_text:
                text_parts.append(page_text.strip())
        return "\n\n".join(text_parts)
    except Exception as e:
        logger.error(f"Failed to extract text from PDF: {e}")
        return ""


def extract_text_from_docx_bytes(docx_bytes: bytes) -> str:
    """Extract text from a DOCX file using python standard library zipfile and xml."""
    try:
        with zipfile.ZipFile(io.BytesIO(docx_bytes)) as z:
            if "word/document.xml" not in z.namelist():
                return ""
            xml_content = z.read("word/document.xml")
            
        tree = ET.fromstring(xml_content)
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        
        text_parts = []
        for p in tree.findall('.//w:p', ns):
            para_text = []
            for t in p.findall('.//w:t', ns):
                if t.text:
                    para_text.append(t.text)
            if para_text:
                text_parts.append("".join(para_text))
                
        return "\n\n".join(text_parts)
    except Exception as e:
        logger.error(f"Failed to extract text from DOCX: {e}")
        return ""



def _extract_text_from_file_bytes(file_bytes: bytes, content_type: str = "") -> str:
    """Extract text from downloaded bytes based on content type and best-effort fallbacks."""
    if not file_bytes:
        return ""

    ct_lower = content_type.lower() if content_type else ""

    # ── If the server says it's a PDF, validate then parse ──
    if "pdf" in ct_lower:
        text = extract_text_from_pdf_bytes(file_bytes)
        if text:
            return text
        # If the "PDF" bytes failed, it might actually be an HTML error page
        if _is_html_content(file_bytes):
            logger.warning("Content-Type says PDF but payload is HTML; extracting text from HTML")
            return _strip_html_to_text(file_bytes)
        return ""

    # ── If the server says it's HTML, extract visible text ──
    if "html" in ct_lower:
        logger.info("Content-Type is HTML; extracting visible text")
        return _strip_html_to_text(file_bytes)

    # ── Heuristic: check the actual bytes ──
    if _is_likely_pdf(file_bytes):
        return extract_text_from_pdf_bytes(file_bytes)

    if _is_html_content(file_bytes):
        logger.info("Downloaded bytes look like HTML; extracting visible text")
        return _strip_html_to_text(file_bytes)

    if _is_likely_docx(file_bytes) or "wordprocessingml" in ct_lower:
        logger.info("Content looks like DOCX; extracting text using zipfile")
        text = extract_text_from_docx_bytes(file_bytes)
        if text:
            return text

    # ── Try plain-text decode ──
    # Note: Only try utf-8 text decoding if we haven't matched a known binary format
    if not _is_likely_pdf(file_bytes) and not _is_likely_docx(file_bytes):
        try:
            return file_bytes.decode("utf-8")
        except UnicodeDecodeError:
            pass

    logger.warning("Could not extract any text from downloaded file (%d bytes)", len(file_bytes))
    return ""


# ──────────────────────────────────────────────
#  Download helpers
# ──────────────────────────────────────────────


def _download_file_from_url(file_url: str, file_access_token: str = "") -> tuple[bytes, str]:
    """Download file bytes from URL and return (content_bytes, content_type)."""
    file_url = _normalize_drive_url(file_url)
    headers = {}
    if file_access_token:
        headers["Authorization"] = f"Bearer {file_access_token}"

    response = requests.get(file_url, headers=headers, timeout=45)
    response.raise_for_status()
    content_type = response.headers.get("Content-Type", "")
    return response.content, content_type


def _extract_drive_file_id(file_url: str) -> str:
    """Best-effort extraction of Drive file ID from common URL shapes."""
    patterns = [
        r"/files/([a-zA-Z0-9_-]+)",
        r"/d/([a-zA-Z0-9_-]+)",
        r"[?&]id=([a-zA-Z0-9_-]+)",
    ]
    for pattern in patterns:
        m = re.search(pattern, file_url)
        if m:
            return m.group(1)
    return ""


def _download_google_native_export_if_needed(file_url: str, file_access_token: str = "") -> tuple[bytes, str]:
    """
    For Google-native files (Docs/Sheets/Slides), alt=media is not reliable.
    Detect the Drive mimeType and export as PDF in-memory.
    """
    file_id = _extract_drive_file_id(file_url)
    if not file_id:
        return b"", ""

    headers = {}
    if file_access_token:
        headers["Authorization"] = f"Bearer {file_access_token}"

    meta_url = f"https://www.googleapis.com/drive/v3/files/{file_id}?fields=mimeType"
    meta_resp = requests.get(meta_url, headers=headers, timeout=45)
    if meta_resp.status_code != 200:
        return b"", ""

    mime_type = (meta_resp.json() or {}).get("mimeType", "")
    if not str(mime_type).startswith("application/vnd.google-apps"):
        return b"", ""

    export_url = f"https://www.googleapis.com/drive/v3/files/{file_id}/export?mimeType=application/pdf"
    export_resp = requests.get(export_url, headers=headers, timeout=60)
    export_resp.raise_for_status()
    return export_resp.content, "application/pdf"


def _download_via_drive_api(file_url: str, file_access_token: str = "") -> tuple[bytes, str]:
    """
    Deterministic Drive download path:
    - If Google-native file => export as PDF
    - Else => alt=media
    Returns (bytes, content_type), empty tuple on fallback conditions.
    """
    if not file_access_token:
        return b"", ""

    file_id = _extract_drive_file_id(file_url)
    if not file_id:
        return b"", ""

    headers = {"Authorization": f"Bearer {file_access_token}"}
    meta_url = f"https://www.googleapis.com/drive/v3/files/{file_id}?fields=id,name,mimeType"
    meta_resp = requests.get(meta_url, headers=headers, timeout=45)
    if meta_resp.status_code != 200:
        logger.warning(f"Drive metadata fetch failed ({meta_resp.status_code}) for file_id={file_id}")
        return b"", ""

    meta = meta_resp.json() or {}
    mime_type = str(meta.get("mimeType", ""))
    logger.info(f"Drive metadata resolved file_id={file_id}, mimeType={mime_type}")

    if mime_type.startswith("application/vnd.google-apps"):
        export_url = f"https://www.googleapis.com/drive/v3/files/{file_id}/export?mimeType=application/pdf"
        export_resp = requests.get(export_url, headers=headers, timeout=60)
        export_resp.raise_for_status()
        logger.info(f"Downloaded Google-native export PDF for file_id={file_id}, bytes={len(export_resp.content)}")
        return export_resp.content, "application/pdf"

    media_url = f"https://www.googleapis.com/drive/v3/files/{file_id}?alt=media"
    media_resp = requests.get(media_url, headers=headers, timeout=60)
    media_resp.raise_for_status()
    media_type = media_resp.headers.get("Content-Type", "")
    logger.info(f"Downloaded Drive media for file_id={file_id}, content_type={media_type}, bytes={len(media_resp.content)}")
    return media_resp.content, media_type


def _normalize_drive_url(file_url: str) -> str:
    """
    Normalize common Google Drive/Docs links into direct-download or export URLs.
    This keeps extraction in-memory and avoids relying on browser-only share pages.
    """
    if not file_url:
        return file_url

    # Already a direct API/media URL.
    if "drive/v3/files/" in file_url and "alt=media" in file_url:
        return file_url

    # Docs/Sheets/Slides export endpoints.
    m = re.search(r"https://docs\.google\.com/document/d/([^/]+)", file_url)
    if m:
        return f"https://docs.google.com/document/d/{m.group(1)}/export?format=pdf"

    m = re.search(r"https://docs\.google\.com/spreadsheets/d/([^/]+)", file_url)
    if m:
        return f"https://docs.google.com/spreadsheets/d/{m.group(1)}/export?format=pdf"

    m = re.search(r"https://docs\.google\.com/presentation/d/([^/]+)", file_url)
    if m:
        return f"https://docs.google.com/presentation/d/{m.group(1)}/export/pdf"

    # Generic Drive share links -> direct file download.
    m = re.search(r"/d/([a-zA-Z0-9_-]+)", file_url)
    if m and "drive.google.com" in file_url:
        return f"https://www.googleapis.com/drive/v3/files/{m.group(1)}?alt=media"

    m = re.search(r"[?&]id=([a-zA-Z0-9_-]+)", file_url)
    if m and "drive.google.com" in file_url:
        return f"https://www.googleapis.com/drive/v3/files/{m.group(1)}?alt=media"

    return file_url


# ──────────────────────────────────────────────
#  Main entry point
# ──────────────────────────────────────────────


def load_document(
    title: str = "",
    description: str = "",
    file_url: str = "",
    file_access_token: str = "",
    file_content_base64: str = "",
    file_content_type: str = "",
) -> str:
    """
    Load and combine all available document content into a single text string.

    Priority:
    1. Base64 file content (pre-downloaded by backend with fresh OAuth token)
    2. File downloaded from file_url (fallback when base64 unavailable)
    3. Title + description only (last resort — questions will be generic)
    """
    parts = []
    document_content_loaded = False

    if title:
        parts.append(f"Assignment Title: {title}")
    if description:
        parts.append(f"Assignment Description:\n{description}")

    # ── Primary path: base64 bytes sent by backend ──
    # The backend downloads the file using a token-refreshing OAuth client,
    # so the bytes are always from a valid authenticated request.
    if file_content_base64:
        try:
            file_bytes = base64.b64decode(file_content_base64)
            logger.info(
                "Decoding base64 file: %d bytes, declared content_type=%s, is_pdf=%s, is_docx=%s, is_html=%s",
                len(file_bytes),
                file_content_type,
                _is_likely_pdf(file_bytes),
                _is_likely_docx(file_bytes),
                _is_html_content(file_bytes),
            )
            extracted = _extract_text_from_file_bytes(file_bytes, file_content_type)
            if extracted:
                logger.info("Base64 content extracted successfully: %d chars", len(extracted))
                parts.append(f"Document Content:\n{extracted}")
                document_content_loaded = True
            else:
                logger.error(
                    "Base64 file extraction returned EMPTY TEXT — "
                    "content_type=%s, first 100 bytes=%r",
                    file_content_type,
                    file_bytes[:100],
                )
        except Exception as e:
            logger.error("Failed to decode/parse base64 file content: %s", e)

    # ── Fallback path: download from URL (token may be expired) ──
    if not document_content_loaded and file_url:
        logger.info("No base64 content; attempting URL download: %s", file_url)
        try:
            file_bytes, downloaded_content_type = _download_via_drive_api(
                file_url=file_url,
                file_access_token=file_access_token,
            )
            if not file_bytes:
                logger.warning(
                    "Drive API download returned empty bytes "
                    "(token may be expired); trying direct URL fetch"
                )
                file_bytes, downloaded_content_type = _download_file_from_url(
                    file_url=file_url,
                    file_access_token=file_access_token,
                )

            logger.info(
                "URL download result: %d bytes, content_type=%s, is_pdf=%s, is_html=%s",
                len(file_bytes),
                downloaded_content_type,
                _is_likely_pdf(file_bytes),
                _is_html_content(file_bytes),
            )

            extracted = _extract_text_from_file_bytes(
                file_bytes=file_bytes,
                content_type=downloaded_content_type or file_content_type,
            )
            if not extracted:
                # Last attempt: Google-native export (Docs/Sheets/Slides)
                export_bytes, export_content_type = _download_google_native_export_if_needed(
                    file_url=file_url,
                    file_access_token=file_access_token,
                )
                if export_bytes:
                    extracted = _extract_text_from_file_bytes(export_bytes, export_content_type)

            if extracted:
                logger.info("URL content extracted successfully: %d chars", len(extracted))
                parts.append(f"Document Content:\n{extracted}")
                document_content_loaded = True
            else:
                logger.error(
                    "URL file extraction returned EMPTY TEXT — "
                    "the access token is likely expired or the file is inaccessible. "
                    "Questions will be generated from title/description only."
                )
        except Exception as e:
            logger.error("Failed to download or parse file from URL: %s", e)

    if not document_content_loaded:
        logger.warning(
            "NO document content loaded for title=%r — "
            "RAG will generate questions from metadata only, results may be inaccurate.",
            title,
        )

    full_text = "\n\n".join(parts)
    logger.info("Document loaded: %d total chars, document_content_loaded=%s", len(full_text), document_content_loaded)
    return full_text


def parse_topic(file_content_base64: str):
    print("Parsing topic from base64 content...")
    if "base64," in file_content_base64:
        file_content_base64 = file_content_base64.split("base64,")[1]

    pdfbytes = base64.b64decode(file_content_base64)

    # Validate before parsing
    if not _is_likely_pdf(pdfbytes):
        logger.warning("parse_topic: content does not look like a valid PDF")
        # Try to return as plain text
        try:
            return pdfbytes.decode("utf-8", errors="ignore")
        except Exception:
            return ""

    reader = PdfReader(io.BytesIO(pdfbytes))

    text = []
    for page in reader.pages:
        text.append(page.extract_text() or "")

    return "\n".join(text)
