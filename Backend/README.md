# Emotion Adkār Backend

<div align="center">

### 🌙 AI-Powered Islamic Emotional Wellness Platform

**Backend API for Emotion Detection & Personalized Spiritual Guidance**

[![Python](https://img.shields.io/badge/Python-3.11-blue.svg)](https://www.python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104-green.svg)](https://fastapi.tiangolo.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[Features](#features) • [Quick Start](#quick-start) • [API Documentation](#api-documentation) • [Architecture](#architecture) • [Contributing](#contributing)

</div>

---

## ✨ Features

- **🧠 Emotion Detection**: Vision Transformer-based facial emotion recognition
- **💬 AI Conversational Assistant**: DhikrAI - Empathetic LLM-powered chatbot via OpenRouter
- **📖 Spiritual Content**: Curated Islamic prayers (Douaa), Quranic verses (Ayah), and explanations
- **🔐 Authentication**: JWT-based secure authentication with bcrypt password hashing
- **📊 MongoDB Integration**: Async database for users, emotions, and conversation history
- **⚡ Production-Ready**: FastAPI async/await with proper error handling and validation

---

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- MongoDB (local or Atlas connection string)
- OpenRouter API key (for LLM features)

### Installation

1. **Clone & Navigate**
```bash
git clone https://github.com/yourusername/emotion-adkar-backend.git
cd emotion-adkar-backend
```

2. **Create Virtual Environment**
```bash
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # macOS/Linux
```

3. **Install Dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure Environment**
```bash
copy .env.example .env  # Windows or cp .env.example .env
```

Edit `.env` with your values:
```env
OPENROUTER_API_KEY=your_api_key_here
OPENROUTER_MODEL=mistralai/mistral-7b-instruct:free
MONGO_URI=mongodb://localhost:27017
JWT_SECRET=your_secret_key_here
JWT_ALGORITHM=HS256
```

5. **Start MongoDB**
```bash
# Windows
net start MongoDB

# macOS (Homebrew)
brew services start mongodb-community

# Linux
sudo systemctl start mongodb
```

6. **Run Server**
```bash
python main.py
```

Server starts on `http://localhost:8000`

---

## 📚 API Documentation

### Interactive Docs
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Key Endpoints

#### Authentication
```http
POST /auth/register
POST /auth/login
```

#### Emotion Detection
```http
POST /api/emotions/detect
# Returns: emotion, confidence, associated_douaa, ayah, explication
```

#### Chat/LLM
```http
POST /api/chat/
# Request: { "message": "...", "history": [...] }
# Response: { "response": "...", "role": "assistant" }
```

#### Get Emotions
```http
GET /api/emotions
```

See [TEST_API.md](TEST_API.md) for detailed examples and curl commands.

---

## 🏗️ Architecture

### Tech Stack
- **Framework**: FastAPI (async Python)
- **Database**: MongoDB with Motor (async driver)
- **ML Model**: Vision Transformer (vit-face-expression from Hugging Face)
- **LLM**: OpenRouter API → Mistral 7B (free tier)
- **Authentication**: JWT (HS256) + bcrypt
- **HTTP Client**: httpx (async)

### Project Structure
```
emotion_adkar_backend/
├── auth/               # JWT authentication routes
├── db/                 # MongoDB connection & setup
├── ml/                 # Emotion detection model
├── models/             # Pydantic data models
├── routes/             # API route handlers
│   ├── emotion_routes.py
│   ├── chat.py
│   └── auth_router.py
├── services/           # Business logic
│   ├── emotion_service.py
│   ├── llm_service.py
│   ├── emotion_content_service.py
│   └── explanation_service.py
├── utils/              # Utilities
│   ├── jwt_handler.py
│   └── text_utils.py
├── main.py             # FastAPI app entry point
├── requirements.txt    # Python dependencies
└── .env.example        # Environment template
```

### Communication Flow

**Emotion Detection:**
```
Client → FastAPI /detect → Hugging Face Model → MongoDB → Response
```

**Chat Integration:**
```
Client → FastAPI /chat → OpenRouter API → Mistral 7B → Clean & Return
```

**Authentication:**
```
Register/Login → Password Hash (bcrypt) → JWT Token → Secure API Access
```

---

## 🧪 Testing

Run the test suite:
```bash
pytest test_*.py -v

# With coverage
pytest --cov=. test_*.py
```

Key test files:
- `test_emotion_api.py` - Emotion detection tests
- `test_chat_api.py` - Chat/LLM integration tests
- `test_hf_api.py` - Hugging Face API tests

---

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENROUTER_API_KEY` | Required | API key for OpenRouter LLM service |
| `OPENROUTER_MODEL` | `mistralai/mistral-7b-instruct:free` | LLM model identifier |
| `MONGO_URI` | `mongodb://localhost:27017` | MongoDB connection string |
| `JWT_SECRET` | Required | Secret key for JWT signing |
| `JWT_ALGORITHM` | `HS256` | JWT algorithm (don't change) |

### LLM Models

**Free Tier** (Recommended):
- `mistralai/mistral-7b-instruct:free` - 1M free tokens/month

**Paid Alternatives**:
- `meta-llama/llama-3-8b-instruct` - Fast, good quality
- `openai/gpt-3.5-turbo` - Highest quality
- `anthropic/claude-3-haiku` - Best balance

See [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) for cost analysis.

---

## 📖 Documentation

- [INSTALLATION.md](INSTALLATION.md) - Detailed setup guide
- [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) - Complete architecture & technical details
- [ENV_SETUP.md](ENV_SETUP.md) - Environment configuration guide
- [TEST_API.md](TEST_API.md) - API testing examples
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [GITHUB_SETUP.md](GITHUB_SETUP.md) - How to fork & contribute

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Code standards & testing
- Pull request process
- Areas needing contribution

Quick start for contributors:
```bash
git clone https://github.com/yourusername/emotion-adkar-backend.git
cd emotion-adkar-backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
pytest -v  # Run tests
```

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Vision Transformer Model**: [trpakov/vit-face-expression](https://huggingface.co/trpakov/vit-face-expression)
- **LLM Service**: [OpenRouter API](https://openrouter.ai)
- **Framework**: [FastAPI](https://fastapi.tiangolo.com)
- **Database**: [MongoDB](https://www.mongodb.com)

---

## 📞 Support & Feedback

- **Issues**: Open a GitHub issue for bugs or features
- **Questions**: Start a Discussion on GitHub
- **Documentation**: Check [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)
- **Examples**: See [TEST_API.md](TEST_API.md)

---

## 🚀 Connected Projects

- **Frontend (Flutter)**: [emotion-adkar-frontend](https://github.com/yourusername/emotion-adkar-frontend)
- **Full Stack Demo**: Check out the Flutter app that uses this backend

---

<div align="center">

**Made with ❤️ for emotional wellness & Islamic spirituality**

⭐ If this project helps you, please consider starring it!

[Sponsor](https://github.com/sponsors/yourusername) • [Issues](../../issues) • [Discussions](../../discussions)

</div>
