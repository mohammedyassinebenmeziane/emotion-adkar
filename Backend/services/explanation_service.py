"""
Service pour générer des explications émotionnelles en français
IMPORTANT: Ce service ne génère JAMAIS de textes sacrés (Quran, Hadith, Douaa)
Les textes sacrés viennent UNIQUEMENT de MongoDB.
Le LLM génère UNIQUEMENT une explication courte (2-3 phrases) expliquant pourquoi le douaa aide émotionnellement.
Rôle du LLM: Accompagnateur émotionnel, PAS autorité religieuse.
"""
import os
import re
from typing import Optional

import requests
from dotenv import load_dotenv

# Charger les variables d'environnement depuis .env
load_dotenv()

# Configuration API Hugging Face (gratuite mais limitée)
ENABLE_LLM = os.getenv("ENABLE_LLM_EXPLANATION", "true").lower() == "true"

# OpenRouter Configuration (RECOMMENDED)
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "").strip()
OPENROUTER_MODEL = os.getenv("OPENROUTER_MODEL", "mistralai/mistral-7b-instruct:free")
OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions"

# Hugging Face Configuration (fallback)
HF_MODEL_NAME = os.getenv("HF_MODEL_NAME", "mistralai/Mistral-7B-Instruct-v0.1")
# Use the serverless inference endpoint with correct format
HF_API_URL = os.getenv("HF_API_URL", f"https://api-inference.huggingface.co/models/{HF_MODEL_NAME}")
HF_TOKEN = os.getenv("HF_TOKEN", "").strip()
HF_TIMEOUT = float(os.getenv("HF_TIMEOUT_SECONDS", "25"))

# Log de configuration au chargement du module
print(f"[EXPLANATION_SERVICE] Configuration LLM:")
print(f"  - ENABLE_LLM: {ENABLE_LLM}")
if OPENROUTER_API_KEY:
    print(f"  - Provider: OpenRouter ✓")
    print(f"  - Model: {OPENROUTER_MODEL}")
else:
    print(f"  - Provider: Hugging Face")
    print(f"  - HF_MODEL_NAME: {HF_MODEL_NAME}")
    print(f"  - HF_TOKEN: {'✓ Configuré' if HF_TOKEN else '✗ Non configuré'}")
print(f"  - HF_TIMEOUT: {HF_TIMEOUT}s")

# Explications pré-définies en français comme fallback (améliorées pour plus de profondeur spirituelle)
FRENCH_EXPLANATIONS = {
    "happy": "Ce douaa vous aide à exprimer votre gratitude envers Allah et à maintenir cette sensation de paix intérieure. Il renforce votre connexion spirituelle, vous rappelle que le bonheur véritable vient de la foi, et vous permet de savourer pleinement ce moment de joie tout en restant humble.",
    "sad": "Ce douaa vous apporte réconfort et apaisement dans les moments difficiles. Il vous rappelle que vous n'êtes jamais seul, qu'Allah est toujours avec vous, et que la patience (sabr) et la foi peuvent transformer la tristesse en force intérieure et en rapprochement spirituel.",
    "angry": "Ce douaa vous aide à calmer votre colère et à retrouver votre sérénité. Il vous guide vers la patience, le pardon et la compréhension, transformant les émotions négatives en énergie positive. La maîtrise de soi dans la colère est une forme de force spirituelle.",
    "fear": "Ce douaa vous apporte protection divine et courage face à vos peurs. Il renforce votre confiance en Allah, vous rappelle que vous avez la force intérieure nécessaire pour surmonter vos craintes, et que la foi est le meilleur remède contre l'anxiété.",
    "neutral": "Ce douaa vous aide à maintenir votre équilibre émotionnel et votre paix intérieure. Il renforce votre connexion spirituelle avec Allah, vous permet de rester centré dans le moment présent, et cultive un état de sérénité et de gratitude constante.",
    "surprised": "Ce douaa vous aide à accueillir l'inattendu avec sérénité et gratitude. Il vous rappelle que tout ce qui arrive est par la volonté d'Allah, et vous guide pour transformer la surprise en opportunité de croissance spirituelle et de renforcement de votre foi.",
    "anxious": "Ce douaa vous apporte calme et tranquillité dans les moments d'anxiété. Il vous aide à lâcher prise, à faire confiance en Allah, et à vous rappeler que Lui seul contrôle l'avenir. La récitation régulière réduit le stress et apporte la paix du cœur.",
    "excited": "Ce douaa vous aide à canaliser votre enthousiasme de manière positive et spirituelle. Il vous rappelle de rester humble dans la joie, de partager votre bonheur avec gratitude, et de diriger votre énergie vers des actions qui plaisent à Allah.",
    "lonely": "Ce douaa vous rappelle que vous êtes toujours accompagné spirituellement par Allah. Il vous apporte réconfort, vous aide à ressentir la présence divine dans votre vie, et transforme la solitude en moment privilégié de connexion spirituelle et de méditation.",
    "grateful": "Ce douaa renforce votre sentiment de gratitude envers Allah et vous aide à exprimer votre reconnaissance pour Ses innombrables bienfaits. Il vous permet de savourer pleinement les bénédictions de votre vie et vous rappelle que la gratitude attire davantage de bénédictions.",
    "hopeful": "Ce douaa renforce votre espoir et votre foi en l'avenir. Il vous rappelle qu'Allah a un plan pour chacun, que chaque jour apporte de nouvelles possibilités, et que la patience et la confiance en Lui portent toujours leurs fruits."
}

