import logging
import time
from typing import TYPE_CHECKING
from app.model import semantic_classify
from app.inference import TARGET_CATEGORIES, CONFIDENCE_THRESHOLD

if TYPE_CHECKING:
    from app.schemas import Email, FilteredEmail, BatchEmailFilterResponse

logger = logging.getLogger(__name__)

class EmailFilterService:
    """Service for filtering academic emails using AI classification"""
    
    # Category groupings for better organization
    CATEGORY_GROUPS = {
        "classes": ["online class", "course update", "seminar", "workshop"],
        "exams": ["exam", "exam schedule"],
        "assignments": ["assignment", "assignment deadline"],
        "grades": ["grade notification"],
        "important": ["urgent notification", "important notice", "administrative notice", "holiday notice"],
        "meetings": ["meeting", "event"],
        "study": ["study material", "study resources", "academic"],
    }
    
    # Keywords for additional context-based filtering (increased coverage)
    URGENT_KEYWORDS = ["urgent", "asap", "immediately", "deadline", "critical", "important"]
    EXAM_KEYWORDS = ["exam", "test", "quiz", "final", "midterm", "assessment", "evaluation"]
    CLASS_KEYWORDS = ["class", "lecture", "session", "online", "zoom", "meet", "live session", "course", "module", "topic"]
    ASSIGNMENT_KEYWORDS = ["assignment", "project", "task", "submission", "deadline", "homework", "work", "submit"]
    STUDY_KEYWORDS = ["study", "learning", "material", "resources", "notes", "reading", "practice", "tutorial", "guide"]
    
    @staticmethod
    def extract_text_for_classification(email: "Email") -> str:
        """Extract text from email for classification"""
        # Combine subject and body for better classification context
        return f"Subject: {email.subject}\n\nBody: {email.body}"
    
    @staticmethod
    def calculate_confidence_score(
        ai_label: str, 
        ai_score: float, 
        subject: str, 
        body: str
    ) -> tuple[str, float]:
        """
        Calculate enhanced confidence score based on AI classification 
        and keyword matching (more lenient with larger boosts)
        """
        text_lower = f"{subject} {body}".lower()
        
        # Boost confidence based on keyword matching (increased boost amounts)
        keyword_boost = 0.0
        
        if ai_label in EmailFilterService.EXAM_KEYWORDS:
            if any(kw in text_lower for kw in EmailFilterService.EXAM_KEYWORDS):
                keyword_boost = 0.20
        elif ai_label in EmailFilterService.CLASS_KEYWORDS:
            if any(kw in text_lower for kw in EmailFilterService.CLASS_KEYWORDS):
                keyword_boost = 0.25
        elif ai_label in EmailFilterService.ASSIGNMENT_KEYWORDS:
            if any(kw in text_lower for kw in EmailFilterService.ASSIGNMENT_KEYWORDS):
                keyword_boost = 0.25
        elif ai_label in EmailFilterService.STUDY_KEYWORDS:
            if any(kw in text_lower for kw in EmailFilterService.STUDY_KEYWORDS):
                keyword_boost = 0.20
        
        # Boost for urgent keywords (increased boost)
        if any(kw in text_lower for kw in EmailFilterService.URGENT_KEYWORDS):
            keyword_boost = max(keyword_boost, 0.25)
        
        # Additional boost for generic study keywords
        study_keywords_found = any(kw in text_lower for kw in EmailFilterService.STUDY_KEYWORDS)
        if study_keywords_found and keyword_boost == 0.0:
            keyword_boost = 0.15
        
        final_score = min(ai_score + keyword_boost, 1.0)
        return ai_label, final_score
    
    @staticmethod
    def get_category_group(label: str) -> str:
        """Get the category group for a given label"""
        for group, labels in EmailFilterService.CATEGORY_GROUPS.items():
            if label in labels:
                return group
        return "other"
    
    @staticmethod
    def filter_emails_batch(
        emails: list["Email"],
        timeout_seconds: float = 45
    ) -> "BatchEmailFilterResponse":
        """
        Filter a batch of emails using AI classification
        
        Args:
            emails: List of Email objects to filter
            timeout_seconds: Total timeout for all classification calls
            
        Returns:
            BatchEmailFilterResponse with organized filtered results
        """
        from app.schemas import FilteredEmail, BatchEmailFilterResponse
        
        logger.info("Starting batch email filtration for %d emails", len(emails))
        filtered_emails: list[FilteredEmail] = []
        started_at = time.monotonic()
        
        for idx, email in enumerate(emails):
            elapsed = time.monotonic() - started_at
            if elapsed >= timeout_seconds:
                logger.warning(
                    "Classification timeout reached after %d/%d emails (%.2fs)",
                    idx,
                    len(emails),
                    elapsed
                )
                break
            
            remaining_budget = timeout_seconds - elapsed
            per_call_timeout = min(20.0, max(5.0, remaining_budget))
            
            try:
                # Extract text and classify using semantic similarity
                text_for_classification = EmailFilterService.extract_text_for_classification(email)
                result = semantic_classify(
                    text_for_classification,
                    TARGET_CATEGORIES
                )
                
                if not result.get("labels") or not result.get("scores"):
                    logger.debug("Email %d: No classification results", idx)
                    continue
                
                top_label = result["labels"][0]
                top_score = result["scores"][0]
                
                # Enhance score with keyword matching
                final_label, final_score = EmailFilterService.calculate_confidence_score(
                    top_label,
                    top_score,
                    email.subject,
                    email.body
                )
                
                # Fallback: if AI score is low but email has strong study keywords, boost it
                text_lower = f"{email.subject} {email.body}".lower()
                if final_score < CONFIDENCE_THRESHOLD:
                    # Check for strong study indicators
                    study_keyword_count = sum(1 for kw in EmailFilterService.STUDY_KEYWORDS if kw in text_lower)
                    class_keyword_count = sum(1 for kw in EmailFilterService.CLASS_KEYWORDS if kw in text_lower)
                    assign_keyword_count = sum(1 for kw in EmailFilterService.ASSIGNMENT_KEYWORDS if kw in text_lower)
                    exam_keyword_count = sum(1 for kw in EmailFilterService.EXAM_KEYWORDS if kw in text_lower)
                    
                    total_keyword_matches = study_keyword_count + class_keyword_count + assign_keyword_count + exam_keyword_count
                    
                    # If multiple study keywords found, mark as academic
                    if total_keyword_matches >= 2:
                        final_label = "academic"
                        final_score = 0.45  # Above new threshold of 0.35
                        logger.debug(
                            "Email %d: Boosted to 'academic' due to %d keyword matches",
                            idx,
                            total_keyword_matches
                        )
                
                # Only include if confidence exceeds threshold
                if final_score >= CONFIDENCE_THRESHOLD:
                    filtered_email = FilteredEmail(
                        id=email.id,
                        subject=email.subject,
                        sender=email.sender,
                        body=email.body,
                        category=final_label,
                        confidence=round(final_score, 3),
                        date=email.date
                    )
                    filtered_emails.append(filtered_email)
                    logger.debug(
                        "Email %d classified as '%s' (confidence: %.3f)",
                        idx,
                        final_label,
                        final_score
                    )
                else:
                    logger.debug(
                        "Email %d filtered out: confidence %.3f below threshold",
                        idx,
                        final_score
                    )
                    
            except TimeoutError:
                logger.warning("Email %d: Classification timeout", idx)
                continue
            except Exception as e:
                logger.warning("Email %d: Classification error: %s", idx, str(e))
                continue
        
        # Organize filtered emails by category group
        by_category: dict[str, list[FilteredEmail]] = {}
        for email in filtered_emails:
            category_group = EmailFilterService.get_category_group(email.category)
            if category_group not in by_category:
                by_category[category_group] = []
            by_category[category_group].append(email)
        
        logger.info(
            "Batch filtration complete: %d/%d emails filtered",
            len(filtered_emails),
            len(emails)
        )
        
        return BatchEmailFilterResponse(
            success=True,
            filtered_count=len(filtered_emails),
            total_emails=len(emails),
            by_category=by_category,
            all_filtered=sorted(
                filtered_emails,
                key=lambda x: x.confidence,
                reverse=True
            )
        )
