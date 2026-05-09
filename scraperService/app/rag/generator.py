"""
generator.py
Generates structured content suggestions using Groq's API (Llama models).
Takes relevant context chunks and produces bulleted content points.
"""

import logging
import os
from groq import Groq

logger = logging.getLogger(__name__)

_client = None


def _get_client():
    """Get or configure the Groq API client."""
    global _client
    if _client is None:
        api_key = os.getenv("GROQ_API_KEY")
        if not api_key:
            raise ValueError("GROQ_API_KEY environment variable is required")
        _client = Groq(api_key=api_key)
        logger.info("Groq API client configured")
    return _client


SYSTEM_PROMPT = """You are an academic assistant helping a college student complete their assignments. 
You will be given the context of an assignment — its title, description, and any template/document content.

Your job is to:
1. Understand what the assignment is asking for
2. Identify the key sections or fields the student needs to fill in
3. Generate clear, concise content points that the student can use

Rules:
- Output ONLY structured content with clear headers and bullet points
- Each header should represent a section of the assignment
- Each bullet should be a specific, actionable content point
- Do NOT generate a full document — give precise content the student can copy
- Be factual and academic in tone
- If the document has specific fields (like name, date, roll number), skip those — focus on content fields
- Format your response as clean markdown with ## headers and - bullet points

Example output format:
## Introduction
- Define the core concept being discussed
- State the relevance to the course topic
- Mention 2-3 key objectives

## Methodology
- Describe the approach taken
- List tools or frameworks used

## Key Findings
- Present 3-5 main findings with brief explanations
"""


def generate_content(context: str, title: str = "", description: str = "") -> dict:
    """
    Generate structured content suggestions for an assignment using Groq.
    
    Args:
        context: Retrieved relevant text chunks
        title: Assignment title
        description: Assignment description
        
    Returns:
        Dict with 'sections' containing structured content
    """
    try:
        client = _get_client()
    except Exception as e:
        logger.error(f"Configuration error: {e}")
        return {
            "success": False,
            "error": str(e),
            "raw_markdown": "",
            "sections": [],
        }

    # Build the prompt
    user_prompt = f"""Here is the assignment context:

Title: {title}
Description: {description if description else 'Not provided'}

Document content / template:
{context if context else 'No document content available — use the title and description to infer what content is needed.'}

Based on this assignment, generate the content the student needs to fill in. 
Structure it as clear headers with bullet points under each."""

    try:
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.7,
            max_tokens=2048,
        )

        raw_text = completion.choices[0].message.content
        logger.info(f"Generated content using Groq: {len(raw_text)} characters")

        # Parse the markdown into structured sections
        sections = parse_markdown_sections(raw_text)

        return {
            "success": True,
            "raw_markdown": raw_text,
            "sections": sections,
        }

    except Exception as e:
        logger.error(f"Groq API error: {e}")
        return {
            "success": False,
            "error": str(e),
            "raw_markdown": "",
            "sections": [],
        }


def parse_markdown_sections(markdown: str) -> list:
    """Parse markdown text into structured sections with headers and bullet points."""
    sections = []
    current_section = None

    for line in markdown.split("\n"):
        line = line.strip()
        if not line:
            continue

        if line.startswith("## "):
            if current_section:
                sections.append(current_section)
            current_section = {
                "header": line[3:].strip(),
                "points": [],
            }
        elif line.startswith("# "):
            if current_section:
                sections.append(current_section)
            current_section = {
                "header": line[2:].strip(),
                "points": [],
            }
        elif line.startswith("- ") or line.startswith("* "):
            point = line[2:].strip()
            if current_section:
                current_section["points"].append(point)
            else:
                current_section = {"header": "General", "points": [point]}
        elif line.startswith("• "):
            point = line[2:].strip()
            if current_section:
                current_section["points"].append(point)

    if current_section:
        sections.append(current_section)

    return sections
