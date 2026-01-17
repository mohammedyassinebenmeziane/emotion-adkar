from fastapi import APIRouter, HTTPException
from schemas.chat_schema import ChatRequest, ChatResponse
from services.llm_service import LLMService

# Initialiser le router
router = APIRouter(prefix="/api/chat", tags=["chat"])

# Initialiser le service LLM
llm_service = LLMService()


@router.post("/", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Endpoint POST pour envoyer un message au LLM et recevoir une réponse.

    Request body:
    {
        "message": "Je me sens triste",
        "history": [
            {"role": "user", "content": "Bonjour"},
            {"role": "assistant", "content": "Bonjour! Comment vas-tu aujourd'hui?"}
        ]
    }

    Response:
    {
        "response": "Je suis là pour toi. Veux-tu en parler?",
        "role": "assistant"
    }
    """
    try:
        # Valider que le message n'est pas vide
        if not request.message or not request.message.strip():
            raise HTTPException(status_code=400, detail="Le message ne peut pas être vide")

        # Appeler le service LLM avec le message et l'historique
        response = await llm_service.chat(request.message, request.history)

        # Retourner la réponse
        return ChatResponse(response=response, role="assistant")

    except HTTPException as e:
        # Re-lancer les HTTP exceptions
        raise e
    except Exception as e:
        # Log et retourner une erreur générique
        print(f"Error in chat endpoint: {e}")
        raise HTTPException(
            status_code=500, detail="Une erreur est survenue lors du traitement."
        )