EMOTION_FRENCH = {
    "happy": "joie",
    "sad": "tristesse",
    "angry": "colère",
    "fear": "peur",
    "neutral": "calme",
    "surprised": "surprise",
    "anxious": "anxiété",
    "excited": "excitation",
    "lonely": "solitude",
    "grateful": "gratitude",
    "hopeful": "espoir",
}


def _confidence_percent(confidence: Optional[float]) -> Optional[float]:
    if confidence is None:
        return None
    return confidence * 100 if confidence <= 1 else confidence


def _build_prompt(emotion: str, confidence: Optional[float], douaa: str) -> str:
    emotion_fr = EMOTION_FRENCH.get(emotion.lower(), "cette émotion")
    conf_pct = _confidence_percent(confidence)
    conf_text = f"{conf_pct:.1f}%" if conf_pct is not None else "non précisée"
    
    # Déterminer le ton selon la confiance
    if conf_pct is None or conf_pct < 55:
        ton_instruction = "prudent et nuancé"
    elif conf_pct < 80:
        ton_instruction = "affirmé mais nuancé"
    else:
        ton_instruction = "confiant"
    
    return f"""Génère une explication émotionnelle courte (2-3 phrases) en français uniquement.

Émotion détectée: {emotion_fr} (confiance: {conf_text})
Ton: {ton_instruction}

Instructions:
- Explique comment cette invocation spirituelle peut aider avec cette émotion
- Ne cite PAS le douaa, ne génère AUCUN texte sacré
- Utilise un langage naturel et chaleureux
- Réponds UNIQUEMENT avec l'explication, sans préambule ni instruction

Explication:"""


def _call_hf_api(prompt: str, retry_on_503: bool = True) -> str:
    """
    Appelle l'API OpenRouter ou Hugging Face pour générer du texte.
    
    Args:
        prompt: Le prompt à envoyer au modèle
        retry_on_503: Si True, attendre et réessayer si le modèle est en cours de chargement (503)
    
    Returns:
        str: Le texte généré par le modèle
    """
    import time
    
    # Try OpenRouter first if configured
    if OPENROUTER_API_KEY:
        return _call_openrouter_api(prompt, retry_on_503)
    
    # Fallback to Hugging Face
    return _call_hf_api_direct(prompt, retry_on_503)


