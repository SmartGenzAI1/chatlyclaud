// ============================================================================
// FILE: lib/core/utils/sanitizers.dart
// PURPOSE: Input sanitization for a Firestore-backed chat app
// ============================================================================

class Sanitizers {
  /// Maximum message length (prevents abuse)
  static const int maxMessageLength = 10000;

  /// Strip HTML tags and control characters from any text input
  static String sanitizeText(String input) {
    String sanitized = input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]'), '')
        .trim();
    return sanitized;
  }

  /// Sanitize and validate a chat message for storage
  static String sanitizeMessage(String message) {
    if (message.length > maxMessageLength) {
      throw Exception('Message exceeds maximum length of $maxMessageLength characters');
    }

    String sanitized = sanitizeText(message);

    if (sanitized.isEmpty) {
      throw Exception('Message cannot be empty');
    }

    if (_hasExcessiveRepetition(sanitized)) {
      throw Exception('Message contains excessive repetition');
    }

    return sanitized;
  }

  /// Sanitize a username for display and storage
  static String sanitizeUsername(String username) {
    String sanitized = username.replaceAll('@', '');
    sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    sanitized = sanitized.toLowerCase();
    if (sanitized.length > 20) {
      sanitized = sanitized.substring(0, 20);
    }
    return sanitized;
  }

  /// Check if text contains excessive repetition (spam detection)
  static bool _hasExcessiveRepetition(String text) {
    // More than 10 consecutive identical characters
    if (RegExp(r'(.)\1{9,}').hasMatch(text)) return true;

    // Same word repeated more than 10 times
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final counts = <String, int>{};
    for (final word in words.where((w) => w.length > 2)) {
      counts[word] = (counts[word] ?? 0) + 1;
      if (counts[word]! > 10) return true;
    }
    return false;
  }
}
