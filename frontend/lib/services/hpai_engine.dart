class HPAIEngine {

  static int calculateRoadmapProgress({

    required int completedPhases,

    required int totalPhases,

  }) {

    if (totalPhases == 0) {

      return 0;

    }

    return ((completedPhases / totalPhases) * 100).round();

  }

  static int calculateTaskProgress({

    required int completedTasks,

    required int totalTasks,

  }) {

    if (totalTasks == 0) {

      return 0;

    }

    return ((completedTasks / totalTasks) * 100).round();

  }

  static int calculateHumanProgress({

    required int roadmapProgress,

    required int taskProgress,

  }) {

    return ((roadmapProgress * 0.6) + (taskProgress * 0.4))

        .round();

  }
}

