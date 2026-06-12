# HPAI-OS: Complete Setup & Run Guide 🚀

## Project Overview
HPAI-OS is a comprehensive AI-powered learning and wellness platform with:
- ✅ Voice Assistant (Speech-to-Text, AI Response, Text-to-Speech)
- ✅ PDF Document Intelligence (Upload & Q&A)
- ✅ Multiple AI Agents (Tutor, Planner, Career Coach, Motivation)
- ✅ Chat with Memory
- ✅ Digital Twin Profile
- ✅ Dashboard & Analytics
- ✅ User Authentication (JWT)

---

## BACKEND SETUP (Python/FastAPI)

### Prerequisites
- Python 3.10+
- Ollama (Local LLM: https://ollama.ai)
- pip

### Step 1: Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### Step 2: Configure Environment
Create a `.env` file in the `backend/` directory:
```
OLLAMA_MODEL=mistral
DATABASE_URL=sqlite:///./hpai.db
SECRET_KEY=hpai_secret_key
```

### Step 3: Initialize Database
```bash
python -c "from app.database.init_db import create_tables; create_tables()"
```

### Step 4: Start Ollama (in another terminal)
```bash
ollama serve
# In another prompt: ollama pull mistral
```

### Step 5: Run Backend Server
```bash
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Backend will be available at: **http://localhost:8000**
API Docs: **http://localhost:8000/docs**

---

## FRONTEND SETUP (Flutter)

### Prerequisites
- Flutter SDK (3.10+): https://flutter.dev/docs/get-started/install
- Android Studio / Xcode (for emulator)
- Android/iOS device or emulator

### Step 1: Install Dependencies
```bash
cd frontend
flutter pub get
```

### Step 2: Update Backend URL (if needed)
Edit `frontend/lib/services/network_utils.dart`:
```dart
static String get baseUrl {
    // Update to your backend URL
    if (kIsWeb) return 'http://127.0.0.1:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000'; // Android emulator
      default:
        return 'http://127.0.0.1:8000';
    }
}
```

### Step 3: Run on Emulator/Device
```bash
cd frontend

# List devices
flutter devices

# Run on device/emulator
flutter run

# Or specify device:
flutter run -d <device_id>
```

---

## COMPLETE WORKFLOW

### 1. **Register/Login**
- Tap "Sign Up" or "Log In"
- Create account with email & password
- Token is saved automatically

### 2. **Chat with AI**
- Send messages to AI agents
- System automatically routes to appropriate agent:
  - "explain/teach/learn" → Tutor Agent
  - "plan/schedule/routine" → Planner Agent
  - "career/job/resume" → Career Agent
  - "stress/motivate/focus" → Motivation Agent

### 3. **PDF Intelligence**
- Go to "PDF Intelligence" tab
- Upload PDF document
- Ask questions about the PDF
- AI retrieves relevant sections and answers

### 4. **Voice Assistant**
- Go to "Voice Assistant" tab
- Tap the blue microphone button to start recording
- Ask a question verbally
- AI transcribes → processes → returns text answer

### 5. **Profile & Dashboard**
- View your "Digital Twin" profile
- Track learning style, stress level, productivity
- View personalized dashboard

---

## TESTING THE COMPLETE FLOW

### Test 1: User Registration & Login
```bash
# Backend check
curl -X POST "http://localhost:8000/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123!"
  }'

# Login
curl -X POST "http://localhost:8000/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'
```

### Test 2: Chat Endpoint
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "message": "Explain machine learning"
  }'
```

### Test 3: PDF Upload & Q&A
```bash
# Upload PDF
curl -X POST "http://localhost:8000/upload-pdf" \
  -H "Authorization: Bearer <TOKEN>" \
  -F "file=@sample.pdf"

# Ask question
curl -X POST "http://localhost:8000/ask-pdf" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "question": "What is the main topic?"
  }'
```

### Test 4: Voice Chat
```bash
# Upload audio file (must be .wav, .mp3, or .m4a)
curl -X POST "http://localhost:8000/voice-chat" \
  -H "Authorization: Bearer <TOKEN>" \
  -F "file=@audio.wav"
```

---

## TROUBLESHOOTING

### Backend Issues

**Issue: "Ollama connection refused"**
```bash
# Make sure Ollama is running
ollama serve
```

**Issue: "ModuleNotFoundError"**
```bash
# Reinstall dependencies
pip install -r requirements.txt
```

**Issue: "Database locked"**
```bash
# Remove old database and recreate
rm hpai.db
python -c "from app.database.init_db import create_tables; create_tables()"
```

### Frontend Issues

**Issue: "Network connection refused"**
- Check if backend is running: `http://localhost:8000`
- On Android emulator, use `http://10.0.2.2:8000` instead of `127.0.0.1`
- On iOS simulator, use `http://localhost:8000`

