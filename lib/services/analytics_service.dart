// ============================================================================
// FILE: lib/services/analytics_service.dart
// PURPOSE: User behavior analytics and event tracking
// ============================================================================

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  
  // Event names
  static const String EVENT_APP_OPEN = 'app_open';
  static const String EVENT_SCREEN_VIEW = 'screen_view';
  static const String EVENT_SIGN_UP = 'sign_up';
  static const String EVENT_SIGN_IN = 'sign_in';
  static const String EVENT_SIGN_OUT = 'sign_out';
  static const String EVENT_MESSAGE_SENT = 'message_sent';
  static const String EVENT_MESSAGE_READ = 'message_read';
  static const String EVENT_CHAT_OPENED = 'chat_opened';
  static const String EVENT_ANONYMOUS_MESSAGE_SENT = 'anonymous_message_sent';
  static const String EVENT_GROUP_CREATED = 'group_created';
  static const String EVENT_GROUP_JOINED = 'group_joined';
  static const String EVENT_THEME_CHANGED = 'theme_changed';
  static const String EVENT_SUBSCRIPTION_PURCHASED = 'subscription_purchased';
  static const String EVENT_FEATURE_USED = 'feature_used';
  static const String EVENT_ERROR_OCCURRED = 'error_occurred';
  static const String EVENT_APP_CRASHED = 'app_crashed';

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  /// Get the Firebase Analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => _observer;

  /// Log app open event
  Future<void> logAppOpen() async {
    await _analytics.logEvent(
      name: EVENT_APP_OPEN,
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log screen view event
  Future<void> logScreenView(String screenName, String screenClass) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Log user sign up event
  Future<void> logSignUp(String method, String userId) async {
    await _analytics.logEvent(
      name: EVENT_SIGN_UP,
      parameters: {
        'sign_up_method': method,
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Set user properties
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'sign_up_method', value: method);
  }

  /// Log user sign in event
  Future<void> logSignIn(String method, String userId) async {
    await _analytics.logEvent(
      name: EVENT_SIGN_IN,
      parameters: {
        'sign_in_method': method,
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log user sign out event
  Future<void> logSignOut(String userId) async {
    await _analytics.logEvent(
      name: EVENT_SIGN_OUT,
      parameters: {
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log message sent event
  Future<void> logMessageSent({
    required String chatId,
    required String userId,
    required String messageType,
    required int messageLength,
    required bool isEncrypted,
  }) async {
    await _analytics.logEvent(
      name: EVENT_MESSAGE_SENT,
      parameters: {
        'chat_id': chatId,
        'user_id': userId,
        'message_type': messageType,
        'message_length': messageLength,
        'is_encrypted': isEncrypted,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Log revenue for premium features (if applicable)
    if (messageType == 'premium_feature') {
      await _analytics.logEvent(
        name: 'purchase',
        parameters: {
          'item_id': 'premium_message_feature',
          'item_name': 'Premium Message Feature',
          'currency': 'INR',
          'value': 0.10, // Example value
        },
      );
    }
  }

  /// Log message read event
  Future<void> logMessageRead({
    required String chatId,
    required String userId,
    required String messageId,
  }) async {
    await _analytics.logEvent(
      name: EVENT_MESSAGE_READ,
      parameters: {
        'chat_id': chatId,
        'user_id': userId,
        'message_id': messageId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log chat opened event
  Future<void> logChatOpened({
    required String chatId,
    required String userId,
    required String chatType,
    required int participantsCount,
  }) async {
    await _analytics.logEvent(
      name: EVENT_CHAT_OPENED,
      parameters: {
        'chat_id': chatId,
        'user_id': userId,
        'chat_type': chatType,
        'participants_count': participantsCount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log anonymous message sent event
  Future<void> logAnonymousMessageSent({
    required String userId,
    required String topic,
    required int messageLength,
    required String tier,
  }) async {
    await _analytics.logEvent(
      name: EVENT_ANONYMOUS_MESSAGE_SENT,
      parameters: {
        'user_id': userId,
        'topic': topic,
        'message_length': messageLength,
        'user_tier': tier,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log group created event
  Future<void> logGroupCreated({
    required String groupId,
    required String userId,
    required String groupName,
    required int initialMembers,
  }) async {
    await _analytics.logEvent(
      name: EVENT_GROUP_CREATED,
      parameters: {
        'group_id': groupId,
        'user_id': userId,
        'group_name': groupName,
        'initial_members': initialMembers,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log group joined event
  Future<void> logGroupJoined({
    required String groupId,
    required String userId,
    required int totalMembers,
  }) async {
    await _analytics.logEvent(
      name: EVENT_GROUP_JOINED,
      parameters: {
        'group_id': groupId,
        'user_id': userId,
        'total_members': totalMembers,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log theme changed event
  Future<void> logThemeChanged({
    required String userId,
    required String oldTheme,
    required String newTheme,
  }) async {
    await _analytics.logEvent(
      name: EVENT_THEME_CHANGED,
      parameters: {
        'user_id': userId,
        'old_theme': oldTheme,
        'new_theme': newTheme,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Set user property for theme preference
    await _analytics.setUserProperty(name: 'preferred_theme', value: newTheme);
  }

  /// Log subscription purchased event
  Future<void> logSubscriptionPurchased({
    required String userId,
    required String subscriptionType,
    required double price,
    required String currency,
  }) async {
    await _analytics.logEvent(
      name: EVENT_SUBSCRIPTION_PURCHASED,
      parameters: {
        'user_id': userId,
        'subscription_type': subscriptionType,
        'price': price,
        'currency': currency,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Log purchase event for revenue tracking
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: subscriptionType,
          itemName: '${subscriptionType}_subscription',
          price: price,
        ),
      ],
    );

    // Set user property for subscription status
    await _analytics.setUserProperty(name: 'subscription_tier', value: subscriptionType);
  }

  /// Log feature used event
  Future<void> logFeatureUsed({
    required String userId,
    required String featureName,
    required String featureType,
  }) async {
    await _analytics.logEvent(
      name: EVENT_FEATURE_USED,
      parameters: {
        'user_id': userId,
        'feature_name': featureName,
        'feature_type': featureType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log error occurred event
  Future<void> logErrorOccurred({
    required String userId,
    required String errorType,
    required String errorMessage,
    required String context,
  }) async {
    await _analytics.logEvent(
      name: EVENT_ERROR_OCCURRED,
      parameters: {
        'user_id': userId,
        'error_type': errorType,
        'error_message': errorMessage,
        'context': context,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log app crashed event
  Future<void> logAppCrashed({
    required String userId,
    required String crashReason,
  }) async {
    await _analytics.logEvent(
      name: EVENT_APP_CRASHED,
      parameters: {
        'user_id': userId,
        'crash_reason': crashReason,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    required String email,
    required String tier,
    required DateTime createdAt,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'email', value: email);
    await _analytics.setUserProperty(name: 'tier', value: tier);
    await _analytics.setUserProperty(name: 'created_at', value: createdAt.toIso8601String());
  }

  /// Log custom event with parameters
  Future<void> logCustomEvent(String eventName, Map<String, Object> parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  /// Get analytics instance for direct access
  FirebaseAnalytics get analytics => _analytics;

  /// Enable or disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  /// Reset analytics data
  Future<void> resetAnalyticsData() async {
    await _analytics.resetAnalyticsData();
  }

  /// Set current screen (for manual screen tracking)
  Future<void> setCurrentScreen(String screenName, String screenClass) async {
    await _analytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClass,
    );
  }
}

/// Extension for easy access to analytics methods in widgets
extension AnalyticsContext on BuildContext {
  AnalyticsService get analytics => AnalyticsService();
}