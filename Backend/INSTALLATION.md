# Installation Guide

Complete step-by-step guide to get Emotion Adkār Backend running.

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Local Development Setup](#local-development-setup)
3. [MongoDB Setup](#mongodb-setup)
4. [OpenRouter API Setup](#openrouter-api-setup)
5. [Running the Server](#running-the-server)
6. [Troubleshooting](#troubleshooting)

---

## System Requirements

| Component | Version | Notes |
|-----------|---------|-------|
| Python | 3.11+ | Download from python.org |
| MongoDB | 6.0+ | Local or Atlas cloud |
| pip | Latest | Comes with Python |
| Git | Latest | For cloning repository |

**Optional:**
- FFmpeg 6.0+ (for video processing)
- Docker 24.0+ (for containerized deployment)

---

## Local Development Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/emotion-adkar-backend.git
cd emotion-adkar-backend
```

### Step 2: Create Virtual Environment

**Windows (PowerShell):**
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**macOS/Linux:**
```bash
python -m venv venv
source venv/bin/activate
```

You should see `(venv)` in your terminal prompt.

### Step 3: Install Python Dependencies

```bash
# Upgrade pip first
pip install --upgrade pip

# Install all dependencies
pip install -r requirements.txt
```

**What gets installed:**
- `fastapi` - Web framework
- `uvicorn` - Server
- `motor` - Async MongoDB driver
- `transformers` - ML models from Hugging Face
- `torch` - Deep learning framework
- `httpx` - Async HTTP client
- `pydantic` - Data validation
- `passlib` - Password hashing
- `python-jose` - JWT authentication
- `pytest` - Testing framework

### Step 4: Configure Environment Variables

```bash
# Copy example file
copy .env.example .env  # Windows
# or
cp .env.example .env    # macOS/Linux

# Edit .env file in your text editor
```

**Minimum required:**
```env
OPENROUTER_API_KEY=your_key_here
MONGO_URI=mongodb://localhost:27017
JWT_SECRET=change-me-to-random-string
```

**Generate a secure JWT secret:**
```bash
# Option 1: Python
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Option 2: PowerShell
$([Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32)))
```

---

## MongoDB Setup

### Option A: Local MongoDB Installation

**Windows:**
1. Download [MongoDB Community](https://www.mongodb.com/try/download/community)
2. Run installer (use default paths)
3. MongoDB starts as a Windows service automatically
4. Test connection: `mongo localhost:27017`

**macOS (via Homebrew):**
```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install -y mongodb
sudo systemctl start mongodb
sudo systemctl enable mongodb
```

**Verify MongoDB is running:**
```bash
mongo --eval "db.version()"
# Should return version number
```

### Option B: MongoDB Atlas (Cloud)

1. **Create account** at [mongodb.com/cloud](https://www.mongodb.com/cloud/atlas)
2. **Create cluster** (M0 tier is free)
3. **Add IP whitelist** (temporarily use 0.0.0.0/0 for development)
4. **Create database user** (save credentials)
5. **Get connection string** and add to `.env`:
   ```env
   MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/emotion_adkar?retryWrites=true&w=majority
   ```

---

## OpenRouter API Setup

### Step 1: Create Account

1. Visit [openrouter.ai](https://openrouter.ai)
2. Sign up with email or GitHub
3. Verify email

### Step 2: Get API Key

1. Go to [Settings/Keys](https://openrouter.ai/settings/keys)
2. Create new key
3. Copy the key (starts with `sk-or-`)

### Step 3: Add to .env

```env
OPENROUTER_API_KEY=sk-or-your-actual-key
```

### Step 4: (Optional) Add Credits

The free tier includes:
- **1M free tokens/month** on Mistral 7B
- Free tier resets monthly

For production, consider adding credits:
1. Go to Billing
2. Add payment method
3. Set spending limit

---

## Running the Server

### Method 1: Direct Python (Development)

```bash
# Make sure venv is activated
python main.py
```

Output should show:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
```

### Method 2: Uvicorn CLI

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Flags:
- `--reload` - Auto-restart on file changes
- `--host 0.0.0.0` - Listen on all interfaces
- `--port 8000` - Custom port (default 8000)

### Method 3: PowerShell Script (Windows)

```bash
.\run_server.ps1
```

### Method 4: Docker

```bash
# Build image
docker build -t emotion-adkar-backend .

# Run container
docker run -p 8000:8000 --env-file .env emotion-adkar-backend
```

---

## Verifying Installation

### Check Server is Running

```bash
curl http://localhost:8000
# Should return: {"status":"ok"}
```

### Access API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Run Test Suite

```bash
# Run all tests
pytest -v

# Run specific test
pytest test_emotion_api.py -v

# Run with coverage
pytest --cov=. test_emotion_api.py
```

### Test Emotion Detection

```bash
python test_emotion_api.py
```

### Test Chat/LLM Integration

```bash
python test_chat_api.py
```

---

## Troubleshooting

### Issue: "Connection refused" on MongoDB

**Solution 1: Start MongoDB**
```bash
# Windows
net start MongoDB

# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongodb
```

**Solution 2: Check connection string**
```env
# Local
MONGO_URI=mongodb://localhost:27017

# Remote (Atlas)
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/db
```

### Issue: "OpenRouter API key invalid"

1. Verify key in `.env` (no extra spaces)
2. Check key starts with `sk-or-`
3. Generate new key at [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys)

### Issue: "ModuleNotFoundError: No module named 'fastapi'"

1. Check venv is activated: `(venv)` in prompt
2. Reinstall dependencies: `pip install -r requirements.txt`
3. Try explicitly: `pip install fastapi uvicorn`

### Issue: Port 8000 already in use

**Option 1:** Kill existing process
```bash
# Windows (PowerShell)
Get-Process -Id (Get-NetTCPConnection -LocalPort 8000).OwningProcess | Stop-Process

# macOS/Linux
lsof -ti:8000 | xargs kill -9
```

**Option 2:** Use different port
```bash
python main.py --port 8001
# or
uvicorn main:app --port 8001
```

### Issue: Slow emotion detection

1. **First run takes time** (~30 seconds) - Model downloads
2. **Subsequent runs** should be ~5 seconds
3. Check GPU access:
   ```bash
   python -c "import torch; print(torch.cuda.is_available())"
   ```

### Issue: "certificate verify failed" with SSL

Add to Python code temporarily:
```python
import urllib3
urllib3.disable_warnings()
```

Or set environment variable:
```bash
set PYTHONHTTPSVERIFY=0  # Windows
export PYTHONHTTPSVERIFY=0  # macOS/Linux
```

### Issue: Large image processing timeout

Edit `main.py` and increase timeout:
```python
MAX_IMAGE_SIZE = 20 * 1024 * 1024  # 20MB instead of default
```

---

## Next Steps

1. **Test API endpoints**: See [TEST_API.md](TEST_API.md)
2. **Read architecture**: See [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)
3. **Deploy to production**: Use Docker or cloud platform
4. **Connect Flutter app**: Update backend URL in app settings

---

## Getting Help

- Check `.env.example` for all available settings
- Review test files for usage examples
- Open issue on GitHub with error details
- Check [ENV_SETUP.md](ENV_SETUP.md) for environment details

---

## System Information

After setup, get your system info:

```bash
python -c "
import sys
import platform
import torch
print(f'Python: {sys.version}')
print(f'Platform: {platform.platform()}')
print(f'GPU Available: {torch.cuda.is_available()}')
"
```

You're ready to go! 🚀
