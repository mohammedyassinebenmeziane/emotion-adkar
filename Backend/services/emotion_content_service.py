import random
from db.mongo import db

emotion_content_collection = db["emotion_content"]

# Mapping des émotions du modèle ML vers les émotions dans la base de données
# Toutes les clés sont en minuscules pour normaliser la casse
EMOTION_MAPPING = {
    "happy": "happy",
    "sad": "sad",
    "angry": "angry",
    "fear": "fear",
    "surprise": "surprised",
    "neutral": "neutral",
    "disgust": "sad",  # Map disgust to sad
    "contempt": "sad",  # Map contempt to sad
    # Si l'émotion n'est pas détectée, on peut utiliser des émotions par défaut
    # ou mapper vers neutral
}

# Cache pour les émotions disponibles afin d'éviter des appels DB répétitifs
_AVAILABLE_EMOTIONS_CACHE = None

async def get_emotion_content(emotion: str):
    """
    Récupère un douaa et un ayah aléatoires basés sur l'émotion détectée.
    
    Args:
        emotion: L'émotion détectée par le modèle ML (ex: "happy", "sad", etc.)
    
    Returns:
        dict: Un dictionnaire contenant:
            - douaa: Un douaa aléatoire pour cette émotion
            - ayah: Un verset coranique aléatoire pour cette émotion
            - emotion: L'émotion mappée utilisée
    """
    global _AVAILABLE_EMOTIONS_CACHE
    
    # Normaliser l'émotion en minuscules pour éviter les problèmes de casse
    emotion_lower = emotion.lower().strip() if emotion else "neutral"
    
    # Mapper l'émotion du modèle vers l'émotion dans la base de données
    mapped_emotion = EMOTION_MAPPING.get(emotion_lower, "neutral")
    
    print(f"[DEBUG] Emotion originale='{emotion}' -> normalisee='{emotion_lower}' -> mappee='{mapped_emotion}'")
    
    try:
        # Récupérer les émotions disponibles une seule fois (ou périodiquement)
        if _AVAILABLE_EMOTIONS_CACHE is None:
            _AVAILABLE_EMOTIONS_CACHE = await emotion_content_collection.distinct("emotion")
            print(f"[DEBUG] Emotions disponibles dans la BD (Mise en cache): {_AVAILABLE_EMOTIONS_CACHE}")
            
            if not _AVAILABLE_EMOTIONS_CACHE:
                print(f"[WARN] Avertissement: La collection 'emotion_content' semble vide ou sans émotions.")
        
        # S'assurer que mapped_emotion est en minuscules pour la recherche
        search_emotion = mapped_emotion.lower()
        
        # Récupérer un douaa aléatoire
        douaa_doc = await emotion_content_collection.find_one(
            {"emotion": search_emotion, "type": "douaa"}
        )
        
        # Récupérer un verset coranique aléatoire
        ayah_doc = await emotion_content_collection.find_one(
            {"emotion": search_emotion, "type": "quran"}
        )
        
        douaa = None
        ayah = None
        
        if douaa_doc and "content" in douaa_doc and len(douaa_doc["content"]) > 0:
            # Sélectionner un douaa aléatoire
            douaa = random.choice(douaa_doc["content"])
            print(f"[OK] Douaa trouve pour '{mapped_emotion}'")
        else:
            print(f"[WARN] Aucun douaa trouve pour l'emotion: '{mapped_emotion}' (doc trouve: {douaa_doc is not None})")
        
        if ayah_doc and "content" in ayah_doc and len(ayah_doc["content"]) > 0:
            # Sélectionner un verset coranique aléatoire
            ayah = random.choice(ayah_doc["content"])
            print(f"[OK] Ayah trouve pour '{mapped_emotion}'")
        else:
            print(f"[WARN] Aucun ayah trouve pour l'emotion: '{mapped_emotion}' (doc trouve: {ayah_doc is not None})")
        
        return {
            "douaa": douaa,
            "ayah": ayah,
            "emotion": mapped_emotion,
            "original_emotion": emotion
        }
    except Exception as e:
        print(f"❌ Erreur lors de la récupération du contenu: {e}")
        import traceback
        traceback.print_exc()
        return {
            "douaa": None,
            "ayah": None,
            "emotion": mapped_emotion,
            "original_emotion": emotion,
            "error": str(e)
        }

