// ============================================================================
// FILE: lib/core/utils/sanitizers.dart
// PURPOSE: Input sanitization for security
// ============================================================================

class Sanitizers {
  /// Remove harmful characters from text
  static String sanitizeText(String input) {
    // Remove HTML-like tags
    String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove script tags
    sanitized = sanitized.replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '');
    
    // Remove potentially harmful characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}]'), '');
    
    // Trim whitespace
    sanitized = sanitized.trim();
    
    return sanitized;
  }
  
  /// Sanitize username
  static String sanitizeUsername(String username) {
    // Remove @ symbol if present
    String sanitized = username.replaceAll('@', '');
    
    // Keep only alphanumeric and underscores
    sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    
    // Convert to lowercase
    sanitized = sanitized.toLowerCase();
    
    return sanitized;
  }
  
  /// Check for banned words (placeholder for actual implementation)
  static bool containsBannedWords(String text) {
    // TODO: Implement actual banned words list from Firestore
    final bannedWords = ['spam', 'scam', 'hack'];
    
    final lowerText = text.toLowerCase();
    for (final word in bannedWords) {
      if (lowerText.contains(word)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Sanitize message for storage
  static String sanitizeMessage(String message) {
    String sanitized = sanitizeText(message);
    
    if (containsBannedWords(sanitized)) {
      throw Exception('Message contains inappropriate content');
    }
    
    return sanitized;
  }
}
