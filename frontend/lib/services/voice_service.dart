import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'network_utils.dart';

class VoiceService {
  static AudioRecorder? _recorder;
  static String? _recordingPath;
  static AudioPlayer? _audioPlayer;
  static Function? _onAudioComplete;

  static void setOnAudioComplete(Function callback) {
    _onAudioComplete = callback;
  }

  static Future<bool> requestMicrophonePermission() async {
    try {
      PermissionStatus status;
      
      if (Platform.isAndroid) {
        debugPrint('========================');
        debugPrint('🎙️ Requesting microphone permission on Android...');
        status = await Permission.microphone.request();
        debugPrint('📊 Android microphone permission status: $status');
        debugPrint('========================');
      } else if (Platform.isIOS) {
        debugPrint('Requesting microphone permission on iOS...');
        status = await Permission.microphone.request();
        debugPrint('iOS microphone permission status: $status');
      } else {
        // For other platforms, just check if recording is available
        debugPrint('Checking recording availability on non-Android/iOS platform...');
    return await _recorder?.hasPermission() ?? false;
      }
      
      if (status.isDenied) {
        debugPrint('❌ Microphone permission DENIED');
        return false;
      } else if (status.isPermanentlyDenied) {
        debugPrint('❌ Microphone permission PERMANENTLY DENIED. Opening app settings...');
        openAppSettings();
        return false;
      } else if (status.isGranted) {
        debugPrint('✅ Microphone permission GRANTED');
        return true;
      } else if (status.isRestricted) {
        debugPrint('❌ Microphone permission RESTRICTED (parental controls)');
        return false;
      }
      
      debugPrint('⚠️ Unknown permission status: $status');
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error requesting microphone permission: $e');
      return false;
    }
  }

