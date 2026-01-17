import os
import httpx
from typing import List, Dict
from schemas.chat_schema import Message


class LLMService:
    """
    Service pour communiquer avec OpenRouter LLM API.
    Gère les appels au LLM sans exposer la clé API au frontend.
    """

    def __init__(self):
        # Récupérer la clé API OpenRouter depuis les variables d'environnement
        self.api_key = os.getenv("OPENROUTER_API_KEY")
        if not self.api_key:
            raise ValueError("OPENROUTER_API_KEY not found in environment variables")

        self.api_url = "https://openrouter.ai/api/v1/chat/completions"
        # Récupérer le modèle depuis l'env, avec un default fiable
        self.model = os.getenv("OPENROUTER_MODEL", "mistralai/mistral-7b-instruct:free")

        # Prompt système qui définit le comportement de DhikrAI
        self.system_prompt = (
            "Tu es DhikrAI, un assistant bienveillant et apaisant. "
            "Tu aides l'utilisateur à se sentir mieux avec des mots simples et réconfortants. "
            "Tu ne fais JAMAIS de diagnostic médical ou psychologique. "
            "Tu proposes parfois de petits exercices de respiration ou de courtes prières inspirées de l'islam. "
            "Tes réponses sont courtes (1 à 3 phrases max), douce et rassurante. "
            "Tu communiques comme dans un SMS ou WhatsApp - naturel et direct."
        )

    async def chat(self, user_message: str, history: List[Message]) -> str:
        """
        Envoie un message au LLM et retourne la réponse.

        Args:
            user_message: Le message de l'utilisateur
            history: L'historique des messages précédents

        Returns:
            La réponse de l'assistant
        """
        try:
            # Construire la liste des messages avec le system prompt
            messages = [{"role": "system", "content": self.system_prompt}]

            # Ajouter l'historique des messages précédents
            for msg in history:
                messages.append({"role": msg.role, "content": msg.content})

            # Ajouter le nouveau message de l'utilisateur
            messages.append({"role": "user", "content": user_message})

            # Préparer la requête pour OpenRouter
            headers = {
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            }

            payload = {
                "model": self.model,
                "messages": messages,
                "temperature": 0.7,  # Un peu de créativité mais cohérent
                "max_tokens": 150,  # Réponses courtes
                "top_p": 0.9,
            }

            # Appel asynchrone à OpenRouter
            print(f"[DEBUG] Calling OpenRouter with model: {self.model}")
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(self.api_url, json=payload, headers=headers)
                print(f"[DEBUG] OpenRouter response status: {response.status_code}")
                response.raise_for_status()

            # Extraire la réponse
            data = response.json()
            print(f"[DEBUG] OpenRouter response data: {data}")
            assistant_response = data["choices"][0]["message"]["content"].strip()
            
            # Nettoyer les artifacts du modèle
            # Supprimer les balises de modèle
            assistant_response = assistant_response.replace("<s>", "").replace("</s>", "").strip()
            
            # Supprimer les patterns "### Prompt" ou "### prompt" et tout après
            import re
            assistant_response = re.sub(r'###\s*[Pp]rompt.*', '', assistant_response).strip()
            
            # Supprimer les patterns de tokens internes
            assistant_response = re.sub(r'\[INST\]|\[/INST\]', '', assistant_response).strip()
            
            # Supprimer les lignes de séparation (---) et tout après
            assistant_response = re.sub(r'\n-{3,}.*', '', assistant_response, flags=re.DOTALL).strip()
            
            # Supprimer les patterns **Utilisateur**: et tout après
            assistant_response = re.sub(r'\n\*\*[Uu]tilisateur\*\*:.*', '', assistant_response, flags=re.DOTALL).strip()
            
            # Supprimer les lignes vides multiples
            assistant_response = re.sub(r'\n\s*\n+', '\n', assistant_response).strip()

            return assistant_response

        except httpx.HTTPError as e:
            # Gestion des erreurs HTTP
            print(f"[ERROR] HTTPError in LLM service: {e}")
            if hasattr(e, 'response'):
                print(f"[ERROR] Response status: {e.response.status_code}")
                print(f"[ERROR] Response body: {e.response.text}")
            return (
                "Je suis temporairement indisponible. Prends soin de toi. 🌙"
            )
        except Exception as e:
            # Gestion des autres erreurs
            print(f"[ERROR] Error in LLM service: {e}")
            import traceback
            traceback.print_exc()
            return "Une erreur est survenue. Réessaye plus tard, s'il te plaît. 💙"
