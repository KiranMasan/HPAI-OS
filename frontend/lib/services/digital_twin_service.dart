import 'goal_service.dart';
import 'task_service.dart';

class DigitalTwinService {

  static Future<Map<String, dynamic>>
      getTwinProfile() async {

    final goalData =
        await GoalService.getGoalData();

    final tasks =
        await TaskService.getTasks();

    int completed = tasks
        .where(
          (task) =>
              task["completed"] == true,
        )
        .length;

    int total = tasks.length;

    int progress = total == 0
        ? 0
        : ((completed / total) * 100)
            .round();

    String status =
        progress >= 70
            ? "On Track"
            : "Needs Attention";

    return {

      "goal":
          goalData["goal"] ?? "",

      "hours":
          goalData["hours"] ?? "",

      "level":
          goalData["level"] ?? "",

      "target":
          goalData["target"] ?? "",

      "progress":
          progress,

      "status":
          status,
    };
  }
}