import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TaskService {

  static Future<void> saveTasks(
      List<Map<String, dynamic>> tasks) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      "tasks",
      jsonEncode(tasks),
    );
  }

  static Future<List<Map<String, dynamic>>>
      getTasks() async {

    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getString("tasks");

    if (data == null) {

      return [];
    }

    final decoded =
        jsonDecode(data) as List;

    return decoded
        .map(
          (e) =>
              Map<String, dynamic>.from(e),
        )
        .toList();
  }
}