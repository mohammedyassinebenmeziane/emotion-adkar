from PIL import Image
import io
from ml.emotion_model import predict_emotion
from services.emotion_content_service import get_emotion_content
from services.explanation_service import generate_explanation, get_fallback_explanation
from utils.text_utils import parse_ayah

import anyio

async def analyze_emotion(file_bytes: bytes):
    """
    Process image bytes and return emotion prediction with personalized douaa, ayah, and AI explanation.
    Returns restructured format with ayah_text, ayah_reference, and explanation_fr.
    """
    try:
        # Convert bytes to PIL Image
        # This is fast, but we could also offload if needed
        image = Image.open(io.BytesIO(file_bytes)).convert("RGB")
        
        # Get prediction from ML model - Offload to thread
        emotion_result = await anyio.to_thread.run_sync(predict_emotion, image)
        
        # Récupérer le douaa et l'ayah basés sur l'émotion détectée
        emotion = emotion_result.get("emotion", "neutral")
        confidence = emotion_result.get("confidence")
        content = await get_emotion_content(emotion)
        
        # Parse ayah into text and reference
        ayah_full = content.get("ayah")
        ayah_parsed = parse_ayah(ayah_full)
        
        # Generate contextual explanation with LLM (based on specific Douaa)
        explanation_fr = None
        explanation_source = "static"
        douaa = content.get("douaa")
        if douaa:
            try:
                # Generate contextual explanation using the specific Douaa
                # Offload to thread since it involves LLM inference
                explanation_fr, explanation_source = await anyio.to_thread.run_sync(
                    generate_explanation, emotion, douaa, confidence
                )
            except Exception as e:
                print(f"[WARN] Erreur lors de la generation de l'explication LLM dans emotion_service: {e}")
                # Fallback to dynamic explanation with confidence
                explanation_fr = get_fallback_explanation(emotion, confidence)
                explanation_source = "static"
        else:
            # No douaa, use dynamic fallback with confidence
            explanation_fr = get_fallback_explanation(emotion, confidence)
            explanation_source = "static"
        
        # Combiner les résultats avec le nouveau format
        result = {
            "emotion": emotion_result.get("emotion"),
            "confidence": emotion_result.get("confidence"),
            "douaa": douaa,
            "ayah_text": ayah_parsed["text"],
            "ayah_reference": ayah_parsed["reference"],
            "explanation_fr": explanation_fr,
            "explanation_source": explanation_source
        }
        
        return result
    except Exception as e:
        print(f"Error in analyze_emotion: {e}")
        raise e
