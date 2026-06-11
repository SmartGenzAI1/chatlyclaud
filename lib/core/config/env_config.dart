// ============================================================================
// FILE: lib/core/config/env_config.dart
// PURPOSE: Environment configuration with secure fallbacks
// ============================================================================

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class EnvConfig {
  static const String _unsplashApiKey = String.fromEnvironment('UNSPLASH_API_KEY', defaultValue: '');
  static const String _perspectiveApiKey = String.fromEnvironment('PERSPECTIVE_API_KEY', defaultValue: '');
  static const String _revenuecatApiKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');

  static String get unsplashApiKey => _unsplashApiKey;
  static String get perspectiveApiKey => _perspectiveApiKey;
  static String get revenuecatApiKey => _revenuecatApiKey;

  static bool get hasUnsplashKey => _unsplashApiKey.isNotEmpty;
  static bool get hasPerspectiveKey => _perspectiveApiKey.isNotEmpty;
  static bool get hasRevenueCatKey => _revenuecatApiKey.isNotEmpty;
  static bool get isFullyConfigured => hasUnsplashKey && hasPerspectiveKey && hasRevenueCatKey;

  static List<String> get missingKeys {
    final missing = <String>[];
    if (!hasUnsplashKey) missing.add('UNSPLASH_API_KEY');
    if (!hasPerspectiveKey) missing.add('PERSPECTIVE_API_KEY');
    if (!hasRevenueCatKey) missing.add('REVENUECAT_API_KEY');
    return missing;
  }

  static void logConfigStatus() {
    if (kDebugMode) {
      debugPrint('EnvConfig: Unsplash=${hasUnsplashKey ? "OK" : "MISSING"} Perspective=${hasPerspectiveKey ? "OK" : "MISSING"} RevenueCat=${hasRevenueCatKey ? "OK" : "MISSING"}');
    }
  }
}
