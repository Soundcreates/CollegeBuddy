from transformers import pipeline
from huggingface_hub import login

class ZeroShotEmailClassifier:
    def __init__(self):
        self.labels = [
            "assignment related email",
            "exam related email",
            "official notification or announcement",
            "other general email"
        ]

        self.classifier = pipeline(
            "zero-shot-classification",
            model="facebook/bart-large-mnli"
        )

    def predict(self, text: str):
        result = self.classifier(
            text,
            self.labels,
            multi_label=False
        )

        top_label = result["labels"][0]
        score = result["scores"][0]

        # map verbose labels → clean labels
        label_map = {
            "assignment related email": "assignment",
            "exam related email": "exam",
            "official notification or announcement": "notification",
            "other general email": "other"
        }

        return label_map[top_label], float(score)
