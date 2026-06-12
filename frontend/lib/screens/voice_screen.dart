import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/voice_service.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  bool isRecording = false;
  bool isLoading = false; // waiting for backend
  bool isAssistantSpeaking = false;

  String transcription = '';
  String response = '';
  String audioUrl = '';

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    VoiceService.setOnAudioComplete(_onAudioComplete);
  }

  void _onAudioComplete() {
    if (!mounted) return;
    setState(() {
      isAssistantSpeaking = false;
      isRecording = false;
      isLoading = false;
    });
  }

  Future<void> toggleRecording() async {
    if (!mounted) return;
    if (isLoading) return;

    try {
      // If currently recording -> stop and send to backend
      if (isRecording) {
        setState(() {
          isRecording = false;
          isLoading = true;
          errorMessage = null;
        });

        await VoiceService.stopRecording();

        final result = await VoiceService.sendVoiceMessage();

        setState(() {
          isLoading = false;
        });

        if (result.containsKey('error')) {
          final msg = result['error']?.toString() ?? 'Unknown error';
          setState(() {
            errorMessage = msg;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Voice error: $msg')),
            );
          }
          return;
        }

        final rawData = result['data'];
        if (rawData == null) {
          setState(() {
            errorMessage = 'Backend returned empty data.';
          });
          return;
        }

        final dynamic decoded =
            rawData is String ? jsonDecode(rawData) : rawData;

        final returnedAudioPath =
            decoded['audio_url'] ?? decoded['audio_path'] ?? '';

        setState(() {
          transcription = decoded['transcription']?.toString() ?? '';
          response = decoded['response']?.toString() ?? '';
          audioUrl = returnedAudioPath is String ? returnedAudioPath : '';
          isAssistantSpeaking = audioUrl.isNotEmpty;
          if (audioUrl.isNotEmpty) {
            // clear any previous text while speaking
            // (optional; keep response visible below)
          }
        });

        if (audioUrl.isNotEmpty) {
          await VoiceService.playAudio(audioUrl);
        }

        return;
      }

      // Not recording -> start recording
      setState(() {
        isLoading = false;
        errorMessage = null;
      });

      final started = await VoiceService.startRecording();
      if (!started) {
        const msg = 'Microphone not available or permission denied';
        setState(() {
          errorMessage = msg;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone not available')),
          );
        }
        return;
      }

      setState(() {
        isRecording = true;
        isAssistantSpeaking = false;
        transcription = '';
        response = '';
        audioUrl = '';
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isRecording = false;
        isLoading = false;
        isAssistantSpeaking = false;
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    // stop any playing audio and dispose recorder
    VoiceService.stopAudio();
    VoiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk with Assistant 🎙️'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: isLoading ? null : toggleRecording,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Colors.red
                          : (isLoading
                              ? Colors.grey
                              : (isAssistantSpeaking
                                  ? Colors.orangeAccent
                                  : Colors.blueAccent)),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording
                                  ? Colors.red
                                  : (isLoading
                                      ? Colors.grey
                                      : (isAssistantSpeaking
                                          ? Colors.orangeAccent
                                          : Colors.blueAccent)))
                              .withValues(alpha: 0.5),
                          spreadRadius: 5,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            size: 80,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                errorMessage != null
                    ? 'Error. Tap mic to try again.'
                    : isRecording
                        ? 'Recording... speak naturally.'
                        : (isLoading
                            ? 'Processing your audio...'
                            : (isAssistantSpeaking
                                ? 'Assistant is speaking...'
                                : 'Tap mic to talk with me 🎤')),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'How Was Your Day Goinig? Ask me anything or share your thoughts!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              if (transcription.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You said:',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transcription,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isAssistantSpeaking)
                const SizedBox(height: 20),
              if (isAssistantSpeaking)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orangeAccent),
                  ),
                  child: const Text(
                    'Assistant is speaking... 🎧',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

              if (!isAssistantSpeaking && response.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Astra says:',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        response,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

