import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'services/app_settings.dart';

import 'theme/app_theme.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_guard.dart';

// Read low-resource preference before launching app to avoid an extra prefs read
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final lowResource = prefs.getBool('low_resource_mode') ?? false;
  runApp(HPAIApp(lowResourceMode: lowResource));
}

class HPAIApp extends StatelessWidget {
  final bool lowResourceMode;
  const HPAIApp({super.key, required this.lowResourceMode});

  @override
  Widget build(BuildContext context) {
    // When lowResourceMode is enabled, disable page transitions and tickers
    final baseTheme = AppTheme.darkTheme;
    final theme = lowResourceMode
        ? baseTheme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.android: _NoTransitionsBuilder(),
              TargetPlatform.iOS: _NoTransitionsBuilder(),
              TargetPlatform.linux: _NoTransitionsBuilder(),
              TargetPlatform.macOS: _NoTransitionsBuilder(),
              TargetPlatform.windows: _NoTransitionsBuilder(),
            }),
          )
        : baseTheme;

    return ChangeNotifierProvider(
      create: (_) => AppSettings(lowResourceMode),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HPAI-OS',
        theme: theme,
        // wrap app with a TickerMode to disable animations entirely when in low resource mode
        builder: (context, child) => TickerMode(
          enabled: !Provider.of<AppSettings>(context).lowResourceMode,
          child: child ?? const SizedBox.shrink(),
        ),
        home: AuthGuard(
          authed: HomeScreen(lowResourceMode: lowResourceMode),
          unauthenticated: LoginScreen(),
        ),
      ),
    );
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation,
      Widget child) {
    return child;
  }
}
