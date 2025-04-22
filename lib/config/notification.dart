import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Notification');

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  _logger.info('---------------Background message received---------------');
  _logger.info('Title:', message.notification?.title);
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<Map<String, dynamic>>.broadcast();
  final streamBackground = StreamController<Map<String, dynamic>>.broadcast();
  final streamTerminated = StreamController<Map<String, dynamic>>.broadcast();

  setNotifications() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _firebaseMessaging.getToken();
    _logger.info('FCM Settings', '${settings} ${token}');

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      if (initialMessage.data['type'] == '1') {
        streamTerminated.sink.add(initialMessage.data);
      }
    }

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      streamCtlr.sink.add(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == '1') {
        streamBackground.sink.add(message.data);
      }
    });
  }

  dispose() {
    streamCtlr.close();
  }
}
