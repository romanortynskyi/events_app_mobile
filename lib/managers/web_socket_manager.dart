import 'dart:async';
import 'dart:convert';

import 'package:events_app_mobile/consts/enums/web_socket_message_type.dart';
import 'package:events_app_mobile/models/upload_user_image_progress.dart';
import 'package:events_app_mobile/models/web_socket_message.dart';
import 'package:events_app_mobile/utils/env_utils.dart';
import 'package:events_app_mobile/utils/secure_storage_utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  final String url;
  final Map<String, String>? headers;

  WebSocketChannel? channel;
  StreamSubscription? subscription;

  Function(WebSocketMessage) onMessage;

  static WebSocketManager? _instance;

  Future<void> reconnect() async {
    String? token = await SecureStorageUtils.getItem('token');
    String bearerToken = '';

    if (token != null) {
      bearerToken = 'Bearer $token';
    }

    _instance = WebSocketManager._privateConstructor(
      url: EnvUtils.getEnv('WS_URL'),
      headers: {
        'Authorization': bearerToken,
      },
      onMessage: onMessage,
    );
  }

  static Future<WebSocketManager?> getInstance({
    required Function(WebSocketMessage) onMessage,
  }) async {
    String? token = await SecureStorageUtils.getItem('token');
    String bearerToken = '';

    if (token != null) {
      bearerToken = 'Bearer $token';
    }

    _instance ??= WebSocketManager._privateConstructor(
      url: EnvUtils.getEnv('WS_URL'),
      headers: {
        'Authorization': bearerToken,
      },
      onMessage: onMessage,
    );

    return _instance;
  }

  WebSocketManager._privateConstructor({
    required this.url,
    required this.onMessage,
    this.headers = const {},
  }) {
    channel = WebSocketChannel.connect(
        Uri.parse('$url?authorization=${headers?['Authorization']}'));

    subscription = channel!.stream.listen(
      (message) {
        Map<String, dynamic> map = jsonDecode(message);
        String typeStr = map['type'];

        WebSocketMessageType type =
            WebSocketMessageType.values.firstWhere((e) => e.value == typeStr);

        switch (type) {
          case WebSocketMessageType.uploadUserImageProgress:
            onMessage(WebSocketMessage<UploadUserImageProgress>.fromMap(
                map, UploadUserImageProgress()));

            break;
        }
      },
    );
  }

  void dispose() {
    subscription?.cancel();
    channel?.sink.close();
  }
}
