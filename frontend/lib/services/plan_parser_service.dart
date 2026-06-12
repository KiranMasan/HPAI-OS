class PlanParserService {

  static List<String> extractRoadmap(
      String plan) {

    final lines =
        plan.split("\n");

    bool roadmap = false;

    List<String> items = [];

    for (final line in lines) {

      if (line.contains("ROADMAP")) {

        roadmap = true;

        continue;
      }

      if (line.contains("TASKS")) {

        roadmap = false;

      }

      if (roadmap &&
          line.trim().isNotEmpty) {

        items.add(line.trim());
      }
    }

    return items;
  }

  static List<String> extractTasks(
      String plan) {

    final lines =
        plan.split("\n");

    bool tasks = false;

    List<String> items = [];

    for (final line in lines) {

      if (line.contains("TASKS")) {

        tasks = true;

        continue;
      }

      if (line.contains(
          "RECOMMENDATION")) {

        tasks = false;
      }

      if (tasks &&
          line.trim().isNotEmpty) {

        items.add(line.trim());
      }
    }

    return items;
  }

  static String extractRecommendation(
      String plan) {

    final index =
        plan.indexOf(
      "RECOMMENDATION",
    );

    if (index == -1) {

      return "";
    }

    return plan
        .substring(index)
        .replaceAll(
          "RECOMMENDATION:",
          "",
        )
        .trim();
  }
}

