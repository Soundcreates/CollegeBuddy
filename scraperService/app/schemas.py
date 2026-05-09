from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class Email(BaseModel):
    id: Optional[str] = None
    subject: str
    sender: str
    body: str
    date: Optional[str] = None
    raw_email: Optional[str] = None

class TextClassificationRequest(BaseModel):
    text: list[str]

class BatchEmailFilterRequest(BaseModel):
    emails: list[Email]
    date: Optional[str] = None  # Date for the batch (YYYY-MM-DD format)

class FilteredEmail(BaseModel):
    id: Optional[str] = None
    subject: str
    sender: str
    body: str
    category: str
    confidence: float
    date: Optional[str] = None

class BatchEmailFilterResponse(BaseModel):
    success: bool
    date: Optional[str] = None
    total_emails: int
    filtered_count: int
    by_category: dict[str, list[FilteredEmail]]  # Organized by category
    all_filtered: list[FilteredEmail]  # Flat list of all filtered emails
    
    class Config:
        # Allow serialization of this response
        json_encoders = {
            datetime: lambda v: v.isoformat() if v else None
        }