def _call_openrouter_api(prompt: str, retry_on_503: bool = True) -> str:
    """Appelle l'API OpenRouter."""
    import time
    
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }
    
    payload = {
        "model": OPENROUTER_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7,
        "top_p": 0.9,
        "max_tokens": 150,
    }
    
    max_retries = 2 if retry_on_503 else 0
    retry_delay = 10
    
    for attempt in range(max_retries + 1):
        try:
            print(f"[DEBUG] Appel OpenRouter API (tentative {attempt + 1}/{max_retries + 1})...")
            resp = requests.post(
                OPENROUTER_API_URL,
                headers=headers,
                json=payload,
                timeout=HF_TIMEOUT,
            )
            
            if resp.status_code == 503:
                if retry_on_503 and attempt < max_retries:
                    print(f"[INFO] Service indisponible. Attente de {retry_delay}s...")
                    time.sleep(retry_delay)
                    continue
                else:
                    raise RuntimeError(f"OpenRouter: Service indisponible (503)")
            elif resp.status_code == 401:
                raise RuntimeError(f"OpenRouter: Erreur d'authentification (401). Vérifiez OPENROUTER_API_KEY.")
            elif resp.status_code != 200:
                error_text = resp.text[:300] if resp.text else "Unknown error"
                raise RuntimeError(f"OpenRouter error {resp.status_code}: {error_text}")
            
            break
            
        except requests.exceptions.Timeout:
            raise RuntimeError(f"Timeout OpenRouter (>{HF_TIMEOUT}s)")
        except requests.exceptions.RequestException as e:
            raise RuntimeError(f"Erreur réseau OpenRouter: {str(e)}")
    
    data = resp.json()
    
    # OpenRouter uses standard OpenAI format
    if "choices" in data and data["choices"]:
        text = data["choices"][0].get("message", {}).get("content", "").strip()
    elif "error" in data:
        raise RuntimeError(f"OpenRouter error: {data['error'].get('message', 'Unknown error')}")
    else:
        raise RuntimeError(f"OpenRouter unexpected response: {str(data)[:300]}")
    
    return text


def _call_hf_api_direct(prompt: str, retry_on_503: bool = True) -> str:
    """Appelle l'API Hugging Face directement."""
    import time
    
    headers = {"Authorization": f"Bearer {HF_TOKEN}"} if HF_TOKEN else {}
    payload = {
        "inputs": prompt,
        "parameters": {
            "max_new_tokens": 150,
            "temperature": 0.7,
            "top_p": 0.9,
        },
    }
    
    max_retries = 2 if retry_on_503 else 0
    retry_delay = 10  # secondes
    
    for attempt in range(max_retries + 1):
        try:
            print(f"[DEBUG] Appel API Hugging Face (tentative {attempt + 1}/{max_retries + 1})...")
            resp = requests.post(
                HF_API_URL,
                headers=headers,
                json=payload,
                timeout=HF_TIMEOUT,
            )
            
            # Gérer les erreurs spécifiques de l'API Hugging Face
            if resp.status_code == 503:
                # Le modèle est en train de se charger
                try:
                    error_data = resp.json()
                    error_msg = error_data.get("error", "Model is loading")
                    estimated_time = error_data.get("estimated_time", None)
                except:
                    error_msg = "Model is loading"
                    estimated_time = None
                
                if retry_on_503 and attempt < max_retries:
                    wait_time = estimated_time if estimated_time else retry_delay
                    print(f"[INFO] Modèle en cours de chargement. Attente de {wait_time}s avant réessai...")
                    time.sleep(wait_time)
                    continue
                else:
                    raise RuntimeError(f"HF API: Modèle en cours de chargement. {error_msg}")
            elif resp.status_code == 401:
                error_text = resp.text[:300] if resp.text else "Unauthorized"
                raise RuntimeError(f"HF API: Erreur d'authentification (401). Vérifiez votre token. {error_text}")
            elif resp.status_code == 410:
                error_text = resp.text[:300] if resp.text else "API deprecated"
                raise RuntimeError(f"HF API: Endpoint deprecated (410). Mettez à jour HF_API_URL. {error_text}")
            elif resp.status_code != 200:
                error_text = resp.text[:300] if resp.text else "Unknown error"
                raise RuntimeError(f"HF API error {resp.status_code}: {error_text}")
            
            # Succès
            break
            
        except requests.exceptions.Timeout:
            raise RuntimeError(f"Timeout lors de l'appel à l'API Hugging Face (>{HF_TIMEOUT}s)")
        except requests.exceptions.RequestException as e:
            raise RuntimeError(f"Erreur réseau lors de l'appel à l'API Hugging Face: {str(e)}")

    data = resp.json()
    
    # Gérer différents formats de réponse
    if isinstance(data, list) and data:
        text = data[0].get("generated_text", "")
        # Extraire seulement la partie générée (sans le prompt)
        if prompt in text:
            text = text.replace(prompt, "").strip()
    elif isinstance(data, dict):
        if "generated_text" in data:
            text = data["generated_text"]
            # Extraire seulement la partie générée (sans le prompt)
            if prompt in text:
                text = text.replace(prompt, "").strip()
        elif "error" in data:
            raise RuntimeError(f"HF API error: {data['error']}")
        else:
            raise RuntimeError(f"HF API unexpected payload: {str(data)[:300]}")
    else:
        raise RuntimeError(f"HF API unexpected payload: {str(data)[:300]}")

    return text.strip()


