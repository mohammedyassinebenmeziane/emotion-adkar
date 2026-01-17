# 🌙 Emotion Adkār - Vue d'ensemble du Projet

## 📊 Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Technologies Utilisées](#technologies-utilisées)
3. [Architecture Système](#architecture-système)
4. [Flux de Communication](#flux-de-communication)
5. [Modèles LLM](#modèles-llm)
6. [Structure du Projet](#structure-du-projet)

---

## 🎯 Vue d'ensemble

**Emotion Adkār** est une application mobile holistique qui combine:
- 🎨 **Détection d'émotions par IA** (vision par ordinateur)
- 📿 **Contenu spirituel personnalisé** (Douaa, versets coraniques)
- 💬 **Assistant IA conversationnel** (DhikrAI)
- 🧠 **Explications générées par LLM**

**Objectif**: Aider les utilisateurs à gérer leurs émotions avec du contenu spirituel adapté et un soutien bienveillant via un assistant IA.

---

## 🛠️ Technologies Utilisées

### **Frontend (Application Mobile)**
```
Framework: Flutter 3.5.4+
Langage: Dart
UI/UX:
  - Material Design 3
  - Gradients personnalisés
  - Animations fluides
  - Chat UI moderne (WhatsApp-style)

Packages clés:
  - http: 1.2.2 (API HTTP)
  - camera: 0.11.0+2 (Capture selfie)
  - image: 4.3.0 (Traitement image)
  - flutter_secure_storage: 9.2.2 (Stockage sécurisé tokens)
  - path_provider: 2.1.5 (Gestion fichiers)
```

### **Backend (API REST)**
```
Framework: FastAPI (Python 3.11+)
Serveur: Uvicorn
Architecture: Async/Await

Packages clés:
  - fastapi: Framework web asynchrone
  - uvicorn: Serveur ASGI
  - pydantic: Validation schemas
  - motor: Driver MongoDB asynchrone
  - httpx: Client HTTP asynchrone
  - python-multipart: Upload fichiers
  - python-jose: JWT tokens
  - passlib: Hash passwords
  - transformers: HuggingFace models
  - torch: Deep Learning

Modèle ML:
  - trpakov/vit-face-expression (Vision Transformer)
```

### **Base de Données**
```
MongoDB (NoSQL)
  - Collections: users, emotions_data, chats
  - Gestion asynchrone via Motor
  - Authentification JWT + MongoDB
```

### **Services d'IA Externes**
```
OpenRouter API
  - Endpoint: https://openrouter.ai/api/v1/chat/completions
  - Multiplex LLM models
  - Fallback automatique
  - Rate limiting intégré
```

---

## 🏗️ Architecture Système

### **Architecture Multi-Couches**

```
┌─────────────────────────────────────────────────────────┐
│                   FLUTTER MOBILE APP                     │
│  (Détection émotions, Chat, Affichage résultats)        │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST
                     ▼
┌─────────────────────────────────────────────────────────┐
│              FASTAPI BACKEND (Python)                    │
│  ┌─────────────────────────────────────────────────┐    │
│  │  API Routes:                                    │    │
│  │  • POST /emotion/predict (détection)            │    │
│  │  • POST /api/chat/ (conversation LLM)           │    │
│  │  • POST /auth/login (authentification)          │    │
│  │  • POST /auth/register (inscription)            │    │
│  └─────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Services:                                      │    │
│  │  • EmotionService (ML inference)                │    │
│  │  • LLMService (OpenRouter integration)          │    │
│  │  • ExplanationService (LLM explanations)        │    │
│  │  • AuthService (JWT tokens)                     │    │
│  └─────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Schemas (Pydantic):                            │    │
│  │  • ChatMessage, ChatRequest, ChatResponse       │    │
│  │  • EmotionRequest, EmotionResponse              │    │
│  │  • UserLogin, UserRegister                      │    │
│  └─────────────────────────────────────────────────┘    │
└────────────────┬─────────────────────────────────────────┘
                 │
        ┌────────┴────────┬────────────────┐
        ▼                 ▼                ▼
    ┌────────────┐  ┌──────────────┐  ┌──────────────┐
    │  MongoDB   │  │ HuggingFace  │  │ OpenRouter   │
    │  (Données) │  │ (Vision      │  │ (LLM API)    │
    │            │  │  Transformer)│  │              │
    └────────────┘  └──────────────┘  └──────────────┘
```

### **Couches de l'Application**

**1. Couche Présentation (Flutter)**
- Écrans: Login, Home, Camera, Emotion Results, Chat
- Services API: EmotionAPI, ChatService
- Gestion d'état: StatefulWidget, setState

**2. Couche Application (FastAPI Routes)**
- `/emotion/*` - Endpoints détection émotions
- `/api/chat/` - Endpoint conversations
- `/auth/*` - Endpoints authentification

**3. Couche Métier (Services)**
- EmotionService: Inference Vision Transformer
- LLMService: Appels OpenRouter API
- ExplanationService: Génération explanations LLM
- AuthService: JWT + MongoDB auth

**4. Couche Données (MongoDB)**
- Stockage users, tokens, historiques chats
- Collections organisées par entité

---

## 🔄 Flux de Communication

### **1. Flux de Détection d'Émotion**

```
┌─────────────────┐
│ Utilisateur    │
│ Prend selfie   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ Flutter App                         │
│ - Capture image                    │
│ - Compresse image                  │
│ - Prépare multipart form           │
└────────┬────────────────────────────┘
         │ HTTP POST
         │ /emotion/predict + File
         ▼
┌─────────────────────────────────────────────┐
│ FastAPI Backend                             │
│ 1. Reçoit image (multipart)                │
│ 2. Charge modèle ViT (si pas chargé)      │
│ 3. Préprocesse image                       │
│ 4. Inference: image → emotion + confidence │
│ 5. Map émotion (EN → FR)                   │
│ 6. Récupère Douaa (MongoDB)                │
│ 7. Récupère Ayah (MongoDB)                 │
│ 8. Génère explication LLM (OpenRouter)     │
└────────┬────────────────────────────────────┘
         │ JSON Response
         │ {emotion, confidence, douaa, 
         │  ayah, explanation}
         ▼
┌─────────────────────────────────────┐
│ Flutter App                         │
│ - Affiche résultat                 │
│ - Affiche Douaa/Ayah               │
│ - Affiche explication              │
│ - Compteur Douaa interactif        │
└─────────────────────────────────────┘
```

**Temps de réponse**: 2-8 secondes
- Capture: 1s
- Inference ViT: 3-5s
- LLM explanation: 1-3s

### **2. Flux de Chat DhikrAI**

```
┌─────────────────┐
│ Utilisateur     │
│ Tape message    │
└────────┬────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Flutter App (DhikrAIChatScreen)      │
│ - Ajoute message à l'historique     │
│ - Affiche message utilisateur       │
│ - Lance loading indicator           │
│ - Affiche typing animation          │
└────────┬─────────────────────────────┘
         │ HTTP POST
         │ /api/chat/ + message + history
         ▼
┌──────────────────────────────────────────────┐
│ FastAPI Backend (LLMService)                │
│ 1. Reçoit message + historique             │
│ 2. Valide input (non-vide)                 │
│ 3. Construit conversation:                 │
│    - System prompt (DhikrAI personality)   │
│    - Message history                       │
│    - Nouveau message                       │
│ 4. Appel OpenRouter API:                   │
│    POST https://openrouter.ai/api/v1/...  │
│ 5. Nettoie réponse (artifacts)             │
│ 6. Retourne texte nettoyé                  │
└────────┬────────────────────────────────────┘
         │ JSON Response
         │ {response: "texte DhikrAI"}
         ▼
┌──────────────────────────────────────┐
│ Flutter App                          │
│ - Reçoit réponse                    │
│ - Ajoute à l'historique             │
│ - Affiche message assistant         │
│ - Auto-scroll vers bas              │
│ - Lance typing animation            │
└──────────────────────────────────────┘
```

**Temps de réponse**: 2-5 secondes
- Validation: 100ms
- OpenRouter API: 1-4s
- Nettoyage: 100ms

### **3. Flux d'Authentification**

```
┌─────────────────────┐
│ Utilisateur         │
│ Rentre credentials  │
└────────┬────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│ Flutter App (LoginScreen)            │
│ - Valide format email               │
│ - Hash password                     │
│ - POST /auth/login                  │
└────────┬─────────────────────────────┘
         │ HTTP POST
         │ {email, password}
         ▼
┌──────────────────────────────────────────────┐
│ FastAPI Backend (AuthRouter)                │
│ 1. Reçoit credentials                      │
│ 2. Recherche user dans MongoDB             │
│ 3. Vérifie password (passlib)              │
│ 4. Génère JWT token (HS256)                │
│ 5. Retourne token + user data              │
└────────┬────────────────────────────────────┘
         │ JSON Response
         │ {access_token, token_type, user}
         ▼
┌──────────────────────────────────────┐
│ Flutter App                          │
│ - Stocke token (secure storage)     │
│ - Navigue vers HomeScreen           │
└──────────────────────────────────────┘
```

---

## 🤖 Modèles LLM

### **OpenRouter API - Modèles Disponibles**

```
┌────────────────────────────────────────────────────────┐
│ Modèle Actuellement Utilisé                            │
├────────────────────────────────────────────────────────┤
│ mistralai/mistral-7b-instruct:free                     │
│ • Modèle: Mistral 7B (open source)                    │
│ • Paramètres: 7 milliards                            │
│ • Vitesse: ⚡ Très rapide                            │
│ • Qualité: ⭐⭐⭐⭐ Très bonne                         │
│ • Prix: GRATUIT (via OpenRouter)                      │
│ • Use case: Chat DhikrAI principal                   │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ Modèles Alternatifs Disponibles                        │
├────────────────────────────────────────────────────────┤
│ 1. meta-llama/llama-2-7b-chat:free                    │
│    • Facebook/Meta LLaMA 2 7B                        │
│    • Bien adapté au français                         │
│    • Gratuit                                         │
│                                                       │
│ 2. meta-llama/llama-3-8b-instruct:free               │
│    • LLaMA 3 8B (plus récent)                       │
│    • Excellente qualité                             │
│    • Gratuit                                        │
│                                                       │
│ 3. openai/gpt-3.5-turbo                             │
│    • OpenAI GPT-3.5 Turbo                           │
│    • Qualité supérieure                             │
│    • Prix: ~$0.0005 / 1K tokens                     │
│                                                       │
│ 4. anthropic/claude-3-haiku                         │
│    • Anthropic Claude 3 Haiku                       │
│    • Performant pour le français                    │
│    • Prix: ~$0.00025 / 1K tokens                    │
│                                                       │
│ 5. mistralai/mistral-medium                         │
│    • Mistral Medium (meilleure qualité)            │
│    • Excellent pour nuances                        │
│    • Prix: ~$0.00015 / 1K tokens                    │
└────────────────────────────────────────────────────────┘

Configuration Actuelle (dans .env):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPENROUTER_API_KEY=sk-or-v1-...
OPENROUTER_MODEL=mistralai/mistral-7b-instruct:free
```

### **Paramètres LLM Configuration**

```python
# Dans services/llm_service.py

payload = {
    "model": "mistralai/mistral-7b-instruct:free",
    "messages": [
        {"role": "system", "content": system_prompt},
        # ... historique messages
        {"role": "user", "content": user_message}
    ],
    "temperature": 0.7,        # 0.7 = créativité modérée
    "max_tokens": 150,         # Limite réponses courtes
    "top_p": 0.9,             # Variété contrôlée
}
```

### **System Prompt DhikrAI**

```
"Tu es DhikrAI, un assistant bienveillant et apaisant.
Tu aides l'utilisateur à se sentir mieux avec des mots 
simples et réconfortants.

Tu ne fais JAMAIS de diagnostic médical ou psychologique.

Tu proposes parfois de petits exercices de respiration 
ou de courtes prières inspirées de l'islam.

Tes réponses sont courtes (1 à 3 phrases max), 
douce et rassurante.

Tu communiques comme dans un SMS ou WhatsApp - 
naturel et direct."
```

### **Coût Estimé (mensuel)**

```
Hypothèse: 100 utilisateurs actifs, 10 messages/jour

Messages/mois: 100 * 10 * 30 = 30,000 messages
Tokens/message: ~60 input + 40 output = 100 tokens
Total tokens: 3,000,000

Mistral 7B (gratuit):     $0
LLaMA 3 (gratuit):         $0
GPT-3.5 (payant):         ~$1.50 / mois
Claude Haiku (payant):    ~$0.75 / mois

→ Coût minimal avec modèles gratuits!
```

---

## 📁 Structure du Projet

### **Backend**

```
emotion_adkar_backend/
├── main.py                      # Point d'entrée FastAPI
├── requirements.txt             # Dépendances Python
├── .env                         # Secrets (clés API, DB)
├── .env.example                # Template .env
│
├── auth/
│   └── auth_router.py          # Endpoints /auth/*
│
├── routes/
│   ├── emotion_routes.py       # Endpoints /emotion/*
│   └── chat.py                 # Endpoint /api/chat/
│
├── services/
│   ├── emotion_service.py      # Logique détection émotion
│   ├── llm_service.py          # Intégration OpenRouter
│   ├── explanation_service.py  # Génération explanations
│   └── emotion_content_service.py  # Douaa/Ayah
│
├── schemas/
│   ├── user_model.py           # Schéma User (Pydantic)
│   └── chat_schema.py          # Schémas Chat (Pydantic)
│
├── models/
│   └── user_model.py           # Modèle MongoDB User
│
├── db/
│   └── mongo.py                # Connexion MongoDB
│
├── ml/
│   └── emotion_model.py        # Chargement ViT
│
├── utils/
│   ├── jwt_handler.py          # JWT tokens
│   ├── text_utils.py           # Parsing texte
│   └── constants.py            # Constantes
│
└── images/                      # Images temporaires upload
```

### **Frontend**

```
emotion_adkar/
├── pubspec.yaml               # Config Flutter + dépendances
├── main.dart                  # Point d'entrée app
│
├── lib/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── camera_screen.dart
│   │   ├── emotion_result_screen.dart  # Résultats emotion
│   │   └── dhikrai_chat_screen.dart    # Chat DhikrAI
│   │
│   ├── services/
│   │   ├── emotion_api.dart    # Client API détection
│   │   ├── auth_service.dart   # Client API auth
│   │   └── chat_service.dart   # Client API chat
│   │
│   └── utils/
│       └── dhikrai_extensions_examples.dart  # Exemples futures features
│
├── assets/
│   └── icon/
│       └── app_icon.png        # Icône app (1024x1024)
│
├── android/
│   ├── app/src/main/
│   │   └── res/mipmap-*/
│   │       └── launcher_icon.png  # Icônes Android
│   └── build.gradle
│
└── ios/
    ├── Runner/Assets.xcassets/
    │   └── AppIcon.appiconset/  # Icônes iOS
    └── Runner/Info.plist
```

---

## 🔌 Intégrations Externes

### **OpenRouter API**
```
Service: LLM Multi-Model API
URL: https://openrouter.ai/api/v1/chat/completions
Authentification: Bearer Token (OPENROUTER_API_KEY)
Rate Limit: ~100 requests/minute (plan gratuit)
Fallback: Retour message réconfortant si erreur
```

### **MongoDB Atlas**
```
Database: emotion_adkar
Collections:
  - users (emails, passwords, profiles)
  - emotions_data (douaa, ayahs par émotion)
  - chats (historiques conversations)
Authentification: Connection String MONGO_URI
```

### **HuggingFace (ViT Model)**
```
Modèle: trpakov/vit-face-expression
Type: Vision Transformer
Cache local: ~/.cache/huggingface/
Téléchargement: Auto (1ère requête)
Taille: ~350MB
```

---

## 📊 Métriques de Performance

```
Détection émotion:        2-8 sec (dépend LLM)
Chat DhikrAI:            2-5 sec
Authentification:        1-2 sec
Upload image:            1-2 sec (compression)

Latence API Backend:     <100ms
Latence OpenRouter:      1-3 sec (dominant)
Latence MongoDB:         <50ms

Bande passante/requête:
  - Emotion predict:     2-8 MB (image)
  - Chat:               <1 KB
  - LLM response:       2-5 KB
```

---

## 🔒 Sécurité

```
JWT Tokens:
  - Algorithm: HS256
  - Expiration: 24h
  - Storage: SecureStorage (Flutter)
  - Header: Authorization: Bearer <token>

API Key OpenRouter:
  - Stockée: .env backend uniquement
  - Jamais envoyée au frontend
  - Proxy: Toutes les requêtes passent par backend

Password:
  - Hash: Passlib + bcrypt
  - Jamais stocké en clair
  - Validation: Lors login
```

---

## 🚀 Déploiement

### **Backend Production**

```bash
# Heroku / Railway / Render
uvicorn main:app --host 0.0.0.0 --port 8000

# Avec gunicorn (production)
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
```

### **Frontend Production**

```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release

# Web (optionnel)
flutter build web --release
```

---

## 📈 Roadmap Futures Features

```
✅ COMPLÉTÉ:
  ✓ Détection émotion ViT
  ✓ Chat DhikrAI
  ✓ Douaa + Ayah personnalisés
  ✓ Authentification JWT
  ✓ Compteur Douaa interactif

🔄 EN COURS:
  ⏳ Icône personnalisée DhikrAI

📋 PLANIFIÉ:
  □ Exercices de respiration guidés
  □ Journal des émotions
  □ Recommandations d'Ayah populaires
  □ Partage de contenu spirituel
  □ Notifications rappels Dhikr
  □ Mode hors ligne (cache)
  □ Support multilingue (AR, EN, FR)
  □ Analytics utilisateur (optionnel)
  □ Intégration réseaux sociaux
```

---

## 📞 Support Technique

```
Questions Backend:       Voir logs FastAPI (terminal)
Questions Frontend:      Voir logs Flutter (flutter logs)
Issues API:             Vérifier .env + OpenRouter key
Issues MongoDB:         Vérifier MONGO_URI + connexion
Issues Modèle ViT:      Vérifier internet (téléchargement)
```

---
