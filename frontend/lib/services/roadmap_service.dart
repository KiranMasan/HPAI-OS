class RoadmapService {

  static List<String> generateRoadmap(
    String goal,
  ) {

    goal = goal.toLowerCase();

    if (goal.contains("ai")) {

      return [

        "Python Fundamentals",

        "NumPy & Pandas",

        "Machine Learning",

        "Deep Learning",

        "AI Projects",

        "Resume & Interview Prep",
      ];
    }

    if (goal.contains("flutter")) {

      return [

        "Dart Basics",

        "Flutter Widgets",

        "State Management",

        "API Integration",

        "Firebase",

        "Deploy App",
      ];
    }

    if (goal.contains("data")) {

      return [

        "Python",

        "Statistics",

        "Data Analysis",

        "Machine Learning",

        "Visualization",

        "Projects",
      ];
    }

    return [

      "Foundation",

      "Core Skills",

      "Practice",

      "Projects",

      "Advanced Topics",

      "Career Preparation",
    ];
  }
}