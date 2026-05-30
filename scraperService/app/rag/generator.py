"""
generator.py
Generates structured content suggestions using Groq's API (Llama models).
Takes relevant context chunks and produces bulleted content points.
"""

import logging
import os
import re
import json
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


def extract_and_answer_questions(
    extraction_context: str,
    answer_context: str = "",
    title: str = "",
    description: str = "",
) -> dict:
    """
    Extract questions from an assignment and generate detailed answers.
    Uses a two-stage approach:
    1. First, parse the document to extract questions/tasks
    2. Then generate detailed answers for each question
    
    Args:
        extraction_context: Broad document text used to extract all prompts/questions
        answer_context: Focused context used for answer generation
        title: Assignment title
        description: Assignment description
        
    Returns:
        Dict with 'questions_answers' containing {question: answer} mapping
    """
    try:
        client = _get_client()
    except Exception as e:
        logger.error(f"Configuration error: {e}")
        return {
            "success": False,
            "error": str(e),
            "questions_answers": {},
        }

    # ── Stage 1: Extract questions from the document ──
    extraction_prompt = f"""You are analyzing an assignment document. Your ONLY job is to extract all questions, tasks, or prompts that the student needs to answer.

Assignment Title: {title}
Description: {description if description else 'Not provided'}

Document Content:
{extraction_context if extraction_context else 'No document content available'}

Instructions:
- CRITICAL: If the document contains a section named 'Post Lab Objective Questions' (or similar like 'Post Lab Questions'), you MUST extract all questions from that section. Prioritize these over general tasks.
- Extract every question, task, prompt, section title, and concept that looks like
  something the student must cover or answer
- If there are numbered questions, extract them exactly as stated
- If the assignment describes tasks (e.g., "Write a program to...", "Explain...", "Discuss..."), treat each task as a question
- If no explicit questions exist, infer 3-5 key questions based on the title and description
- Return ONLY JSON in this exact shape:
  {{
    "document_titles": ["..."],
    "core_concepts": ["..."],
    "questions": ["..."]
  }}
- Do NOT include any other text, markdown, or explanation
"""

    try:
        # Stage 1: Extract questions
        extraction_response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": "You extract assignment structure from academic documents. Return ONLY a valid JSON object with keys: document_titles, core_concepts, questions."},
                {"role": "user", "content": extraction_prompt},
            ],
            temperature=0.3,
            max_tokens=1800,
        )

        extraction_raw = extraction_response.choices[0].message.content.strip()
        logger.info(f"Extracted structure raw: {extraction_raw[:200]}")

        parsed = _parse_assignment_structure(extraction_raw)
        questions = parsed.get("questions", [])
        core_concepts = parsed.get("core_concepts", [])
        document_titles = parsed.get("document_titles", [])
        
        if not questions:
            # Fallback: generate questions from title/description
            logger.warning("No questions extracted, generating from title")
            questions = [f"What are the key concepts related to {title}?",
                        f"Explain the main topics covered in {title}.",
                        f"What is the expected approach for {title}?"]

        logger.info(f"Extracted {len(questions)} questions")

        # ── Stage 2: Answer each question with context ──
        qa_prompt = f"""You are an academic assistant. Answer the following questions based on the assignment context provided.

Assignment: {title}
Document Titles/Sections: {", ".join(document_titles) if document_titles else "Not explicitly identified"}
Core Concepts: {", ".join(core_concepts) if core_concepts else "Not explicitly identified"}
Context: {answer_context if answer_context else extraction_context if extraction_context else description if description else 'Use your knowledge to answer.'}

Questions to answer:
{chr(10).join(f'{i+1}. {q}' for i, q in enumerate(questions))}

Instructions:
- Answer EACH question thoroughly (2-4 sentences minimum per answer)
- Be academic and factual in tone
- Use specific examples where possible
- Format your response EXACTLY as follows (one per line):

QUESTION: [exact question text]
ANSWER: [your detailed answer]

Repeat for each question. Use EXACTLY "QUESTION:" and "ANSWER:" prefixes."""

        answer_response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": "You are a knowledgeable academic assistant. Answer questions thoroughly and accurately. Format each Q&A pair with QUESTION: and ANSWER: prefixes."},
                {"role": "user", "content": qa_prompt},
            ],
            temperature=0.5,
            max_tokens=4096,
        )

        raw_text = answer_response.choices[0].message.content
        logger.info(f"Generated answers: {len(raw_text)} characters")

        # Parse the Q&A pairs from the response
        questions_answers = parse_qa_pairs(raw_text, questions)
        logger.info(f"Parsed {len(questions_answers)} Q&A pairs")

        # If parsing failed, try to at least return something
        if not questions_answers:
            # Fallback: use the raw text as a single answer
            questions_answers = {title: raw_text.strip()}
            logger.warning("Fallback: returning raw text as single Q&A pair")

        return {
            "success": True,
            "questions_answers": questions_answers,
            "document_titles": document_titles,
            "core_concepts": core_concepts,
        }

    except Exception as e:
        logger.error(f"Groq API error in Q&A extraction: {e}")
        return {
            "success": False,
            "error": str(e),
            "questions_answers": {},
        }