  static Future<bool> startRecording() async {
    try {
      // Request permission before starting recording
      final hasPermission = await requestMicrophonePermission();
      
      debugPrint('========================');
      debugPrint('🔐 HAS PERMISSION = $hasPermission');
      debugPrint('========================');
      
      if (!hasPermission) {
        debugPrint('❌ Microphone permission not granted');
        return false;
      }

      String recordPath;
      
      if (Platform.isAndroid) {
        try {
          // Try to use app's cache directory first
          final cacheDir = await getApplicationCacheDirectory();
          recordPath = '${cacheDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
          
          // Ensure directory exists
          if (!cacheDir.existsSync()) {
            cacheDir.createSync(recursive: true);
            debugPrint('📁 Created cache directory');
          }
          debugPrint('✅ Using cache directory: $recordPath');
        } catch (e) {
          debugPrint('⚠️ Error getting cache directory: $e');
          
          // Fallback to temp directory
          try {
            final tempDir = await getTemporaryDirectory();
            recordPath = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
            debugPrint('✅ Fallback to temp directory: $recordPath');
          } catch (e2) {
            debugPrint('⚠️ Error getting temp directory: $e2');
            // Last resort: use hardcoded path
            recordPath = '/sdcard/Music/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
            debugPrint('✅ Last resort path: $recordPath');
          }
        }
      } else {
        final documentsDirectory = await getTemporaryDirectory();
        recordPath = '${documentsDirectory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      _recordingPath = recordPath;
      debugPrint('🎙️ Starting recording at: $_recordingPath');

      _recorder ??= AudioRecorder();

      try {
        await _recorder!.start(

          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 16000,
          ),
          path: _recordingPath!,
        );

        debugPrint('✅ RECORDER STARTED SUCCESSFULLY');
        return true;
      } catch (recordError) {
        debugPrint('❌ RECORDER FAILED: $recordError');
        debugPrint('🔍 Error type: ${recordError.runtimeType}');
        debugPrint('🔍 Error details: ${recordError.toString()}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ CRITICAL ERROR in startRecording: $e');
      debugPrint('🔍 Error type: ${e.runtimeType}');
      debugPrint('🔍 Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  static Future<void> stopRecording() async {
    try {
      final path = await _recorder?.stop();
      if (path != null) {
        _recordingPath = path;
        try {
          final f = File(_recordingPath!);
          debugPrint('🎛️ Recording saved to: $_recordingPath (size=${await f.length()} bytes)');
        } catch (e) {
          debugPrint('⚠️ Could not stat recording file: $e');
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  static Future<Map<String, dynamic>> sendVoiceMessage() async {
    if (_recordingPath == null) {
      return {'error': 'No recording found'};
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'error': 'Not authenticated: Please login first'};
      }

      final request = http.MultipartRequest('POST', Uri.parse('${NetworkUtils.baseUrl}/voice-chat'));
      request.headers['Authorization'] = 'Bearer $token';

      // Debug: ensure file exists and report size
      try {
        final f = File(_recordingPath!);
        final size = await f.length();
        debugPrint('📤 Uploading file: $_recordingPath (bytes=$size) to ${NetworkUtils.baseUrl}/voice-chat');
      } catch (e) {
        debugPrint('⚠️ Could not read recording file before upload: $e');
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', _recordingPath!, contentType: MediaType('audio', 'm4a')),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Voice upload timeout'),
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 401) {
        return {'error': 'Unauthorized: Please login again'};
      }

      debugPrint('📥 Upload response status: ${response.statusCode}');
      debugPrint('📥 Upload response body: $responseBody');

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseBody};
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          return {
            'error': 'Failed to send voice message: ${errorData['detail'] ?? response.statusCode}',
          };
        } catch (e) {
          return {
            'error': 'Failed to send voice message: ${response.statusCode} - $responseBody',
          };
        }
      }
    } catch (e) {
      return {'error': 'Voice message failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> sendTextMessage(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'error': 'Not authenticated: Please login first'};
      }

      final url = Uri.parse('${NetworkUtils.baseUrl}/voice-chat-text');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'text': text}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Voice upload timeout'),
      );

      final responseBody = response.body;
      debugPrint('📥 Text upload response status: ${response.statusCode}');
      debugPrint('📥 Text upload response body: $responseBody');

      if (response.statusCode == 401) {
        return {'error': 'Unauthorized: Please login again'};
      }

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseBody};
      } else {
        try {
          final errorData = jsonDecode(responseBody);
          return {
            'error': 'Failed to send recognized text: ${errorData['detail'] ?? response.statusCode}',
          };
        } catch (e) {
          return {
            'error': 'Failed to send recognized text: ${response.statusCode} - $responseBody',
          };
        }
      }
    } catch (e) {
      return {'error': 'Text message failed: $e'};
    }
  }

  static Future<bool> isRecording() async {
    return await _recorder?.isRecording() ?? false;
  }

  static Future<void> dispose() async {
    await _recorder?.dispose();
    await _audioPlayer?.dispose();
    _recorder = null;
    _recordingPath = null;
    _audioPlayer = null;
  }

  static Future<String?> playAudio(String audioPath) async {
    try {
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();

      _audioPlayer = AudioPlayer();

      // Listen for playback completion
      _audioPlayer!.onPlayerComplete.listen((_) {
        debugPrint('✅ Audio playback completed');
        if (_onAudioComplete != null) {
          _onAudioComplete!();
        }
      });

      String url;
      if (audioPath.startsWith('http')) {
        url = audioPath;
      } else {
        final suffix = audioPath.startsWith('/') ? audioPath : '/$audioPath';
        url = '${NetworkUtils.baseUrl}$suffix';
      }

      if (Platform.isAndroid) {
        if (url.contains('127.0.0.1')) {
          url = url.replaceFirst('127.0.0.1', '10.0.2.2');
        } else if (url.contains('localhost')) {
          url = url.replaceFirst('localhost', '10.0.2.2');
        }
      }

      debugPrint('Resolved audio URL: $url');

      // Always try streaming playback first. If it fails, download and play from local storage.
      try {
        await _audioPlayer!.play(UrlSource(url, mimeType: 'audio/wav'));
        return url;
      } catch (e) {
        debugPrint('Direct audio URL playback failed, trying fallback download: $e');
      }

      final tempFile = await _downloadAudioToTempFile(url, null);
      if (tempFile != null) {
        debugPrint('Playing audio from local temp file: ${tempFile.path}');
        await _audioPlayer!.play(DeviceFileSource(tempFile.path));
        return tempFile.path;
      }

      return null;
    } catch (e) {
      debugPrint('Audio playback error: $e');
      return null;
    }
  }

  static Future<File?> _downloadAudioToTempFile(String url, Map<String, String>? headers) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final tempFile = File('${directory.path}/voice_response_${DateTime.now().millisecondsSinceEpoch}.wav');
        await tempFile.writeAsBytes(response.bodyBytes);
        return tempFile;
      }

      debugPrint('Failed to download audio file: ${response.statusCode} ${response.reasonPhrase}');
      return null;
    } catch (e) {
      debugPrint('Audio download fallback failed: $e');
      return null;
    }
  }

  static Future<void> stopAudio() async {
    try {
      await _audioPlayer?.stop();
    } catch (_) {
      // silently ignore stop errors
    }
  }
}
