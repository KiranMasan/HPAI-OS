import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthGuard extends StatefulWidget {
  final Widget authed;
  final Widget unauthenticated;

  const AuthGuard({
    super.key,
    required this.authed,
    required this.unauthenticated,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _checking = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          _authed = false;
          _checking = false;
        });
        return;
      }

      // Verify token is still valid
      final isValid = await ApiService.verifyToken();

      setState(() {
        _authed = isValid;
        _checking = false;
      });

      if (!isValid) {
        // Clear invalid token
        await prefs.remove('token');
        await prefs.remove('username');
      }
    } catch (e) {
      setState(() {
        _authed = false;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _authed ? widget.authed : widget.unauthenticated;
  }
}


