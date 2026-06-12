import 'package:shared_preferences/shared_preferences.dart';

class GoalService {

  static Future<void> saveGoal({
    required String goal,
    required String level,
    required String hours,
    required String target,
  }) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString("goal", goal);

    await prefs.setString("level", level);

    await prefs.setString("hours", hours);

    await prefs.setString("target", target);
  }

  static Future<Map<String, String>>
      getGoalData() async {

    final prefs =
        await SharedPreferences.getInstance();

    return {

      "goal":
          prefs.getString("goal") ?? "",

      "level":
          prefs.getString("level") ?? "",

      "hours":
          prefs.getString("hours") ?? "",

      "target":
          prefs.getString("target") ?? "",
    };
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      "onboarding_completed",
      true,
    );
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(
          "onboarding_completed",
        ) ??
        false;
  }
}