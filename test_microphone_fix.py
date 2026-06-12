#!/usr/bin/env python3
"""
Microphone Permission Fix Test Script
Helps verify the Flutter app can record audio after permission fix
"""

import subprocess
import time
import sys

def run_command(cmd, description):
    """Run a command and display output"""
    print(f"\n{'='*60}")
    print(f"🔧 {description}")
    print(f"{'='*60}")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print("STDERR:", result.stderr)
        return result.returncode == 0
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("\n" + "="*60)
    print("🎙️  MICROPHONE PERMISSION FIX - TEST SCRIPT")
    print("="*60)
    
    # Step 1: Clean
    print("\n📋 Step 1: Cleaning Flutter project...")
    if not run_command("cd frontend && flutter clean", "Running flutter clean"):
        print("⚠️  Warning: flutter clean may have issues")
    
    # Step 2: Get dependencies
    print("\n📋 Step 2: Getting dependencies...")
    if not run_command("cd frontend && flutter pub get", "Running flutter pub get"):
        print("❌ Failed to get dependencies")
        sys.exit(1)
    
    # Step 3: Check ADB
    print("\n📋 Step 3: Checking Android devices...")
    result = subprocess.run("adb devices", shell=True, capture_output=True, text=True)
    print(result.stdout)
    
    if "emulator" not in result.stdout.lower() and "device" not in result.stdout.lower():
        print("⚠️  WARNING: No Android device/emulator detected!")
        print("Please start an emulator or connect a device first")
    
    # Step 4: Uninstall old app
    print("\n📋 Step 4: Uninstalling old app...")
    run_command("adb uninstall com.example.frontend", "Removing old app")
    
    # Step 5: Run app
    print("\n📋 Step 5: Building and running app...")
    print("This will take a minute...")
    run_command("cd frontend && flutter run --no-fast-start -v", "Running app with verbose output")
    
    # Step 6: Monitor logs
    print("\n📋 Step 6: Monitoring app logs (running for 10 seconds)...")
    print("Look for these messages:")
    print("  ✅ Microphone permission GRANTED")
    print("  ✅ Recording started successfully")
    print("  ✅ Starting recording at: /data/data/com.example.frontend/cache/voice_*.m4a")
    
    start_time = time.time()
    while time.time() - start_time < 10:
        result = subprocess.run("flutter logs", shell=True, capture_output=True, text=True, timeout=2)
        if result.stdout:
            print(result.stdout[-500:])  # Show last 500 chars
        time.sleep(1)
    
    print("\n" + "="*60)
    print("✅ MICROPHONE FIX TEST COMPLETE")
    print("="*60)
    print("\nNext steps:")
    print("1. Open the app and go to Voice Assistant screen")
    print("2. Tap the microphone button")
    print("3. Grant permission when prompted")
    print("4. Speak and check if recording works")
    print("\nIf issues persist:")
    print("- Check Android Settings → Apps → frontend → Permissions → Microphone")
    print("- Ensure microphone is enabled in emulator settings")
    print("- Run: adb logcat | grep flutter")

if __name__ == "__main__":
    main()
