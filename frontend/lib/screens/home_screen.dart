import 'package:flutter/material.dart';
// shared_preferences intentionally not needed here; lowResourceMode is passed from main

import '../services/goal_service.dart';
import 'chat_screen.dart';
import 'dashboard_screen.dart';
import 'planner_screen.dart';
import 'roadmap_screen.dart';
import 'voice_screen.dart';
import 'profile_screen.dart';
import 'onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool lowResourceMode;

  const HomeScreen({super.key, this.lowResourceMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      checkOnboarding();
    });
  }

  bool lowResourceMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use the preloaded value passed from main to avoid an extra async prefs read at startup
    lowResourceMode = widget.lowResourceMode;
  }

  Future<void> checkOnboarding() async {
    final completed = await GoalService.isOnboardingCompleted();

    if (!completed && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    }
  }

  int currentIndex = 0;

  // Lazy-loaded screen instances to reduce startup cost on emulators
  final List<Widget?> screens = List<Widget?>.filled(6, null);

  Widget _buildScreen(int index) {
    if (screens[index] != null) return screens[index]!;

      switch (index) {
      case 0:
        screens[0] = const ChatScreen();
        break;
      case 1:
        screens[1] = const DashboardScreen();
        break;
      case 2:
        screens[2] = const RoadmapScreen();
        break;
      case 3:
        screens[3] = const PlannerScreen();
        break;
      case 4:
        // In low resource mode, show a lightweight placeholder instead of the full Voice UI
        if (lowResourceMode) {
          screens[4] = Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Voice disabled in Low Resource Mode',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentIndex = 5; // navigate to Profile
                      });
                    },
                    child: const Text('Enable in Profile'),
                  ),
                ],
              ),
            ),
          );
        } else {
          screens[4] = const VoiceScreen();
        }
        break;
      case 5:
        screens[5] = ProfileScreen(
          onLowResourceChanged: (val) {
            // Update HomeScreen state immediately when profile toggles low-resource
            setState(() {
              lowResourceMode = val;
              // reset voice screen so it will rebuild using new mode
              screens[4] = null;
            });
          },
        );
        break;
      default:
        screens[index] = const DashboardScreen();
    }

    return screens[index]!;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _buildScreen(currentIndex),

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {

          setState(() {

            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: "Roadmap",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Planner",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: "Voice",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}