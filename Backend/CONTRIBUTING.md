# Contributing to Emotion Adkār

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Code of Conduct

Be respectful, inclusive, and constructive. We're building a project for emotional wellness and spirituality - let's maintain that spirit in our interactions.

## Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/emotion-adkar-backend.git
   cd emotion-adkar-backend
   ```

2. **Set up development environment**
   ```bash
   python -m venv venv
   .\venv\Scripts\activate
   pip install -r requirements.txt
   pip install pytest pytest-asyncio black flake8
   ```

3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Before Making Changes

- Check existing issues and PRs to avoid duplicate work
- Open an issue for major features before starting
- For small fixes, you can start directly

### Code Standards

We follow PEP 8 with these tools:

**Format code:**
```bash
black . --line-length=100
```

**Check for issues:**
```bash
flake8 . --max-line-length=100
```

**Run tests:**
```bash
pytest -v
```

### Writing Tests

- Add tests for all new features in `test_*.py` files
- Use descriptive test names: `test_emotion_detection_returns_valid_emotion`
- Mock external services (MongoDB, OpenRouter API)
- Aim for >80% code coverage

Example test:
```python
@pytest.mark.asyncio
async def test_chat_endpoint_with_valid_message():
    client = TestClient(app)
    response = client.post(
        "/api/chat/",
        json={"message": "I feel sad", "history": []}
    )
    assert response.status_code == 200
    assert "response" in response.json()
```

### Commit Messages

Use clear, descriptive commit messages:

```
✨ feat: Add emotion detection caching for performance
🐛 fix: Handle missing MongoDB connection gracefully
📝 docs: Update API documentation with examples
🧹 refactor: Simplify LLM artifact cleaning logic
🧪 test: Add integration tests for chat endpoint
```

Prefixes:
- `✨ feat:` - New feature
- `🐛 fix:` - Bug fix
- `📝 docs:` - Documentation
- `🧹 refactor:` - Code refactoring
- `🧪 test:` - Tests
- `⚡ perf:` - Performance improvement
- `🔒 security:` - Security fix

## Pull Request Process

1. **Update documentation**
   - Update README if behavior changes
   - Add docstrings to new functions
   - Update requirements.txt if adding dependencies

2. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create Pull Request**
   - Clear title describing the change
   - Reference related issues (#123)
   - Explain why this change is needed
   - Show before/after behavior for UI changes

4. **PR Checklist**
   - [ ] Code follows PEP 8 style
   - [ ] All tests pass locally
   - [ ] New tests added for new features
   - [ ] Documentation updated
   - [ ] No unnecessary files committed
   - [ ] Meaningful commit messages

## Areas for Contribution

### High Priority
- [ ] Emotion detection accuracy improvements
- [ ] LLM response quality enhancements
- [ ] Database performance optimization
- [ ] Mobile app Flutter integration improvements
- [ ] Docker/Kubernetes deployment setup

### Medium Priority
- [ ] Additional spiritual content (Douaa, Ayah)
- [ ] Multi-language support (Arabic, English, French variations)
- [ ] Enhanced error messages and logging
- [ ] User analytics dashboard
- [ ] Caching strategies

### Documentation
- [ ] API endpoint examples
- [ ] Deployment guides
- [ ] Architecture diagrams
- [ ] Video tutorials
- [ ] Troubleshooting guides

## Reporting Bugs

**Good bug reports include:**
- Clear, descriptive title
- Exact reproduction steps
- Expected vs actual behavior
- Environment info (OS, Python version, MongoDB version)
- Error logs/stack traces
- Screenshots for UI issues

Example:
```
Title: Emotion detection fails with 500 error on invalid image

Steps to reproduce:
1. Send POST to /api/emotions/detect with corrupted image
2. Watch server logs

Expected: Error message about invalid image format
Actual: Internal server error with no details

Environment:
- Python 3.11.4
- FastAPI 0.104
- MongoDB 6.0
```

## Review Process

- At least one maintainer review required
- Address feedback before merge
- Keep discussions focused and respectful
- We may request changes for code quality

## Questions?

- Check [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) for architecture
- Review existing code and tests for patterns
- Open an issue labeled "question"

## Recognition

All contributors will be recognized in:
- Project README
- Contributors list
- Release notes

Thank you for making Emotion Adkār better! 🌙
