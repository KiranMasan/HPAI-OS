import 'package:flutter/material.dart';

import '../services/goal_service.dart';
import '../services/ai_plan_service.dart';
import '../services/plan_storage_service.dart';

class OnboardingScreen extends StatefulWidget {

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {

  final goalController =
      TextEditingController();

  String level = "Beginner";

  String hours = "2 Hours";

  String target = "6 Months";

  bool isSubmitting = false;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Setup Your AI Journey 🚀",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              controller: goalController,

              decoration:
                  const InputDecoration(

                labelText:
                    "What do you want to become?",
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(

              initialValue: level,

              items: const [

                DropdownMenuItem(
                  value: "Beginner",
                  child: Text("Beginner"),
                ),

                DropdownMenuItem(
                  value: "Intermediate",
                  child: Text("Intermediate"),
                ),

                DropdownMenuItem(
                  value: "Advanced",
                  child: Text("Advanced"),
                ),
              ],

              onChanged: (value) {

                setState(() {

                  level = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(

              initialValue: hours,

              items: const [

                DropdownMenuItem(
                  value: "1 Hour",
                  child: Text("1 Hour"),
                ),

                DropdownMenuItem(
                  value: "2 Hours",
                  child: Text("2 Hours"),
                ),

                DropdownMenuItem(
                  value: "4 Hours",
                  child: Text("4 Hours"),
                ),
              ],

              onChanged: (value) {

                setState(() {

                  hours = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(

              initialValue: target,

              items: const [

                DropdownMenuItem(
                  value: "3 Months",
                  child: Text("3 Months"),
                ),

                DropdownMenuItem(
                  value: "6 Months",
                  child: Text("6 Months"),
                ),

                DropdownMenuItem(
                  value: "1 Year",
                  child: Text("1 Year"),
                ),
              ],

              onChanged: (value) {

                setState(() {

                  target = value!;
                });
              },
            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),

                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (goalController.text.trim().isEmpty) {
                          _showMessage(
                              'Please enter your AI career goal.');
                          return;
                        }

                        final navigator = Navigator.of(context);

                        setState(() {
                          isSubmitting = true;
                        });

                        await GoalService.saveGoal(
                          goal: goalController.text.trim(),
                          level: level,
                          hours: hours,
                          target: target,
                        );

                        final plan = await AIPlanService.generatePlan(
                          goal: goalController.text.trim(),
                          level: level,
                          hours: hours,
                          target: target,
                        );

                        await PlanStorageService.savePlan(plan);
                        await GoalService.setOnboardingCompleted();

                        if (!mounted) return;
                        navigator.pop();
                      },

                child: isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Generate My AI Plan",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}