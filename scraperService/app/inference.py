
from app.model import ZeroShotEmailClassifier

classifier = ZeroShotEmailClassifier()

# Define your target categories here
TARGET_CATEGORIES = ["important", "todo", "meeting", "event", "assignment", "exam", "notice", "class"]

def classify_and_filter_emails(emails):
    filtered = []
    for email in emails:
        label, confidence = classifier.predict(email)
        if label in TARGET_CATEGORIES:
            filtered.append({
                "text": email,
                "label": label,
                "confidence": confidence
            })
    return filtered
