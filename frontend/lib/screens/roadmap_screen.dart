import 'package:flutter/material.dart';

import '../services/plan_storage_service.dart';
import '../services/plan_parser_service.dart';

class RoadmapScreen extends StatefulWidget {

  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() =>
      _RoadmapScreenState();
}

class _RoadmapScreenState
    extends State<RoadmapScreen> {

  String plan = "";

  List<String> roadmap = [];

  List<String> tasks = [];

  String recommendation = "";

  @override
  void initState() {

    super.initState();

    loadPlan();
  }

  Future<void> loadPlan() async {

    plan =
        await PlanStorageService
            .getPlan();

    roadmap =
        PlanParserService
            .extractRoadmap(plan);

    tasks =
        PlanParserService
            .extractTasks(plan);

    recommendation =
        PlanParserService
            .extractRecommendation(
                plan);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "AI Growth Plan 🚀",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: ListView(

          children: [

            const Text(

              "🧠 AI Roadmap",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 15),

            ...roadmap.map(

              (phase) => Card(

                color:
                    Colors.grey.shade900,

                child: ListTile(

                  leading:
                      const Icon(
                    Icons.route,
                  ),

                  title: Text(
                    phase,
                  ),

                ),

              ),

            ),

            const SizedBox(height: 25),

            const Text(

              "🚀 Today's Mission",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 15),

            ...tasks.map(

              (task) => Card(

                color:
                    Colors.grey.shade900,

                child: ListTile(

                  leading:
                      const Icon(
                    Icons.task_alt,
                  ),

                  title: Text(
                    task,
                  ),

                ),

              ),

            ),

            const SizedBox(height: 25),

            Card(

              color:
                  Colors.blueGrey.shade900,

              child: Padding(

                padding:
                    const EdgeInsets.all(
                        16),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(

                      "💡 AI Recommendation",

                      style: TextStyle(

                        fontSize: 18,

                        fontWeight:
                            FontWeight.bold,

                      ),

                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      recommendation,
                    ),

                  ],

                ),

              ),

            ),

          ],

        ),
      ),
    );
  }
}
