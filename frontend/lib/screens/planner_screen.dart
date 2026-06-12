import 'package:flutter/material.dart';

import '../services/goal_service.dart';
import '../services/task_service.dart';

class PlannerScreen extends StatefulWidget {

  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() =>
      _PlannerScreenState();
}

class _PlannerScreenState
    extends State<PlannerScreen> {

  String goal = "";

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {

    super.initState();

    loadGoal();
  }

  Future<void> loadGoal() async {

    final data =
        await GoalService.getGoalData();

    goal = data["goal"] ?? "";

    // Load tasks saved earlier (if any)
    tasks = await TaskService.getTasks();

    if (tasks.isEmpty) {

      generateTasks();

    }

    TaskService.saveTasks(tasks);

    setState(() {});
  }

  void generateTasks() {

    if (goal.toLowerCase().contains("ai")) {

      tasks = [

        {
          "title": "Learn Python Fundamentals",
          "completed": false,
        },

        {
          "title": "Complete NumPy Basics",
          "completed": false,
        },

        {
          "title": "Watch ML Introduction",
          "completed": false,
        },

        {
          "title": "Solve 5 DSA Problems",
          "completed": false,
        },
      ];
    }

    else {

      tasks = [

        {
          "title": "Complete Daily Learning",
          "completed": false,
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "AI Planner 🚀",
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

            const Text(

              "Today's AI Mission",

              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                itemCount: tasks.length,

                itemBuilder:
                    (context, index) {

                  return Card(

                    color:
                        Colors.grey.shade900,

                    child: ListTile(

                      leading: const Icon(
                        Icons.auto_awesome,
                        color: Colors.blue,
                      ),

                      title: Text(
                        tasks[index]["title"],
                      ),

                      trailing: Checkbox(
                        value: tasks[index]["completed"],
                        onChanged: (value) async {
                          setState(() {
                            tasks[index]["completed"] = value!;
                          });

                          TaskService.saveTasks(tasks);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}