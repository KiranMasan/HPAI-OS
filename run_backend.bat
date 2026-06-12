@echo off
REM HPAI-OS Backend Startup Script for Windows

echo.
echo ╔═══════════════════════════════════════════╗
echo ║     HPAI-OS Backend Startup Script        ║
echo ║           (FastAPI + Ollama)              ║
echo ╚═══════════════════════════════════════════╝
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found! Please install Python 3.10+
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo ✅ Python found
echo.

REM Check if requirements are installed
echo Checking dependencies...
cd backend

REM Create virtual environment if not exists
if not exist venv (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Recommend Redis usage
if defined REDIS_URL (
    echo Using Redis at %REDIS_URL%
) else (
    echo Tip: set REDIS_URL=redis://localhost:6379/0 to enable Redis-backed caching
)

REM Install/upgrade requirements
echo Installing/upgrading dependencies...
pip install -q -r requirements.txt
if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed
echo.

REM Check if Ollama is running
echo Checking Ollama...
timeout /t 2 /nobreak >nul
curl -s http://localhost:11434 >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Ollama doesn't seem to be running
    echo Please start Ollama separately:
    echo   1. Open Command Prompt
    echo   2. Run: ollama serve
    echo   3. In another window: ollama pull mistral
    echo.
)

REM Initialize database
echo Initializing database...
python -c "from app.database.init_db import create_tables; create_tables()" >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Database initialization had issues (may be normal if already exists)
)

echo ✅ Database ready
echo.

REM Start backend
echo.
echo ╔═══════════════════════════════════════════╗
echo ║   Starting HPAI-OS Backend Server...      ║
echo ║   Listening on http://localhost:8000      ║
echo ║   API Docs: http://localhost:8000/docs    ║
echo ║   Press Ctrl+C to stop                    ║
echo ╚═══════════════════════════════════════════╝
echo.

REM Use 127.0.0.1 instead of 0.0.0.0 on Windows to avoid WinError 10013 socket permissions/binding issues.
set HOST=127.0.0.1
set PORT=8000

echo.
echo Starting with host=%HOST% port=%PORT% ...
uvicorn app.main:app --reload --host %HOST% --port %PORT%

pause

