# GitHub Repository Setup Guide

Steps to upload Emotion Adkār Backend to GitHub.

## Prerequisites

- GitHub account (create one at github.com)
- Git installed on your machine
- Backend folder ready with all files

## Step 1: Create GitHub Repository

1. **Go to GitHub** → [github.com/new](https://github.com/new)
2. **Fill in details:**
   - Repository name: `emotion-adkar-backend`
   - Description: "AI-Powered Islamic Emotional Wellness Platform - Backend API"
   - Visibility: **Public** (for open source)
   - ✅ Initialize with README (optional - we have one)
   - ✅ Add .gitignore: Python
   - ✅ Add license: MIT
3. **Click "Create repository"**

## Step 2: Initialize Local Git Repository

Open PowerShell in `emotion_adkar_backend` folder:

```powershell
# Initialize git
git init

# Add all files
git add .

# Initial commit
git commit -m "🚀 Initial commit: Emotion Adkār Backend - Full-stack emotion detection and AI chat"

# Verify status
git status
```

You should see something like:
```
On branch main
nothing to commit, working tree clean
```

## Step 3: Connect to GitHub Repository

Replace `YOUR_USERNAME` with your GitHub username:

```powershell
# Add GitHub as remote origin
git remote add origin https://github.com/YOUR_USERNAME/emotion-adkar-backend.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

**First time setup?** You may be prompted for authentication:
- GitHub username or email
- Personal Access Token (or use GitHub CLI)

## Step 4: Generate GitHub Personal Access Token (if needed)

1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Click "Generate new token" → "Generate new token (classic)"
3. **Give it permissions:**
   - ✅ `repo` (full control of private repositories)
   - ✅ `workflow` (GitHub Actions)
4. Set expiration: 90 days (or 1 year for dev)
5. **Copy the token** and save it
6. Use token as password when prompted

---

## Verification

### Check on GitHub

1. Go to `https://github.com/YOUR_USERNAME/emotion-adkar-backend`
2. You should see all your files listed
3. README.md should be displayed

### Check Remote Configuration

```powershell
git remote -v
# Should show:
# origin  https://github.com/YOUR_USERNAME/emotion-adkar-backend.git (fetch)
# origin  https://github.com/YOUR_USERNAME/emotion-adkar-backend.git (push)
```

---

## Next Steps

### 1. Add Repository Topics (for discoverability)

On GitHub repository page:
- Click "Settings"
- Scroll to "Topics"
- Add: `emotion-detection`, `mental-health`, `islam`, `ai-chat`, `fastapi`, `flutter`, `emotion-ai`

### 2. Configure GitHub Pages (optional)

For hosting documentation:
- Settings → Pages
- Select `main` branch
- Documentation auto-publishes

### 3. Setup GitHub Actions (optional)

Create `.github/workflows/tests.yml` for automated testing:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Run tests
      run: pytest -v
```

### 4. Add Release (tag version)

```powershell
# Create a tag
git tag -a v1.0.0 -m "Release version 1.0.0: Emotion detection + DhikrAI chat"

# Push tag
git push origin v1.0.0
```

Then on GitHub, create Release from the tag with changelog.

### 5. Enable Discussions (for community)

- Settings → Features → enable "Discussions"
- Helps users ask questions without GitHub Issues

---

## Troubleshooting

### Error: "fatal: remote origin already exists"

```powershell
# Remove existing remote
git remote remove origin

# Add correct remote
git remote add origin https://github.com/YOUR_USERNAME/emotion-adkar-backend.git
```

### Error: "The repository could not be accessed"

1. Verify username in URL
2. Check authentication token
3. Try: `git remote set-url origin https://YOUR_USERNAME:TOKEN@github.com/YOUR_USERNAME/emotion-adkar-backend.git`

### Error: "Updates were rejected"

```powershell
# Fetch and merge remote changes
git fetch origin
git merge origin/main
git push origin main
```

### Commits not showing as "verified"

```powershell
# Configure Git
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"

# Create new commit
git commit --amend --no-edit
git push -f origin main
```

---

## Best Practices After Upload

### 1. Add Collaborators

- Settings → Collaborators → Invite by username

### 2. Set Branch Protection (for main)

- Settings → Branches → Add rule for `main`
- Require pull request reviews before merging
- Require status checks (tests) to pass

### 3. Enable Security Features

- Settings → Security & analysis
- Enable "Dependabot" for dependency updates
- Enable "Secret scanning"

### 4. Keep Repository Updated

```powershell
# After making local changes
git add .
git commit -m "✨ feat: Description of changes"
git push origin main
```

---

## Future: Frontend Repository

Create separate repository for Flutter app:

1. Create new repo: `emotion-adkar-frontend`
2. Push Flutter code similarly
3. Link both repos in READMEs

Example link in backend README:
```markdown
**Frontend Repository**: [emotion-adkar-frontend](https://github.com/YOUR_USERNAME/emotion-adkar-frontend)
```

---

## Repository Structure on GitHub

After push, your repo will look like:

```
emotion-adkar-backend/
├── .github/
│   └── workflows/        # CI/CD configurations
├── auth/
├── db/
├── ml/
├── models/
├── routes/
├── services/
├── utils/
├── .gitignore
├── .env.example
├── GITHUB_README.md      (rename to README.md)
├── INSTALLATION.md
├── CONTRIBUTING.md
├── LICENSE
├── PROJECT_OVERVIEW.md
├── TEST_API.md
├── ENV_SETUP.md
└── requirements.txt
```

---

## Public Repository Considerations

### What to Avoid Committing

✅ Already excluded by `.gitignore`:
- `__pycache__/`
- `venv/`
- `.env` (use `.env.example`)
- `.vscode/`, `.idea/`
- Uploaded images
- `*.log`, `*.tmp`

### Document Sensitive Info

- Explain where to get API keys (`.env.example`)
- Don't include example `.env` with real keys
- Add warning about free tier limitations

### Add Badges to README

```markdown
[![Python](https://img.shields.io/badge/Python-3.11-blue.svg)](https://www.python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104-green.svg)](https://fastapi.tiangolo.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

---

## Monitoring Your Repository

After upload, you can:

1. **Track Stars** → Repository → Star icon
2. **Monitor Forks** → Network graph
3. **Track Issues** → Issue templates for bug reports
4. **Track Discussions** → Q&A with community
5. **Watch Commits** → Real-time updates

---

## Success! 🎉

Your repository is now public and ready for:
- Collaboration
- Community contributions
- Portfolio display
- Open-source recognition

---

## Need Help?

- [GitHub Docs](https://docs.github.com)
- [Git Reference](https://git-scm.com/docs)
- [GitHub Community](https://github.community)

Congratulations on sharing your code! 🚀
