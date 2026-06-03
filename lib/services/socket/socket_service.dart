import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

typedef SessionStartedCallback = void Function({
  required String sessionId,
  required String moduleId,
  required String moduleName,
  required String group,
  required String startTime,
});

typedef SessionEndedCallback = void Function(String sessionId);
typedef FraudAlertCallback = void Function({
  required String sessionId,
  required String reason,
  required double riskScore,
});

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _connecting = false;
  Timer? _reconnectTimer;

  SessionStartedCallback? onSessionStarted;
  SessionEndedCallback? onSessionEnded;
  FraudAlertCallback? onFraudAlert;

  Future<void> connect() async {
    if (_connecting || _isConnected) return;

    _connecting = true;

    final token = await ApiService().token ?? '';
    final wsUrl = AppConstants.baseUrl.replaceFirst('http', 'ws');
    final uri = Uri.parse('$wsUrl?token=$token');

    try {
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;
      _connecting = false;

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final msg = jsonDecode(data as String) as Map<String, dynamic>;
            _handleEvent(msg['event'] as String?, msg['data']);
          } catch (_) {}
        },
        onDone: () {
          _isConnected = false;
          _connecting = false;
          _scheduleReconnect();
        },
        onError: (_) {
          _isConnected = false;
          _connecting = false;
          _scheduleReconnect();
        },
      );
    } catch (_) {
      _isConnected = false;
      _connecting = false;
      _scheduleReconnect();
    }
  }

  void _handleEvent(String? event, dynamic data) {
    if (event == null || data is! Map) return;

    switch (event) {
      case 'session:started':
        onSessionStarted?.call(
          sessionId: data['sessionId'] ?? '',
          moduleId: data['moduleId'] ?? '',
          moduleName: data['moduleName'] ?? '',
          group: data['group'] ?? '',
          startTime: data['startTime'] ?? '',
        );
        break;
      case 'session:ended':
        onSessionEnded?.call(data['sessionId'] ?? '');
        break;
      case 'attendance:fraud-alert':
        debugPrint('[WS] Fraud alert for session ${data['sessionId']}: ${data['reason']}');
        onFraudAlert?.call(
          sessionId: data['sessionId'] ?? '',
          reason: data['reason'] ?? '',
          riskScore: (data['riskScore'] ?? 0).toDouble(),
        );
        break;
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _connecting = false;
      connect();
    });
  }

  void joinGroup(String group) {
    _send('join:group', group);
  }

  void leaveGroup(String group) {
    _send('leave:group', group);
  }

  void _send(String event, dynamic data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({'event': event, 'data': data}));
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connecting = false;
  }
}
