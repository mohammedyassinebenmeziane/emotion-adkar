from pydantic import BaseModel
from typing import List, Literal

# Schéma pour un message dans l'historique
class Message(BaseModel):
    role: Literal["user", "assistant"]
    content: str


# Schéma pour la requête de chat
class ChatRequest(BaseModel):
    message: str
    history: List[Message] = []


# Schéma pour la réponse de chat
class ChatResponse(BaseModel):
    response: str
    role: str = "assistant"
