import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter/foundation.dart';

import '../../services/api_service.dart';

typedef SessionStartedCallback = void Function({
  required String sessionId,
  required String moduleId,
  required String moduleName,
  required String group,
  required String startTime,
});

typedef SessionEndedCallback = void Function(String sessionId);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  Socket? _socket;
  bool _isConnected = false;
  bool _connecting = false;

  SessionStartedCallback? onSessionStarted;
  SessionEndedCallback? onSessionEnded;

  Future<void> connect() async {
    if (_connecting || _isConnected) return;

    _connecting = true;

    final token = await ApiService().token ?? '';
    final uri = 'http://localhost:3000?token=$token';

    _socket = io(
        uri,
        OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build());

    _socket!.onConnect((_) {
      _isConnected = true;
      _connecting = false;
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connecting = false;
    });

    _socket!.onConnectError((data) {
      _connecting = false;
    });

    _socket!.on('session:started', (data) {
      if (onSessionStarted != null && data is Map) {
        onSessionStarted!(
          sessionId: data['sessionId'] ?? '',
          moduleId: data['moduleId'] ?? '',
          moduleName: data['moduleName'] ?? '',
          group: data['group'] ?? '',
          startTime: data['startTime'] ?? '',
        );
      }
    });

    _socket!.on('session:ended', (data) {
      if (onSessionEnded != null && data is Map) {
        onSessionEnded!(data['sessionId'] ?? '');
      }
    });

    _socket!.on('attendance:fraud-alert', (data) {
      if (data is Map) {
        debugPrint(
            '[SocketIO] Fraud alert for session ${data['sessionId']}: ${data['reason']}');
      }
    });
  }

  void joinGroup(String group) {
    _socket?.emit('join:group', group);
  }

  void leaveGroup(String group) {
    _socket?.emit('leave:group', group);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    _connecting = false;
  }
}
