import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'network_utils.dart';

class ApiService {
  static String get baseUrl => NetworkUtils.baseUrl;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return {
        'Content-Type': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> verifyToken() async {
    try {
      final headers = await _authHeaders();
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/verify-token'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('timeout', 408),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String> sendMessage(String message) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: headers,
      body: jsonEncode({
        'message': message,
      }),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => http.Response('timeout', 408),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please login again');
    }

    if (response.statusCode != 200) {
      throw Exception('Chat failed: ${response.statusCode} - ${response.body}');
    }

    try {
      final data = jsonDecode(response.body);
      final responseText = data['response'];

      if (responseText == null || responseText.toString().isEmpty) {
        throw Exception('Empty response from server');
      }

      return responseText.toString();
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }
}

