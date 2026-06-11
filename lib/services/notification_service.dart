// ============================================================================
// FILE: lib/services/notification_service.dart
// PURPOSE: Push notifications via Firebase Cloud Messaging
// ============================================================================

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/errors/error_handler.dart';
import '../main.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize notifications and request permissions
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('NotificationService: permission granted');
      }

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      debugPrint('NotificationService: FCM token = $_fcmToken');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('NotificationService: FCM token refreshed');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app was terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'NotificationService.initialize');
    }
  }

  /// Save FCM token to Firestore for a user
  Future<void> saveTokenToFirestore(String userId) async {
    if (_fcmToken == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService: failed to save FCM token: $e');
    }
  }

  /// Subscribe to a chat topic for push notifications
  Future<void> subscribeToChat(String chatId) async {
    try {
      await _messaging.subscribeToTopic('chat_$chatId');
    } catch (e) {
      debugPrint('NotificationService: failed to subscribe: $e');
    }
  }

  /// Unsubscribe from a chat topic
  Future<void> unsubscribeFromChat(String chatId) async {
    try {
      await _messaging.unsubscribeFromTopic('chat_$chatId');
    } catch (e) {
      debugPrint('NotificationService: failed to unsubscribe: $e');
    }
  }

  /// Handle foreground notification
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('NotificationService: foreground message: ${message.notification?.title}');
    // Show in-app notification banner
    _showInAppBanner(message);
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final chatId = message.data['chatId'];
    if (chatId != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/chat', arguments: {
        'chatId': chatId,
        'otherUserId': message.data['otherUserId'] ?? '',
        'otherUsername': message.data['otherUsername'] ?? 'Unknown',
      });
    }
  }

  /// Show in-app notification banner
  void _showInAppBanner(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? 'New message';
    final body = message.notification?.body ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (body.isNotEmpty) Text(body, style: const TextStyle(fontSize: 12)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            final chatId = message.data['chatId'];
            if (chatId != null) {
              Navigator.of(context).pushNamed('/chat', arguments: {
                'chatId': chatId,
                'otherUserId': message.data['otherUserId'] ?? '',
                'otherUsername': message.data['otherUsername'] ?? 'Unknown',
              });
            }
          },
        ),
      ),
    );
  }
}
