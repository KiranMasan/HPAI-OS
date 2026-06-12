# HPAI-OS Complete Startup Guide

## Prerequisites
- Python 3.9+
- Flutter 3.0+
- Node.js (optional, for web support)
- PostgreSQL or SQLite (backend uses SQLite by default)

## Backend Setup

### 1. Create Python Virtual Environment
```bash
cd backend
python -m venv venv
# On Windows
venv\Scripts\activate
# On macOS/Linux
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 3. Initialize Database
```bash
python -c "from app.database.init_db import create_tables; create_tables()"
```

### 4. Start Backend Server
```bash
# Using Uvicorn directly
uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload

# OR using the batch file (Windows)
run_backend.bat
```

Expected output:
```
Uvicorn running on http://127.0.0.1:8000
```

## Frontend Setup

### 1. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 2. Run the Application

#### For Android
```bash
flutter run -d android
```

#### For iOS
```bash
flutter run -d ios
```

#### For Web
```bash
flutter run -d chrome
```

#### Using Batch File (Windows)
```bash
run_frontend.bat
```

## Testing Authentication Flow

### 1. Create Test User
Use REST client or curl:
```bash
curl -X POST http://127.0.0.1:8000/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 2. Login
```bash
curl -X POST http://127.0.0.1:8000/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Save the `access_token` from response.

### 3. Verify Token
```bash
curl -X GET http://127.0.0.1:8000/verify-token \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## API Endpoints Reference

### Authentication
- `POST /register` - Register new user
- `POST /login` - Login and get token
- `GET /verify-token` - Verify token is valid (requires auth)

### Chat
- `POST /chat` - Send chat message (requires auth)
- `WebSocket /ws/chat` - Streaming chat connection (requires token in query)

### PDF
- `POST /upload-pdf` - Upload PDF file (requires auth)
- `POST /ask-pdf` - Ask question about PDF (requires auth)

### Voice
- `POST /voice-chat` - Send voice message (requires auth)

### Dashboard & Profile
- `GET /dashboard` - Get dashboard data (requires auth)
- `GET /profile` - Get user profile (requires auth)

## Troubleshooting

### Backend Issues

#### 401 Unauthorized Errors
- Ensure token is being sent in Authorization header: `Bearer <token>`
- Verify token is not expired (24 hours expiration)
- Check if user exists in database
- Verify SECRET_KEY hasn't changed

#### Port Already in Use
```bash
# On Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# On macOS/Linux
lsof -i :8000
kill -9 <PID>
```

#### Database Connection Issues
- Ensure database file exists in backend directory
- Check file permissions
- Try deleting `hpai.db` to reinitialize

### Frontend Issues

#### Token Not Persisting
- Check SharedPreferences is working
- Verify token is being saved after login
- Clear app data and retry: `flutter clean`

#### Network Connection Failed
- Verify backend is running on 127.0.0.1:8000
- For Android: Use 10.0.2.2:8000 (emulator)
- Check CORS middleware is enabled (should be)
- Firewall may be blocking connections

#### Build Errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

## Development Workflow

### 1. Terminal Setup
Open two terminals:
- Terminal 1: Backend (Uvicorn)
- Terminal 2: Frontend (Flutter)

### 2. Make Changes
- Backend changes: Auto-reloaded with `--reload`
- Frontend changes: Use hot reload (R) in Flutter

### 3. Testing
- Test each endpoint using curl or REST client
- Test frontend with running emulator/device
- Monitor logs for errors

## Environment Configuration

### Backend Environment Variables (optional)
Create `backend/.env` file:
```
SECRET_KEY=hpai_secret_key
DATABASE_URL=sqlite:///hpai.db
ACCESS_TOKEN_EXPIRE_MINUTES=1440
```

### Frontend Configuration
Edit `frontend/lib/services/network_utils.dart` to change API URL.

## Performance Optimization

1. **Backend**: Use production ASGI server instead of Uvicorn
2. **Frontend**: Enable code obfuscation in release build
3. **Database**: Add indexes for frequently queried fields
4. **Caching**: Implement response caching in frontend

## Security Notes

1. Change SECRET_KEY in production
2. Use HTTPS in production
3. Store sensitive data securely
4. Validate all user inputs
5. Implement rate limiting
6. Use strong passwords

## Monitoring

### Backend Logs
- Check console output for errors
- Enable detailed logging in security.py
- Monitor database queries

### Frontend Logs
```bash
flutter run -v  # Verbose logging
```

## Deployment

### Backend (Production)
```bash
gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

### Frontend (Production Build)
```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## Support

If you encounter issues:
1. Check logs in console
2. Verify all services are running
3. Test endpoints with curl
4. Check network connectivity
5. Review error messages carefully
