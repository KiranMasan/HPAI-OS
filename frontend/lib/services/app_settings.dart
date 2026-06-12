import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  bool _lowResourceMode;

  AppSettings(this._lowResourceMode);

  bool get lowResourceMode => _lowResourceMode;

  Future<void> setLowResource(bool val) async {
    if (_lowResourceMode == val) return;
    _lowResourceMode = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('low_resource_mode', val);
    notifyListeners();
  }
}