def _normalize_text(explanation: str) -> str:
    if not explanation:
        return ""

    sentences = []
    for sep in [".", "!", "?", "\n"]:
        if sep in explanation:
            sentences = [s.strip() for s in explanation.split(sep) if s.strip()]
            break

    if not sentences:
        sentences = [explanation.strip()] if explanation.strip() else []

    if sentences:
        explanation = ". ".join(sentences[:3]).strip()
        if explanation and not explanation.endswith((".", "!", "?")):
            explanation += "."
    else:
        explanation = ""

    return explanation


def _is_invalid(explanation: str) -> tuple[bool, list[str]]:
    reasons = []
    exp_lower = explanation.lower()

    if len(explanation.strip()) < 20:
        reasons.append("trop court")
    if not explanation.strip():
        reasons.append("vide")

    has_arabic = bool(re.search(r"[\u0600-\u06FF]", explanation))
    if has_arabic:
        reasons.append("texte arabe détecté")

    verse_markers = ["sourate", "ayah", "verset", "quran", "coran", "سورة", "آية"]
    if any(marker in exp_lower for marker in verse_markers):
        reasons.append("marqueurs de versets détectés")

    instruction_words = [
        "explique",
        "parle",
        "réponds",
        "uniquement",
        "français",
        "phrases",
        "court",
        "simplement",
        "comment",
        "une personne ressent",
    ]
    if any(exp_lower.strip().startswith(word) for word in instruction_words):
        reasons.append("débute par instruction")

    instruction_count = sum(1 for word in instruction_words if word in exp_lower)
    if instruction_count >= 3:
        reasons.append("instructions répétées")

    if "une personne ressent de la" in exp_lower:
        reasons.append("prompt répété")

    return len(reasons) > 0, reasons


def _dynamic_fallback(emotion: str, confidence: Optional[float]) -> str:
    base = FRENCH_EXPLANATIONS.get(emotion.lower(), FRENCH_EXPLANATIONS["neutral"])
    emotion_fr = EMOTION_FRENCH.get(emotion.lower(), emotion.lower())
    conf_pct = _confidence_percent(confidence)
    conf_text = f"{conf_pct:.1f}%" if conf_pct is not None else "confiance non précisée"

    if conf_pct is None:
        ton = "prudent"
        signal = "non précisé"
    elif conf_pct < 55:
        ton = "prudent"
        signal = "modéré"
    elif conf_pct < 80:
        ton = "affirmé mais nuancé"
        signal = "assez clair"
    else:
        ton = "confiant"
        signal = "net"

    return (
        f"Je perçois surtout de la {emotion_fr} ({conf_text}). "
        f"Le ton reste {ton} car le signal est {signal}. "
        f"{base}"
    )


