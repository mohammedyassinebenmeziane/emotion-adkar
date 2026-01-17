# 🌙 Emotion Adkār - Full Stack Project

<div align="center">

### AI-Powered Islamic Emotional Wellness & Spiritual Guidance Platform

**A complete full-stack application combining facial emotion detection with personalized Islamic spiritual support**

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green.svg)](https://fastapi.tiangolo.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg)](https://flutter.dev)
[![MongoDB](https://img.shields.io/badge/MongoDB-6.0+-green.svg)](https://www.mongodb.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[Overview](#-overview) • [Features](#-features) • [Architecture](#-architecture) • [Quick Start](#-quick-start) • [Project Structure](#-project-structure) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 🎯 Overview

**Emotion Adkār** is an innovative platform that bridges modern AI technology with Islamic spiritual wellness. The application:

1. **Detects Emotions**: Uses Vision Transformer AI to analyze facial expressions in real-time
2. **Provides Spiritual Guidance**: Offers personalized Islamic prayers, Quranic verses, and spiritual wisdom
3. **Enables Conversations**: Features DhikrAI, an empathetic AI chatbot that provides support grounded in Islamic teachings
4. **Supports Wellness**: Helps users navigate emotional challenges with culturally appropriate, spiritually aligned guidance

---

## ✨ Features

### 🎬 Frontend (Flutter Mobile App)
- **Cross-Platform**: Android, iOS, Web, Windows, macOS, and Linux support
- **Real-time Camera Feed**: Live emotion detection with video stream processing
- **Authentication**: Secure login and registration system
- **Emotion Results**: Visual display of detected emotions and confidence scores
- **Chat Interface**: Interactive conversations with DhikrAI spiritual assistant
- **Home Dashboard**: User-friendly interface with emotion history and recommendations
- **Secure Storage**: Local storage for authentication tokens and user preferences

### 🧠 Backend (Python FastAPI API)
- **Emotion Detection API**: Vision Transformer-based facial emotion recognition
- **AI Chatbot**: DhikrAI - Empathetic LLM-powered chatbot via OpenRouter API
- **Spiritual Content Service**: Curated Islamic prayers, Quranic verses, and explanations
- **User Authentication**: JWT-based secure authentication with bcrypt hashing
- **Database**: MongoDB integration for users, emotions, conversation history
- **Production-Ready**: Async/await architecture with proper error handling
- **API Documentation**: Auto-generated Swagger/OpenAPI documentation
- **Scalable**: Designed for easy deployment and horizontal scaling

---

## 🏗️ Architecture

### System Design

```
┌─────────────────────────────────────────────────────────────┐
│                    Emotion Adkār Platform                    │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│  Frontend Layer      │         │  Backend Layer       │
│  (Flutter)           │         │  (FastAPI)           │
│                      │         │                      │
│ • Mobile Apps        │◄────────┤ • REST API           │
│ • Web Interface      │  HTTP   │ • Authentication     │
│ • Camera Module      │         │ • Services           │
│ • Chat UI            │         │ • ML Models          │
└──────────────────────┘         └──────────────────────┘
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    │                     │                     │
              ┌─────▼──────┐       ┌──────▼──────┐      ┌──────▼──────┐
              │ MongoDB    │       │ Vision      │      │ OpenRouter  │
              │ Database   │       │ Transformer │      │ LLM API     │
              │ (Users,    │       │ (Emotion)   │      │ (DhikrAI)   │
              │ Emotions,  │       │             │      │             │
              │ Chats)     │       │             │      │             │
              └────────────┘       └─────────────┘      └─────────────┘
```

### Modules

**Frontend (`/Frontend`)**
- `lib/main.dart` - Main application entry point
- `lib/screens/` - UI screens (login, home, camera, emotion results, chat)
- `lib/services/` - API integration and business logic
- `lib/utils/` - Helper functions and extensions

**Backend (`/Backend`)**
- `main.py` - Application entry point and FastAPI setup
- `auth/` - Authentication router and JWT handlers
- `routes/` - API endpoints (chat, emotions)
- `models/` - Database models and schemas
- `services/` - Business logic (emotion, LLM, content)
- `ml/` - Machine learning models (emotion detection)
- `db/` - Database configuration and connections
- `utils/` - Helper utilities

---

## 🚀 Quick Start

### Prerequisites

- **For Backend:**
  - Python 3.11+
  - MongoDB 6.0+ (local or Atlas)
  - OpenRouter API key
  - pip package manager

- **For Frontend:**
  - Flutter 3.0+
  - Dart 3.0+
  - Android SDK (for Android) or Xcode (for iOS)

### Backend Setup

```bash
# 1. Navigate to backend directory
cd Backend

# 2. Create virtual environment
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # macOS/Linux

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment variables
cp .env.example .env
# Edit .env and add:
# - MONGODB_URL (MongoDB connection string)
# - OPENROUTER_API_KEY (Your OpenRouter API key)
# - JWT_SECRET (Random secure string)

# 5. Run the backend server
python main.py
# Server runs on http://localhost:8000
# API docs available at http://localhost:8000/docs
```

### Frontend Setup

```bash
# 1. Navigate to frontend directory
cd Frontend

# 2. Install dependencies
flutter pub get

# 3. Generate build files
flutter pub run build_runner build

# 4. Run the app
flutter run  # Select device/emulator when prompted

# For web
flutter run -d chrome

# For Windows
flutter run -d windows

# For macOS
flutter run -d macos
```

---

## 📁 Project Structure

```
emotion-adkar/
│
├── Backend/                          # Python FastAPI Backend
│   ├── main.py                      # Application entry point
│   ├── requirements.txt             # Python dependencies
│   ├── .env.example                 # Environment variables template
│   │
│   ├── auth/                        # Authentication module
│   │   └── auth_router.py
│   │
│   ├── db/                          # Database configuration
│   │   └── mongo.py
│   │
│   ├── ml/                          # Machine learning models
│   │   └── emotion_model.py
│   │
│   ├── models/                      # Data models
│   │   └── user_model.py
│   │
│   ├── routes/                      # API endpoints
│   │   ├── chat.py
│   │   └── emotion_routes.py
│   │
│   ├── schemas/                     # Request/Response schemas
│   │   └── chat_schema.py
│   │
│   ├── services/                    # Business logic
│   │   ├── emotion_service.py
│   │   ├── emotion_content_service.py
│   │   ├── llm_service.py
│   │   └── explanation_service.py
│   │
│   ├── utils/                       # Utilities
│   │   ├── jwt_handler.py
│   │   └── text_utils.py
│   │
│   └── README.md                    # Backend documentation
│
├── Frontend/                         # Flutter Mobile App
│   ├── pubspec.yaml                # Flutter dependencies
│   ├── lib/
│   │   ├── main.dart               # App entry point
│   │   ├── screens/                # UI Screens
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── camera_screen.dart
│   │   │   ├── emotion_result_screen.dart
│   │   │   └── dhikrai_chat_screen.dart
│   │   ├── services/               # API & Business Logic
│   │   │   ├── auth_service.dart
│   │   │   └── emotion_api.dart
│   │   └── utils/                  # Helpers
│   │
│   ├── android/                    # Android native files
│   ├── ios/                        # iOS native files
│   ├── web/                        # Web files
│   ├── windows/                    # Windows desktop files
│   ├── macos/                      # macOS desktop files
│   ├── linux/                      # Linux desktop files
│   │
│   └── README.md                   # Frontend documentation
│
├── .gitignore                       # Git ignore rules
└── README.md                        # This file
```

---

## 🔧 Technology Stack

### Backend
| Technology | Purpose |
|-----------|---------|
| **Python 3.11+** | Programming language |
| **FastAPI** | Web framework for REST APIs |
| **PyTorch** | Deep learning framework |
| **Transformers** | Vision Transformer models |
| **MongoDB** | NoSQL database |
| **PyJWT** | JWT authentication |
| **OpenRouter API** | LLM access (Claude, GPT, etc.) |
| **Uvicorn** | ASGI server |

### Frontend
| Technology | Purpose |
|-----------|---------|
| **Flutter 3.0+** | Cross-platform framework |
| **Dart 3.0+** | Programming language |
| **Camera Plugin** | Real-time camera access |
| **HTTP Package** | API requests |
| **Provider** | State management |
| **Flutter Secure Storage** | Secure token storage |

### Infrastructure
| Technology | Purpose |
|-----------|---------|
| **MongoDB** | Primary database |
| **GitHub** | Version control & hosting |
| **Docker** | Containerization (optional) |

---

## 📖 Documentation

Detailed documentation for each component:

- **[Backend Documentation](Backend/README.md)** - API endpoints, setup, architecture
- **[Frontend Documentation](Frontend/README.md)** - UI components, navigation, services
- **[Environment Setup](Backend/ENV_SETUP.md)** - Detailed environment configuration
- **[Installation Guide](Backend/INSTALLATION.md)** - Step-by-step installation
- **[Contributing Guidelines](Backend/CONTRIBUTING.md)** - How to contribute

### API Documentation

Once the backend is running, access interactive API documentation:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt-based password security
- **Environment Variables**: Sensitive data protected via `.env` files
- **CORS Configuration**: Controlled cross-origin requests
- **Input Validation**: Pydantic schemas validate all inputs
- **Error Handling**: Secure error messages without exposing internals

---

## 🚢 Deployment

### Backend Deployment

```bash
# Build Docker image (optional)
docker build -t emotion-adkar-backend .
docker run -p 8000:8000 emotion-adkar-backend

# Or use cloud platforms:
# - Heroku
# - AWS Lambda
# - Google Cloud Run
# - DigitalOcean App Platform
```

### Frontend Deployment

```bash
# Build APK (Android)
flutter build apk

# Build AAB (Google Play)
flutter build appbundle

# Build iOS
flutter build ios

# Build Web
flutter build web

# Build Windows/macOS/Linux
flutter build windows
flutter build macos
flutter build linux
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

See [CONTRIBUTING.md](Backend/CONTRIBUTING.md) for detailed guidelines.

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

**Yassine Ben Meziane**
- GitHub: [@mohammedyassinebenmeziane](https://github.com/mohammedyassinebenmeziane)
- Email: yassinebenmeziane@example.com

---

## 🙏 Acknowledgments

- Vision Transformer for emotion detection
- OpenRouter API for LLM capabilities
- Flutter team for the excellent cross-platform framework
- FastAPI for the modern Python web framework
- MongoDB for the flexible database

---

## 📞 Support & Contact

For questions, suggestions, or issues:

1. **GitHub Issues**: [Create an issue](https://github.com/mohammedyassinebenmeziane/emotion-adkar/issues)
2. **GitHub Discussions**: [Start a discussion](https://github.com/mohammedyassinebenmeziane/emotion-adkar/discussions)
3. **Email**: yassinebenmeziane@example.com

---

## 🌟 Features Roadmap

- [ ] Multi-language support (Arabic, English, French)
- [ ] Emotion history analytics and trends
- [ ] Advanced meditation and Quranic recitation
- [ ] Social sharing features
- [ ] Offline mode support
- [ ] Push notifications for spiritual reminders
- [ ] User community features
- [ ] Admin dashboard

---

<div align="center">

**Made with ❤️ for emotional and spiritual wellness**

*"Indeed, in the remembrance of Allah do hearts find rest." - Quran 13:28*

</div>
