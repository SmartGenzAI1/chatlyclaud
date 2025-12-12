// ============================================================================
// FILE: lib/services/notification_service.dart
// PURPOSE: Firebase Cloud Messaging notification service
// ============================================================================

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/errors/error_handler.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      
      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Get FCM token
      final token = await _messaging.getToken();
      print('FCM Token: $token');
      
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'initializeNotifications');
    }
  }
  
  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
    );
  }
  
  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chatly_channel',
      'Chatly Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }
}
