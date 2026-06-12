import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'network_utils.dart';

class DashboardService {
  static Future<Map<String, dynamic>> fetchDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${NetworkUtils.baseUrl}/dashboard'),
      headers: token == null || token.isEmpty
          ? {
              'Content-Type': 'application/json',
            }
          : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
    );

    return jsonDecode(response.body);
  }
}
