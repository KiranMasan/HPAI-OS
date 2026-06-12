class CoachService {

  static String generateAdvice({

    required String goal,

    required int completed,

    required int total,
  }) {

    if (total == 0) {

      return
          "Start your first mission today.";
    }

    double progress =
        completed / total;

    if (progress >= 0.8) {

      return
          "Excellent progress. You are ready for the next roadmap phase.";
    }

    if (progress >= 0.5) {

      return
          "Good progress. Complete remaining tasks to stay on track.";
    }

    return
        "Focus on completing today's mission before moving ahead.";
  }
}