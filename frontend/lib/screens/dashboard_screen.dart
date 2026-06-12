import 'package:flutter/material.dart';

import '../services/goal_service.dart';
import '../services/task_service.dart';
import '../services/progress_service.dart';

class DashboardScreen extends StatefulWidget {

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  String goal = "";

  String recommendation = "";

  int goalProgress = 0;

  int careerReadiness = 0;

  int learningEfficiency = 0;

  int humanProgress = 0;

  String currentRoadmapPhase = "";

  @override
  void initState() {

    super.initState();

    loadGoal();
  }

  Future<void> loadGoal() async {

    final data =
        await GoalService.getGoalData();

    goal = data["goal"] ?? "";

    generateRecommendation();

    await loadProgress();
  }

  Future<void> loadProgress() async {

    final tasks = await TaskService.getTasks();

    int completed = tasks.where((task) => task["completed"] == true).length;

    int total = tasks.length;

    final progress = ProgressService.calculateProgress(

      completed,

      total == 0 ? 1 : total,

    );

    goalProgress = progress["goal"] ?? 0;

    careerReadiness = progress["career"] ?? 0;

    learningEfficiency = progress["learning"] ?? 0;

    humanProgress = progress["human"] ?? 0;

    setState(() {});

  }

  void generateRecommendation() {

    if (goal.toLowerCase().contains("ai")) {

      recommendation =
          "Focus on Python and Machine Learning today.";
    }

    else if (goal.toLowerCase().contains("flutter")) {

      recommendation =
          "Build one UI screen today to improve faster.";
    }

    else {

      recommendation =
          "Stay consistent and complete your daily mission.";
    }
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.grey.shade900,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            size: 40,
            color: Colors.blueAccent,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          Text(

            value,

            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "AI Dashboard 📊",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              "Goal: $goal",

              style: const TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: GridView.count(

                crossAxisCount: 2,

                crossAxisSpacing: 16,

                mainAxisSpacing: 16,

                children: [

                  dashboardCard(

                    title:
                        "Goal Progress",

                    value: "$goalProgress%",


                    icon:
                        Icons.flag,
                  ),

                  dashboardCard(

                    title:
                        "Career Readiness",

                    value: "62%",

                    icon:
                        Icons.work,
                  ),

                  dashboardCard(

                    title:
                        "Learning Efficiency",

                    value: "77%",

                    icon:
                        Icons.school,
                  ),

                  dashboardCard(

                    title:
                        "Human Progress",

                    value: "74%",

                    icon:
                        Icons.trending_up,
                  ),
                ],
              ),
            ),

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color:
                    Colors.grey.shade900,

                borderRadius:
                    BorderRadius.circular(
                        16),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(

                    "AI Recommendation",

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    recommendation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}