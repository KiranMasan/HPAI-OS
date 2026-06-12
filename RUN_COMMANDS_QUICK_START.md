# 🚀 HPAI-OS - RUN COMMANDS (Updated May 29, 2026)

## ⚡ QUICK START (Copy & Paste Ready)

### Step 1️⃣ : Open Terminal 1 - Start Ollama

```bash
ollama serve
```

**Expected Output:**
```
Listening on 127.0.0.1:11434
```

---

### Step 2️⃣ : Open Terminal 2 - Start Backend

```bash
cd backend
venv\Scripts\activate
uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

**Expected Output:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Application startup complete.
```

---

### Step 3️⃣ : Open Terminal 3 - Start Frontend

```bash
cd frontend
flutter pub get
flutter run
```

**Expected Output:**
```
Flutter is running your Flutter app on Android/iOS emulator
```

---

## ✅ VERIFICATION TESTS

After all three terminals show success, run these tests:

### Test 1: Backend is Responding
```bash
curl http://127.0.0.1:8000/
```

**Expected:**
```json
{"message": "HPAI-OS Running 🚀"}
```

### Test 2: Register User
```bash
curl -X POST http://127.0.0.1:8000/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

**Expected:**
```json
{"message": "User registered successfully"}
```

### Test 3: Login
```bash
curl -X POST http://127.0.0.1:8000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

**Expected:**
```json
{"access_token": "eyJhbGc....", "token_type": "bearer"}
```

---

## 🔧 TROUBLESHOOTING

### ❌ "Address already in use" on port 8000

**Solution:**
```bash
# Find what's using port 8000
netstat -ano | findstr :8000

# Kill the process (replace PID with actual number)
taskkill /PID <PID> /F

# Then restart backend
```

### ❌ "Ollama is not reachable"

**Solution:**
```bash
# Make sure Ollama is running in Terminal 1
# Verify Ollama is serving:
curl http://127.0.0.1:11434/

# If that fails, restart Ollama:
# Kill Ollama process and run: ollama serve
```

### ❌ "Microphone permission denied" (NEW FIX ✅)

**Solution:**
- Android: Check Settings → Apps → Frontend → Permissions → Microphone
- iOS: Grant permission when prompted on first run
- **This is now properly handled with the permission_handler package** ✅

### ❌ "WebSocket disconnect" errors (NEW FIX ✅)

**Solution:**
- Errors are now handled gracefully
- Application will auto-reconnect if connection drops
- **This has been fixed in stream_chat.py** ✅

### ❌ "/ask-pdf returns 500" (NEW FIX ✅)

**Solution:**
- Make sure PDF was uploaded first
- Check Ollama is running with mistral model
- **This has been fixed in rag_pipeline.py** ✅

---

## 📋 COMPLETE FILE CHANGES (May 29, 2026)

### Backend Files Modified
```
✅ backend/app/api/stream_chat.py
   - Added WebSocket disconnect handling
   - Added error recovery
   
✅ backend/app/rag/rag_pipeline.py
   - Fixed ask_pdf() return type
   - Added validation
```

### Frontend Files Modified
```
✅ frontend/lib/services/voice_service.dart
   - Added permission_handler import
   - Added requestMicrophonePermission()
   - Updated startRecording() with proper permissions
   
✅ frontend/pubspec.yaml
   - Added permission_handler: ^11.4.3
   
✅ frontend/ios/Runner/Info.plist
   - Added NSMicrophoneUsageDescription
```

---

## 🎯 FINAL CHECKLIST

Before you start, make sure:

- [ ] Python 3.10+ installed
- [ ] Flutter SDK installed  
- [ ] Ollama installed
- [ ] Backend venv created: `python -m venv backend/venv`
- [ ] Backend dependencies installed: `pip install -r requirements.txt`
- [ ] Frontend dependencies updated: `flutter pub get`

---

## 🚀 GO! 

Run the 3 terminals in order, then test. Everything should work perfectly now! ✅

**All errors from May 29 have been fixed:**
1. ✅ WebSocket disconnect handled
2. ✅ /ask-pdf returns proper responses
3. ✅ Microphone permissions working

---

## 📞 QUICK HELP

**Q: Can I run on a different port?**  
A: Yes! Change `--port 8000` to your desired port

**Q: Can I run on 0.0.0.0 instead of localhost?**  
A: Yes! Change `--host 127.0.0.1` to `--host 0.0.0.0`

**Q: How do I stop everything?**  
A: Press CTRL+C in each terminal

**Q: Where are the logs?**  
A: Check each terminal for output

---

**Last Updated:** May 29, 2026 (All Errors Fixed ✅)
