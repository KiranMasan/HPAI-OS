import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'network_utils.dart';

class SocketService {
  WebSocketChannel? channel;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final baseUrl = NetworkUtils.websocketUrl;
    final url = token == null || token.isEmpty
        ? baseUrl
        : '$baseUrl?token=$token';

    channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void sendMessage(String message) {
    channel?.sink.add(message);
  }

  Stream get stream => channel!.stream;

  void dispose() {
    channel?.sink.close();
  }
}
