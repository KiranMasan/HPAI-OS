import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../services/app_settings.dart';

import '../services/auth_service.dart';
import '../services/digital_twin_service.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<bool>? onLowResourceChanged;

  const ProfileScreen({super.key, this.onLowResourceChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  Map<String, dynamic> twin = {};
  bool isLoading = true;
  bool isProcessing = false;
  String username = "";
  bool lowResourceMode = false;

  @override
  void initState() {

    super.initState();

    loadTwin();
  }

  Future<void> loadTwin() async {
    final profile = await DigitalTwinService.getTwinProfile();
    final cachedUsername = await AuthService.getUsername();
    final prefs = await SharedPreferences.getInstance();
    lowResourceMode = prefs.getBool('low_resource_mode') ?? false;

    twin = profile;
    username = cachedUsername ?? "";
    isLoading = false;

    if (!mounted) return;
    setState(() {});
  }

  Future<bool> _confirmAction(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget infoTile(
    String title,
    String value,
  ) {

    return Card(

      color: Colors.grey.shade900,

      child: ListTile(

        title: Text(title),

        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Digital Twin 🧠",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  Text(
                    'Digital Twin',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    username.isNotEmpty
                        ? 'Welcome back, $username'
                        : 'Welcome back',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 45,
                    child: Icon(
                      Icons.psychology,
                      size: 40,
                    ),
                  ),

            const SizedBox(height: 20),

            SwitchListTile.adaptive(
              title: const Text('Low Resource Mode'),
              subtitle: const Text(
                'Reduce animations and disable heavy features for faster emulators',
              ),
              value: lowResourceMode,
              onChanged: (val) async {
                final messenger = ScaffoldMessenger.of(context);
                // capture provider instance synchronously to avoid using context after await
                AppSettings? settings;
                try {
                  settings = Provider.of<AppSettings>(context, listen: false);
                } catch (_) {
                  settings = null;
                }

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('low_resource_mode', val);

                // update global provider if available
                if (settings != null) {
                  await settings.setLowResource(val);
                }

                if (!mounted) return;
                setState(() {
                  lowResourceMode = val;
                });

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        val ? 'Low Resource Mode enabled' : 'Low Resource Mode disabled'),
                  ),
                );

                // Notify ancestor screens (HomeScreen) so they can update UI immediately
                widget.onLowResourceChanged?.call(val);
              },
            ),

            infoTile(
              "Career Goal",
              twin["goal"] ?? "",
            ),

            infoTile(
              "Skill Level",
              twin["level"] ?? "",
            ),

            infoTile(
              "Daily Capacity",
              twin["hours"] ?? "",
            ),

            infoTile(
              "Target Timeline",
              twin["target"] ?? "",
            ),

            infoTile(
              "Progress",
              "${twin["progress"] ?? 0}%",
            ),

            infoTile(
              "AI Status",
              twin["status"] ?? "",
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                "Create New Journey",
              ),
              onPressed: isProcessing
                  ? null
                  : () async {
                      final currentContext = context;
                      final navigator = Navigator.of(currentContext);
                      final confirmed = await _confirmAction(
                        currentContext,
                        "Create New Journey",
                        "This will reset your current journey and start onboarding again.",
                      );
                      if (!confirmed) return;

                      setState(() {
                        isProcessing = true;
                      });

                      final prefs = await SharedPreferences.getInstance();

                      await prefs.remove("onboarding_completed");
                      await prefs.remove("goal");
                      await prefs.remove("level");
                      await prefs.remove("hours");
                      await prefs.remove("target");
                      await prefs.remove("ai_plan");

                      if (!mounted) return;
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingScreen(),
                        ),
                      );
                    },
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.redAccent,
              ),
              icon: const Icon(
                Icons.logout,
              ),
              label: const Text(
                "Logout",
              ),
              onPressed: isProcessing
                  ? null
                  : () async {
                      final currentContext = context;
                      final navigator = Navigator.of(currentContext);
                      final confirmed = await _confirmAction(
                        currentContext,
                        "Logout",
                        "You will be signed out and returned to the login screen.",
                      );
                      if (!confirmed) return;

                      setState(() {
                        isProcessing = true;
                      });

                      await AuthService.logout();

                      if (!mounted) return;
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}