import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'network_utils.dart';

class PDFService {
  static Future<void> uploadPDF(File file) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated: Please login first');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${NetworkUtils.baseUrl}/upload-pdf'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Upload timeout'),
      );

      final body = await response.stream.bytesToString();

      if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        try {
          final errorData = jsonDecode(body);
          throw Exception('Upload failed: ${errorData['detail'] ?? response.statusCode}');
        } catch (e) {
          throw Exception('Upload failed: ${response.statusCode} - $body');
        }
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  static Future<String> askQuestion(String question) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated: Please login first');
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('${NetworkUtils.baseUrl}/ask-pdf'),
        headers: headers,
        body: jsonEncode({'question': question}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'];
        if (answer == null || answer.toString().isEmpty) {
          throw Exception('No answer found from server');
        }
        return answer.toString();
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception('Failed to ask question: ${errorData['detail'] ?? response.statusCode}');
        } catch (e) {
          throw Exception('Failed to ask question: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Question failed: $e');
    }
  }
}
