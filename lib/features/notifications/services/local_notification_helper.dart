import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (kIsWeb || _isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(settings);
      _isInitialized = true;
    } catch (_) {}
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'cosmyra_broadcast_channel',
        'Cosmyra Announcements',
        channelDescription: 'Live broadcast announcements and offer notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        color: Color(0xFF4F46E5),
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
      );
    } catch (_) {}
  }
}