def _parse_questions_list(text: str) -> list:
    """Parse a list of questions from LLM output. Handles JSON arrays and plain text."""
    text = text.strip()
    
    # Try to parse as JSON first
    try:
        # Find JSON array in the text
        match = re.search(r'\[.*\]', text, re.DOTALL)
        if match:
            questions = json.loads(match.group())
            if isinstance(questions, list):
                return [str(q).strip() for q in questions if str(q).strip()]
    except (json.JSONDecodeError, Exception) as e:
        logger.debug(f"JSON parse failed: {e}")

    # Fallback: parse line by line
    questions = []
    for line in text.split("\n"):
        line = line.strip()
        if not line:
            continue
        # Remove numbering like "1.", "1)", "Q1:", etc.
        cleaned = re.sub(r'^(\d+[\.\)]\s*|Q\d+[\.:]\s*|[-•]\s*)', '', line).strip()
        # Remove quotes
        cleaned = cleaned.strip('"').strip("'").strip()
        if cleaned and len(cleaned) > 5:  # Filter out very short lines
            questions.append(cleaned)
    
    return questions


def _parse_assignment_structure(text: str) -> dict:
    """
    Parse assignment structure JSON from LLM output.
    Returns keys: document_titles, core_concepts, questions.
    """
    parsed = {
        "document_titles": [],
        "core_concepts": [],
        "questions": [],
    }

    if not text.strip():
        return parsed

    try:
        # Try full object parse first
        obj = json.loads(text)
    except Exception:
        obj = None

    if obj is None:
        # Try to locate a JSON object in noisy output
        match = re.search(r"\{.*\}", text, re.DOTALL)
        if match:
            try:
                obj = json.loads(match.group())
            except Exception:
                obj = None

    if isinstance(obj, dict):
        for key in parsed.keys():
            raw = obj.get(key, [])
            if isinstance(raw, list):
                parsed[key] = [str(v).strip() for v in raw if str(v).strip()]
        if parsed["questions"]:
            return parsed

    # Last-resort fallback: infer questions from line parsing
    parsed["questions"] = _parse_questions_list(text)
    return parsed