**Issue: "Microphone permission denied"**
- Android: Grant permission in Settings → Apps → HPAI-OS → Permissions
- iOS: Go to Settings → Privacy → Microphone → Allow

**Issue: "File picker not working"**
```bash
# Rebuild app
flutter clean
flutter pub get
flutter run
```

---

## PROJECT STRUCTURE

```
HPAI-OS/
├── backend/                 # FastAPI Backend
│   ├── app/
│   │   ├── api/            # REST Endpoints
│   │   │   ├── auth.py
│   │   │   ├── chat.py
│   │   │   ├── pdf_chat.py
│   │   │   ├── voice_chat.py
│   │   │   ├── stream_chat.py
│   │   │   ├── digital_twin.py
│   │   │   ├── dashboard.py
│   │   │   └── profile.py
│   │   ├── agents/         # AI Agents
│   │   │   ├── tutor_agent.py
│   │   │   ├── planner_agent.py
│   │   │   ├── career_agent.py
│   │   │   ├── motivation_agent.py
│   │   │   └── router.py
│   │   ├── rag/            # PDF Q&A
│   │   │   ├── pdf_parser.py
│   │   │   ├── chunker.py
│   │   │   ├── embedder.py
│   │   │   ├── vector_store.py
│   │   │   ├── retriever.py
│   │   │   └── rag_pipeline.py
│   │   ├── voice/          # Voice Processing
│   │   │   ├── speech_to_text.py
│   │   │   ├── text_to_speech.py
│   │   │   └── voice_pipeline.py
│   │   ├── services/       # Business Logic
│   │   ├── models/         # Database Models
│   │   ├── database/       # DB Setup
│   │   ├── core/           # Security, Config
│   │   └── main.py         # App Entry
│   ├── requirements.txt
│   └── README.md
│
└── frontend/                # Flutter Frontend
    ├── lib/
    │   ├── main.dart
    │   ├── screens/         # UI Screens
    │   ├── services/        # API Services
    │   ├── models/          # Data Models
    │   ├── widgets/         # Reusable Widgets
    │   ├── providers/       # State Management
    │   ├── theme/           # UI Theme
    │   └── utils/           # Utilities
    ├── pubspec.yaml
    └── README.md
```

---

## DEPLOYMENT

### Deploy Backend to Production
```bash
# Using Gunicorn + Nginx
pip install gunicorn
gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

### Deploy Frontend
```bash
# Build Android APK
flutter build apk

# Build iOS IPA
flutter build ios

# Build Web
flutter build web
```

---

## API ENDPOINTS

### Authentication
- `POST /register` - Register new user
- `POST /login` - Login user

### Chat
- `POST /chat` - Send message to AI
- `WebSocket /ws/chat` - Real-time streaming chat

### PDF
- `POST /upload-pdf` - Upload PDF document
- `POST /ask-pdf` - Ask question about PDF

### Voice
- `POST /voice-chat` - Send voice message

### Profile & Settings
- `GET /profile` - Get user profile
- `POST /profile` - Update profile
- `GET /dashboard` - Get dashboard data
- `POST /digital-twin` - Update digital twin

---

## KEY FEATURES

✨ **Multi-Agent AI System**
- Automatic routing to specialized agents based on keywords
- Context-aware responses

🎤 **Voice First Interface**
- Record voice → Transcribe → AI Response → Speak back
- Works offline with Ollama

📄 **PDF Intelligence**
- Extract and index PDF content
- Similarity-based retrieval
- Context-aware Q&A

🧠 **Memory & Context**
- Maintains conversation history
- Digital twin learning profile
- Adaptive responses

🔐 **Secure Authentication**
- JWT tokens
- Protected endpoints
- User-specific data

---

## NEXT STEPS

1. ✅ Run backend: `cd backend && uvicorn app.main:app --reload`
2. ✅ Run frontend: `cd frontend && flutter run`
3. ✅ Register a test user
4. ✅ Test chat, PDF, and voice features
5. ✅ Check dashboard and profile

**Everything is ready to use! 🎉**

---

## Support & Debugging

Enable verbose logging:
```bash
# Frontend
flutter run -v

# Backend
uvicorn app.main:app --reload --log-level debug
```

Check logs:
- Backend: Logs appear in terminal
- Frontend: Use `flutter logs` in another terminal

---

## Quick Links
- 📖 [FastAPI Docs](http://localhost:8000/docs)
- 🎯 [Ollama Models](https://ollama.ai/library)
- 🔗 [Flutter Docs](https://flutter.dev/docs)
- 🐍 [Python Packages](https://pypi.org)

**Happy Coding! 🚀**
