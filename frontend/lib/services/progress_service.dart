class ProgressService {

  static Map<String, int>
      calculateProgress(
    int completed,
    int total,
  ) {

    double ratio =
        completed / total;

    return {

      "goal":
          (ratio * 100).round(),

      "career":
          (ratio * 85).round(),

      "learning":
          (ratio * 90).round(),

      "human":
          (ratio * 95).round(),
    };
  }
}