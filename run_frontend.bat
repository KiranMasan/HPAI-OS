@echo off
REM HPAI-OS Frontend Startup Script for Windows

echo.
echo ╔═══════════════════════════════════════════╗
echo ║     HPAI-OS Frontend Startup Script       ║
echo ║           (Flutter Mobile App)            ║
echo ╚═══════════════════════════════════════════╝
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter not found!
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    echo.
    echo Quick steps:
    echo   1. Download Flutter from https://flutter.dev/docs/get-started/install/windows
    echo   2. Extract to a folder (e.g., C:\flutter)
    echo   3. Add to PATH: C:\flutter\bin
    echo   4. Run: flutter doctor
    pause
    exit /b 1
)

echo ✅ Flutter found
flutter --version
echo.

cd frontend

REM Check if pubspec.yaml exists
if not exist pubspec.yaml (
    echo ❌ pubspec.yaml not found in frontend directory
    pause
    exit /b 1
)

echo Getting Flutter dependencies...
flutter pub get

echo.
echo ╔═══════════════════════════════════════════╗
echo ║   Available Devices:                      ║
echo ╚═══════════════════════════════════════════╝
echo.

flutter devices

echo.
echo ╔═══════════════════════════════════════════╗
echo ║   Starting Flutter App...                 ║
echo ║                                           ║
echo ║   Make sure:                             ║
echo ║   ✓ Backend is running on :8000         ║
echo ║   ✓ An emulator/device is connected     ║
echo ║                                           ║
echo ║   Press Ctrl+C to stop                   ║
echo ╚═══════════════════════════════════════════╝
echo.

flutter run

pause
