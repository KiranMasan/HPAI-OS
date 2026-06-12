@echo off
REM =====================================================
REM Microphone Permission Fix - Quick Test Script (Windows)
REM =====================================================

echo.
echo =====================================================
echo 🎙️  MICROPHONE PERMISSION FIX - QUICK TEST
echo =====================================================
echo.

REM Step 1: Clean
echo 📋 Step 1: Cleaning Flutter project...
cd frontend
call flutter clean
if errorlevel 1 (
    echo ⚠️  Warning: flutter clean had issues
)

REM Step 2: Get dependencies  
echo.
echo 📋 Step 2: Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ❌ Failed to get dependencies
    pause
    exit /b 1
)

REM Step 3: Check devices
echo.
echo 📋 Step 3: Checking Android devices...
call adb devices

REM Step 4: Uninstall old app
echo.
echo 📋 Step 4: Uninstalling old app...
call adb uninstall com.example.frontend

REM Step 5: Run app
echo.
echo 📋 Step 5: Building and running app (this takes a minute)...
echo When you see the app, please:
echo   1. Open Voice Assistant screen
echo   2. Tap the microphone button
echo   3. Grant permission when prompted
echo   4. Try recording
echo.
call flutter run --no-fast-start

REM Step 6: Show logs
echo.
echo 📋 Step 6: Starting logs...
echo Look for these messages:
echo   ✅ Microphone permission GRANTED
echo   ✅ Recording started successfully
echo   ✅ Starting recording at: ...
echo.
echo Press Ctrl+C to stop logs
call flutter logs

REM Summary
echo.
echo =====================================================
echo ✅ MICROPHONE FIX TEST COMPLETE
echo =====================================================
echo.
echo If microphone still doesn't work:
echo 1. Check Settings ^> Apps ^> frontend ^> Permissions ^> Microphone
echo 2. Make sure "Allow" is selected
echo 3. Uninstall and reinstall the app
echo 4. Check emulator microphone is enabled
echo.
pause
