#!/usr/bin/env python3
"""End-to-end voice assistant test"""
import requests
import time
import wave
import struct
import math
import os
import json

url = 'http://127.0.0.1:8000'
suffix = str(int(time.time()))
user = {
    'email': f'voicetest{suffix}@example.com',
    'username': f'voiceuser{suffix}',
    'password': 'Test1234!'
}

try:
    print('[1/5] Registering user...')
    r = requests.post(url + '/register', json=user, timeout=10)
    print(f'  Status: {r.status_code}')
    
    print('[2/5] Logging in...')
    r = requests.post(url + '/login', json={
        'email': user['email'],
        'password': user['password']
    }, timeout=10)
    token = r.json().get('access_token')
    print(f'  Token obtained')
    
    print('[3/5] Generating test audio...')
    path = os.path.join(os.path.dirname(__file__), 'backend', 'test_audio.wav')
    nframes = 16000
    frames = []
    for t in range(nframes):
        sample = int(32767 * 0.1 * math.sin(2 * math.pi * 440 * t / 16000))
        frames.append(struct.pack('<h', sample))
    
    with wave.open(path, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(16000)
        wf.writeframes(b''.join(frames))
    
    print(f'  Audio file created at {path}')
    
    print('[4/5] Sending voice to API...')
    headers = {'Authorization': f'Bearer {token}'}
    with open(path, 'rb') as f:
        r = requests.post(
            url + '/voice-chat',
            headers=headers,
            files={'file': ('test_audio.wav', f, 'audio/wav')},
            timeout=60
        )
    
    print(f'  Response status: {r.status_code}')
    data = r.json()
    
    transcription = data.get('transcription', '')
    response_text = data.get('response', '')
    audio_path = data.get('audio_path', '')
    audio_url = data.get('audio_url', '')
    
    print(f'  - transcription: {transcription[:50]}...' if transcription else '  - transcription: (empty)')
    print(f'  - response: {response_text[:60]}...' if response_text else '  - response: (empty)')
    print(f'  - audio_path: {audio_path}')
    print(f'  - audio_url: {audio_url}')
    
    if audio_url:
        print(f'[5/5] Fetching audio file...')
        r = requests.get(audio_url, headers=headers, timeout=20)
        print(f'  Audio fetch status: {r.status_code}')
        print(f'  Audio size: {len(r.content)} bytes')
        if r.status_code == 200:
            audio_file = path.replace('.wav', '_response.wav')
            with open(audio_file, 'wb') as f:
                f.write(r.content)
            print(f'  ✓ Audio saved to {audio_file}')
    else:
        print('[5/5] No audio URL in response')
    
    print('\n✓ END-TO-END TEST COMPLETE')
    
except Exception as e:
    print(f'\n✗ TEST FAILED: {e}')
    import traceback
    traceback.print_exc()
