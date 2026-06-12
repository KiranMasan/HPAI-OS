import 'package:shared_preferences/shared_preferences.dart';

class PlanStorageService {

  static Future<void> savePlan(
    String plan,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      "ai_plan",
      plan,
    );
  }

  static Future<String> getPlan()
      async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
          "ai_plan",
        ) ??
        "";
  }
}

