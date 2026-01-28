// ============================================================================
// FILE: lib/core/utils/error_handler_utils.dart
// PURPOSE: Centralized error handling utilities for production safety
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized error handling utilities
class ErrorHandlerUtils {
  /// Execute a function with try-catch and automatic error reporting
  static Future<T?> tryCatch<T>({
    required Future<T> Function() function,
    required String context,
    T? defaultValue,
    bool reportToCrashlytics = true,
  }) async {
    try {
      return await function();
    } catch (e, stackTrace) {
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('❌ Error in $context: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      // Report to Crashlytics in production
      if (reportToCrashlytics && !kDebugMode) {
        await FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'Error in $context',
          fatal: false,
        );
      }
      
      return defaultValue;
    }
  }

  /// Execute a synchronous function with try-catch
  static T? tryCatchSync<T>({
    required T Function() function,
    required String context,
    T? defaultValue,
    bool reportToCrashlytics = true,
  }) {
    try {
      return function();
    } catch (e, stackTrace) {
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('❌ Error in $context: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      // Report to Crashlytics in production
      if (reportToCrashlytics && !kDebugMode) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'Error in $context',
          fatal: false,
        );
      }
      
      return defaultValue;
    }
  }

  /// Log non-fatal error to Crashlytics
  static Future<void> logNonFatalError({
    required dynamic error,
    required StackTrace stackTrace,
    String? reason,
    Map<String, dynamic>? customData,
  }) async {
    if (kDebugMode) {
      debugPrint('⚠️  Non-fatal error: $error');
      if (reason != null) debugPrint('Reason: $reason');
      if (customData != null) debugPrint('Custom data: $customData');
    }
    
    if (!kDebugMode) {
      if (customData != null) {
        customData.forEach((key, value) {
          FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
        });
      }
      
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: false,
      );
    }
  }

  /// Log message to Crashlytics for debugging
  static void log(String message, {String? context}) {
    final formattedMessage = context != null 
        ? '[$context] $message' 
        : message;
    
    if (kDebugMode) {
      debugPrint('ℹ️  $formattedMessage');
    }
    
    FirebaseCrashlytics.instance.log(formattedMessage);
  }

  /// Set user identifier for crash reports
  static Future<void> setUserIdentifier(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Set custom key-value pairs for crash reports
  static void setCustomKey(String key, dynamic value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
  }
}
