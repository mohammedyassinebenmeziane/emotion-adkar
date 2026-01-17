from transformers import AutoImageProcessor, AutoModelForImageClassification
from PIL import Image
import torch
import torch.nn.functional as F

# Load model and processor globally to avoid reloading on every request
MODEL_NAME = "trpakov/vit-face-expression"

print(f"Loading model: {MODEL_NAME}...")
try:
    processor = AutoImageProcessor.from_pretrained(MODEL_NAME)
    model = AutoModelForImageClassification.from_pretrained(MODEL_NAME)
    print("Model loaded successfully.")
except Exception as e:
    print(f"Error loading model: {e}")
    raise e

def predict_emotion(image: Image.Image):
    """
    Predicts the emotion from a PIL Image.
    Returns a dictionary with the predicted emotion and confidence score.
    """
    inputs = processor(images=image, return_tensors="pt")
    
    with torch.no_grad():
        outputs = model(**inputs)
        logits = outputs.logits
        probabilities = F.softmax(logits, dim=-1)
        
    # Get the highest probability
    confidence, predicted_class_idx = torch.max(probabilities, dim=-1)
    predicted_label = model.config.id2label[predicted_class_idx.item()]
    
    return {
        "emotion": predicted_label,
        "confidence": confidence.item()
    }