def get_fallback_explanation(emotion: str, confidence: Optional[float] = None) -> str:
    """
    Fonction publique pour obtenir une explication de fallback avec la confiance.
    
    Args:
        emotion: L'émotion détectée
        confidence: Score de confiance du modèle d'émotion
    
    Returns:
        str: Explication de fallback en français
    """
    return _dynamic_fallback(emotion, confidence)


def generate_explanation(emotion: str, douaa: str, confidence: Optional[float] = None) -> tuple[str, str]:
    """
    Génère une explication courte en français expliquant pourquoi le Douaa aide avec l'émotion.
    
    RÈGLES IMPORTANTES:
    - Ne JAMAIS générer de textes sacrés (Quran, Hadith, Douaa) - ils viennent de MongoDB
    - Générer UNIQUEMENT une explication émotionnelle/psychologique (2-3 phrases)
    - Réponse en FRANÇAIS uniquement
    - Rôle: Accompagnateur émotionnel, PAS autorité religieuse
    
    Args:
        emotion: L'émotion détectée (ex: "happy", "sad", "angry")
        douaa: Le douaa sélectionné depuis la base de données (pour contexte uniquement)
        confidence: Score de confiance du modèle d'émotion (0-100 ou 0-1)
    
    Returns:
        tuple[str, str]: (explication en français, source) où source est "llm" ou "static"
    """
    if not ENABLE_LLM:
        print(f"[INFO] LLM désactivé (ENABLE_LLM_EXPLANATION=false). Utilisation du fallback statique.")
        explanation = _dynamic_fallback(emotion, confidence)
        return explanation, "static"

    print(f"[INFO] Tentative de génération LLM pour émotion: {emotion}, confiance: {confidence}")
    
    try:
        prompt = _build_prompt(emotion, confidence, douaa)
        print(f"[DEBUG] Prompt construit: {prompt[:100]}...")
        
        raw_text = _call_hf_api(prompt)
        print(f"[DEBUG] Réponse brute LLM: '{raw_text[:150]}...'")
        
        explanation = _normalize_text(raw_text)
        print(f"[DEBUG] Explication normalisée: '{explanation[:150]}...'")

        is_invalid, reasons = _is_invalid(explanation)
        if is_invalid:
            print(f"[WARN] Réponse LLM rejetée ({', '.join(reasons)}). Utilisation du fallback dynamique.")
            print(f"   Réponse LLM complète: '{explanation}'")
            explanation = _dynamic_fallback(emotion, confidence)
            return explanation, "static"

        print(f"[OK] Explication LLM générée avec succès: '{explanation[:80]}...'")
        return explanation, "llm"

    except RuntimeError as e:
        error_msg = str(e)
        print(f"[WARN] Erreur API Hugging Face: {error_msg}")
        if "401" in error_msg or "authentification" in error_msg.lower():
            print(f"[ERROR] ⚠️  Problème d'authentification! Vérifiez que HF_TOKEN est correct dans .env")
            print(f"[INFO] 💡 Alternative: Utilisez OpenRouter pour une API plus fiable")
        elif "503" in error_msg or "chargement" in error_msg.lower():
            print(f"[INFO] Le modèle est en cours de chargement. Réessayez dans quelques secondes.")
        elif "410" in error_msg or "deprecated" in error_msg.lower():
            print(f"[ERROR] ⚠️  L'endpoint Hugging Face a changé. Vérifiez HF_API_URL dans .env")
            print(f"[INFO] 💡 Alternative: Utilisez https://router.huggingface.co ou OpenRouter")
        else:
            print(f"[WARN] Erreur LLM: {error_msg}")
        explanation = _dynamic_fallback(emotion, confidence)
        return explanation, "static"
    except Exception as e:
        print(f"[WARN] Erreur inattendue lors de la génération de l'explication LLM: {type(e).__name__}: {e}")
        import traceback
        print(f"[DEBUG] Traceback complet:\n{traceback.format_exc()}")
        explanation = _dynamic_fallback(emotion, confidence)
        return explanation, "static"

