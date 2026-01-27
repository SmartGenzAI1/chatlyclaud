// ============================================================================
// FILE: lib/services/rate_limiter.dart
// PURPOSE: Rate limiting service to prevent abuse and brute force attacks
// ============================================================================

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  final Map<String, List<DateTime>> _attempts = {};
  final Map<String, DateTime> _blockedUntil = {};

  factory RateLimiter() => _instance;

  RateLimiter._internal();

  /// Rate limiting configuration
  static const int maxAttempts = 5;
  static const int blockDurationMinutes = 15;
  static const int timeWindowMinutes = 15;

  /// Check if an action is allowed for a given key (IP, user ID, etc.)
  bool isAllowed(String key) {
    final now = DateTime.now();
    final blockUntil = _blockedUntil[key];
    
    // Check if still blocked
    if (blockUntil != null && now.isBefore(blockUntil)) {
      return false;
    }
    
    // Clean old attempts
    _cleanOldAttempts(key, now);
    
    // Get current attempts
    final attempts = _attempts[key] ?? [];
    
    // Check if within limit
    if (attempts.length < maxAttempts) {
      attempts.add(now);
      _attempts[key] = attempts;
      return true;
    }
    
    // Block the key
    final blockUntilTime = now.add(Duration(minutes: blockDurationMinutes));
    _blockedUntil[key] = blockUntilTime;
    _attempts[key] = []; // Reset attempts
    
    return false;
  }

  /// Record a failed attempt
  void recordAttempt(String key) {
    final now = DateTime.now();
    final attempts = _attempts[key] ?? [];
    attempts.add(now);
    _attempts[key] = attempts;
  }

  /// Reset attempts for a key (after successful action)
  void resetAttempts(String key) {
    _attempts.remove(key);
    _blockedUntil.remove(key);
  }

  /// Get remaining time until unblock (in minutes)
  int getRemainingBlockTime(String key) {
    final blockUntil = _blockedUntil[key];
    if (blockUntil == null) return 0;
    
    final now = DateTime.now();
    if (now.isAfter(blockUntil)) return 0;
    
    final difference = blockUntil.difference(now);
    return difference.inMinutes + (difference.inSeconds % 60 > 0 ? 1 : 0);
  }

  /// Clean old attempts outside the time window
  void _cleanOldAttempts(String key, DateTime now) {
    final attempts = _attempts[key];
    if (attempts == null) return;
    
    final cutoff = now.subtract(Duration(minutes: timeWindowMinutes));
    _attempts[key] = attempts.where((attempt) => attempt.isAfter(cutoff)).toList();
  }

  /// Check if user is rate limited for login attempts
  bool isLoginAllowed(String identifier) {
    return isAllowed('login_$identifier');
  }

  /// Record failed login attempt
  void recordLoginAttempt(String identifier) {
    recordAttempt('login_$identifier');
  }

  /// Reset login attempts after successful login
  void resetLoginAttempts(String identifier) {
    resetAttempts('login_$identifier');
  }

  /// Check if user is rate limited for signup attempts
  bool isSignupAllowed(String ipAddress) {
    return isAllowed('signup_$ipAddress');
  }

  /// Record failed signup attempt
  void recordSignupAttempt(String ipAddress) {
    recordAttempt('signup_$ipAddress');
  }

  /// Check if user is rate limited for password reset
  bool isPasswordResetAllowed(String email) {
    return isAllowed('pwd_reset_$email');
  }

  /// Record password reset attempt
  void recordPasswordResetAttempt(String email) {
    recordAttempt('pwd_reset_$email');
  }

  /// Check if user is rate limited for message sending
  bool isMessageAllowed(String userId) {
    return isAllowed('message_$userId');
  }

  /// Record message sending attempt
  void recordMessageAttempt(String userId) {
    recordAttempt('message_$userId');
  }

  /// Check if user is rate limited for chat creation
  bool isChatCreationAllowed(String userId) {
    return isAllowed('chat_create_$userId');
  }

  /// Record chat creation attempt
  void recordChatCreationAttempt(String userId) {
    recordAttempt('chat_create_$userId');
  }

  /// Get all blocked keys for monitoring
  Map<String, DateTime> getBlockedKeys() {
    return Map.from(_blockedUntil);
  }

  /// Get attempt counts for monitoring
  Map<String, int> getAttemptCounts() {
    return _attempts.map((key, attempts) => MapEntry(key, attempts.length));
  }

  /// Clear all rate limiting data (for testing or admin use)
  void clearAll() {
    _attempts.clear();
    _blockedUntil.clear();
  }

  /// Get status for a specific key
  Map<String, dynamic> getStatus(String key) {
    final blockUntil = _blockedUntil[key];
    final attempts = _attempts[key] ?? [];
    final now = DateTime.now();
    
    return {
      'isBlocked': blockUntil != null && now.isBefore(blockUntil),
      'remainingBlockTime': blockUntil != null && now.isBefore(blockUntil) 
          ? blockUntil.difference(now).inMinutes 
          : 0,
      'currentAttempts': attempts.length,
      'maxAttempts': maxAttempts,
      'blockedUntil': blockUntil?.toIso8601String(),
    };
  }
}

/// Middleware for rate limiting in services
class RateLimitingMiddleware {
  final RateLimiter _rateLimiter = RateLimiter();

  /// Wrap authentication operations with rate limiting
  Future<T> withAuthRateLimit<T>(
    String identifier,
    Future<T> Function() operation,
    {String? operationType = 'login'}
  ) async {
    final key = '$operationType\_$identifier';
    
    if (!_rateLimiter.isAllowed(key)) {
      final remainingTime = _rateLimiter.getRemainingBlockTime(key);
      throw Exception(
        'Too many attempts. Please try again in $remainingTime minutes.'
      );
    }

    try {
      final result = await operation();
      _rateLimiter.resetAttempts(key);
      return result;
    } catch (e) {
      _rateLimiter.recordAttempt(key);
      rethrow;
    }
  }

  /// Wrap message operations with rate limiting
  Future<T> withMessageRateLimit<T>(
    String userId,
    Future<T> Function() operation
  ) async {
    if (!_rateLimiter.isMessageAllowed(userId)) {
      throw Exception('Message rate limit exceeded. Please wait before sending more messages.');
    }

    try {
      final result = await operation();
      return result;
    } catch (e) {
      _rateLimiter.recordMessageAttempt(userId);
      rethrow;
    }
  }

  /// Wrap chat operations with rate limiting
  Future<T> withChatRateLimit<T>(
    String userId,
    Future<T> Function() operation
  ) async {
    if (!_rateLimiter.isChatCreationAllowed(userId)) {
      throw Exception('Chat creation rate limit exceeded.');
    }

    try {
      final result = await operation();
      return result;
    } catch (e) {
      _rateLimiter.recordChatCreationAttempt(userId);
      rethrow;
    }
  }
}