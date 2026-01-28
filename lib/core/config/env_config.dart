// ============================================================================
// FILE: lib/core/config/env_config.dart
// PURPOSE: Environment configuration and API key management with secure fallbacks
// ============================================================================

import 'package:flutter/foundation.dart';

/// Environment configuration class for managing API keys and secrets
/// Provides safe fallbacks when environment variables are not configured
class EnvConfig {
  // API Keys - replace with actual values or use environment variables
  static const String _unsplashApiKey = String.fromEnvironment(
    'UNSPLASH_API_KEY',
    defaultValue: '',
  );
  
  static const String _perspectiveApiKey = String.fromEnvironment(
    'PERSPECTIVE_API_KEY',
    defaultValue: '',
  );
  
  static const String _revenuecatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '',
  );

  /// Get Unsplash API key
  static String get unsplashApiKey => _unsplashApiKey;
  
  /// Get Perspective API key (for toxicity detection)
  static String get perspectiveApiKey => _perspectiveApiKey;
  
  /// Get RevenueCat API key (for subscriptions)
  static String get revenuecatApiKey => _revenuecatApiKey;
  
  /// Check if Unsplash API is configured
  static bool get hasUnsplashKey => _unsplashApiKey.isNotEmpty;
  
  /// Check if Perspective API is configured
  static bool get hasPerspectiveKey => _perspectiveApiKey.isNotEmpty;
  
  /// Check if RevenueCat is configured
  static bool get hasRevenueCatKey => _revenuecatApiKey.isNotEmpty;
  
  /// Validate all required API keys
  static bool get isFullyConfigured => 
      hasUnsplashKey && hasPerspectiveKey && hasRevenueCatKey;
  
  /// Get missing API keys list
  static List<String> get missingKeys {
    final missing = <String>[];
    if (!hasUnsplashKey) missing.add('UNSPLASH_API_KEY');
    if (!hasPerspectiveKey) missing.add('PERSPECTIVE_API_KEY');
    if (!hasRevenueCatKey) missing.add('REVENUECAT_API_KEY');
    return missing;
  }
  
  /// Log configuration status (for debugging)
  static void logConfigStatus() {
    if (kDebugMode) {
      print('=== Environment Configuration ===');
      print('Unsplash API: ${hasUnsplashKey ? "✓ Configured" : "✗ Missing"}');
      print('Perspective API: ${hasPerspectiveKey ? "✓ Configured" : "✗ Missing"}');
      print('RevenueCat API: ${hasRevenueCatKey ? "✓ Configured" : "✗ Missing"}');
      
      if (!isFullyConfigured) {
        print('\n⚠️  Warning: Missing API keys: ${missingKeys.join(", ")}');
        print('Some features may be disabled.');
      }
      print('================================');
    }
  }
}
