# HPAI-OS - Quick Start Checklist 🚀

## ⚡ 5-Minute Quick Start for Windows

### Prerequisites Check
- [ ] Python 3.10+ installed (test: `python --version`)
- [ ] Flutter installed (test: `flutter --version`)
- [ ] Ollama downloaded from https://ollama.ai

### Step 1: Start Backend (2 min)
```
1. Double-click: run_backend.bat
2. Wait for: "Listening on http://localhost:8000"
3. Leave this window open
```

### Step 2: Start Ollama (in another window)
```
1. Open Command Prompt
2. Run: ollama serve
3. In another Command Prompt, run: ollama pull mistral
4. Wait for model to download (~5 min)
```

### Step 3: Start Frontend (2 min)
```
1. Double-click: run_frontend.bat
2. Select your device when prompted
3. Wait for app to load
```

### Step 4: Test the App
```
1. Tap "Sign Up"
2. Create account (any email/password)
3. Tap one of the feature tabs:
   ✓ Chat - Send a message
   ✓ Voice - Tap mic to record
   ✓ PDF - Upload a PDF document
```

---

## 🎯 Feature Quick Guide

### 💬 Chat with AI
- **Type:** "Explain machine learning"
- **What happens:** Routes to Tutor Agent, gives explanation

### 📅 Planning
- **Type:** "Create a weekly schedule"
- **What happens:** Routes to Planner Agent, creates schedule

### 💼 Career Help
- **Type:** "How to write a resume"
- **What happens:** Routes to Career Agent, gives advice

### 🌟 Motivation
- **Type:** "I'm stressed"
- **What happens:** Routes to Motivation Agent, provides support

### 🎤 Voice Commands
- **Action:** Tap blue mic button and speak
- **Example:** "What is Python programming"
- **Result:** Transcribed, answered, and spoken back

### 📄 PDF Questions
- **Action:** Upload a PDF, ask questions about it
- **Example:** Upload a book chapter, ask "What's the main idea?"
- **Result:** AI searches PDF and answers with citations

---

## 🔧 Common Commands

### Backend Commands
```bash
# If run_backend.bat doesn't work
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Frontend Commands
```bash
# If run_frontend.bat doesn't work
cd frontend
flutter pub get
flutter run

# List devices
flutter devices

# Run on specific device
flutter run -d <device_name>
```

### Check if Services are Running
```bash
# Check Backend
curl http://localhost:8000

# Check Ollama
curl http://localhost:11434

# Check Ollama Models
ollama list
```

---

## 🐛 Quick Troubleshooting

### Backend Won't Start
```
❌ "Module not found"
✅ Fix: pip install -r requirements.txt

❌ "Port 8000 already in use"
✅ Fix: Change port in uvicorn command: --port 8001

❌ "Ollama connection refused"
✅ Fix: Make sure ollama serve is running in another terminal
```

### Frontend Won't Run
```
❌ "Flutter not found"
✅ Fix: Add Flutter to PATH or reinstall

❌ "Device not found"
✅ Fix: Run 'flutter devices' and check devices

❌ "Connection refused to backend"
✅ Fix: Check backend is running on :8000
       For Android emulator use: http://10.0.2.2:8000
```

### Voice Not Working
```
❌ "Microphone permission denied"
✅ Fix: Android Settings → Apps → Permissions → Microphone → Allow

❌ "No audio heard"
✅ Fix: Check device volume, check pyttsx3 is installed
```

### PDF Not Uploading
```
❌ "PDF upload failed"
✅ Fix: Check file size < 50MB
       Try with a smaller test PDF
       Check backend logs for errors

❌ "Answer not in document"
✅ Fix: This is expected - PDF Q&A works with content in PDF
```

---

## 📊 What Should You See

### Successful Backend Start
```
INFO:     Application startup complete
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Successful Frontend Run
```
Connected to backend: http://localhost:8000
✓ App loads with login screen
```

### Successful Ollama
```
Listening on 127.0.0.1:11434
```

### Successful Chat
```
You: "Explain AI"
AI: "Artificial Intelligence is..."
```

### Successful Voice
```
Recording...
Processing...
You said: [your transcription]
Assistant says: [AI response]
```

### Successful PDF
```
PDF uploaded successfully!
You: "What is the topic?"
AI: [answer from PDF]
```

---

## 📞 Need Help?

1. **Check Backend Docs** → http://localhost:8000/docs
2. **Check Logs** → Look at terminal output
3. **Restart Everything** → Close all windows, start fresh
4. **Read SETUP_AND_RUN.md** → Complete setup guide
5. **Check PROJECT_COMPLETION.md** → Feature list

---

## ✅ Success Checklist

- [ ] Backend running on http://localhost:8000
- [ ] Ollama running and mistral model downloaded
- [ ] Frontend app loading without errors
- [ ] Can register/login successfully
- [ ] Can send chat message and get response
- [ ] Can see PDF upload screen
- [ ] Can see voice assistant screen
- [ ] Can use at least one feature (chat/PDF/voice)

---

## 🎉 You're Ready!

If all checkboxes are checked, your HPAI-OS is fully functional!

Start with Chat or Voice to test the basic flow, then try PDF features.

**Enjoy your AI learning assistant! 🚀**

---

## 💡 Pro Tips

1. **Faster Development** - Use VS Code for editing
2. **Better Debugging** - Keep browser open to http://localhost:8000/docs
3. **Test Offline** - Everything works offline once running
4. **Customize Models** - Change Ollama model in config
5. **Save Conversations** - Check database in backend directory

---

## 📚 Resources

- Ollama Models: https://ollama.ai/library
- Flutter Docs: https://flutter.dev/docs
- FastAPI Docs: https://fastapi.tiangolo.com/
- Python Docs: https://python.org/docs

---

**Questions? Check the full SETUP_AND_RUN.md guide for detailed instructions.**

**Ready to go! Double-click run_backend.bat and run_frontend.bat! 🚀**
