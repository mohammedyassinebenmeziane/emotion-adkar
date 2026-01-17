from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from auth.auth_router import router as auth_router, get_current_user
from models.user_model import UserOut

app = FastAPI(title="Emotion Adkar Backend")

@app.on_event("startup")
async def startup_event():
    print("\n" + "="*50)
    print("[START] Serveur en cours de demarrage...")
    print("[LOAD] Chargement des modeles ML (cela peut prendre quelques secondes)...")
    # Importer le modèle ici déclenchera le chargement s'il ne l'est pas déjà
    from ml.emotion_model import MODEL_NAME
    print(f"[OK] Modele ML '{MODEL_NAME}' charge avec succes!")
    print("[READY] Le serveur est maintenant pret a recevoir des requetes.")
    print("="*50 + "\n")

# Enable CORS
origins = ["*"]  # Allow all origins for Flutter app

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Auth Router
app.include_router(auth_router)

# Include Emotion Router
from routes.emotion_routes import router as emotion_router
app.include_router(emotion_router)

# Include Chat Router
from routes.chat import router as chat_router
app.include_router(chat_router)


@app.get("/")
async def root():
    return {"message": "Welcome to Emotion Adkar Backend"}

@app.get("/me", response_model=UserOut)
async def read_users_me(current_user: UserOut = Depends(get_current_user)):
    return current_user
