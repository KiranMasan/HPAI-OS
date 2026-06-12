import 'package:flutter/foundation.dart';

class NetworkUtils {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static String get websocketUrl {
    if (kIsWeb) return 'ws://127.0.0.1:8000/ws/chat';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ws://10.0.2.2:8000/ws/chat';
      default:
        return 'ws://127.0.0.1:8000/ws/chat';
    }
  }
}