def parse_qa_pairs(text: str, original_questions: list = None) -> dict:
    """
    Parse Q&A pairs from the response text.
    Handles multiple formats:
    - QUESTION: ... ANSWER: ...
    - Q: ... | A: ...
    - Numbered Q&A
    - Markdown formatted Q&A
    
    Args:
        text: Raw text containing Q&A pairs
        original_questions: Original questions list for fallback matching
        
    Returns:
        Dictionary mapping questions to answers
    """
    qa_dict = {}
    
    # Strategy 1: QUESTION: / ANSWER: format (most reliable)
    qa_pattern = re.compile(
        r'QUESTION:\s*(.+?)(?:\n)ANSWER:\s*(.+?)(?=\nQUESTION:|\Z)',
        re.DOTALL | re.IGNORECASE
    )
    matches = qa_pattern.findall(text)
    if matches:
        for q, a in matches:
            q = q.strip().strip('*').strip()
            a = a.strip().strip('*').strip()
            if q and a:
                qa_dict[q] = a
        if qa_dict:
            return qa_dict

    # Strategy 2: Q: ... | A: ... format (single line)
    for line in text.split("\n"):
        line = line.strip()
        if not line or "|" not in line:
            continue
        try:
            parts = line.split("|", 1)
            if len(parts) != 2:
                continue
            q_part = parts[0].strip()
            a_part = parts[1].strip()
            if q_part.upper().startswith("Q:"):
                q_part = q_part[2:].strip()
            if a_part.upper().startswith("A:"):
                a_part = a_part[2:].strip()
            if q_part and a_part:
                qa_dict[q_part] = a_part
        except Exception:
            continue
    if qa_dict:
        return qa_dict

    # Strategy 3: Numbered Q&A with **bold** or ### headers
    # Pattern: **Q1:** or **1.** or ### Question 1 followed by answer text
    current_question = None
    current_answer_lines = []
    
    for line in text.split("\n"):
        stripped = line.strip()
        if not stripped:
            continue
        
        # Check if this is a question line
        is_question = False
        question_text = stripped
        
        # Match patterns like: **Q1:**, **Question 1:**, 1., Q1., etc.
        q_patterns = [
            r'^\*\*(?:Q(?:uestion)?\s*\d*[\.:])?\s*(.+?)\*\*',  # **Q1: text** or **text**
            r'^#{1,4}\s*(?:Q(?:uestion)?\s*\d*[\.:])?\s*(.+)',    # ### Q1: text
            r'^(?:Q(?:uestion)?\s*\d+[\.:]\s*)(.+)',               # Q1: text or Question 1: text
            r'^(\d+[\.\)]\s*.+\?)',                                  # 1. text? (question with ?)
        ]
        
        for pattern in q_patterns:
            match = re.match(pattern, stripped, re.IGNORECASE)
            if match:
                is_question = True
                question_text = match.group(1).strip().rstrip(':').strip()
                break
        
        if is_question and question_text:
            # Save previous Q&A if exists
            if current_question and current_answer_lines:
                qa_dict[current_question] = " ".join(current_answer_lines).strip()
            current_question = question_text
            current_answer_lines = []
        elif current_question is not None:
            # Check if this is an answer prefix line
            answer_prefixes = [r'^(?:\*\*)?A(?:nswer)?[\.:]\s*(?:\*\*)?\s*(.*)', r'^[-•]\s*(.+)']
            matched_answer = False
            for ap in answer_prefixes:
                am = re.match(ap, stripped, re.IGNORECASE)
                if am:
                    answer_text = am.group(1).strip()
                    if answer_text:
                        current_answer_lines.append(answer_text)
                    matched_answer = True
                    break
            if not matched_answer:
                # It's a continuation of the answer
                current_answer_lines.append(stripped)
    
    # Don't forget the last Q&A pair
    if current_question and current_answer_lines:
        qa_dict[current_question] = " ".join(current_answer_lines).strip()
    
    if qa_dict:
        return qa_dict

    # Strategy 4: If we have original questions, try to match them in the text
    if original_questions:
        remaining_text = text
        for i, question in enumerate(original_questions):
            # Try to find the question in the text and extract the answer after it
            q_escaped = re.escape(question[:50])  # Use first 50 chars
            next_q_pattern = re.escape(original_questions[i+1][:50]) if i+1 < len(original_questions) else r"\Z"
            pattern = re.compile(
                rf'{q_escaped}.*?(?:\n)(.*?)(?=(?:{next_q_pattern}))',
                re.DOTALL | re.IGNORECASE
            )
            match = pattern.search(remaining_text)
            if match:
                answer = match.group(1).strip()
                # Clean up the answer
                answer = re.sub(r'^(?:A(?:nswer)?[\.:]\s*)', '', answer, flags=re.IGNORECASE).strip()
                if answer:
                    qa_dict[question] = answer
        if qa_dict:
            return qa_dict

    return qa_dict


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
