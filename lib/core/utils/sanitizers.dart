// ============================================================================
// FILE: lib/core/utils/sanitizers.dart
// PURPOSE: Input sanitization for security
// ============================================================================

class Sanitizers {
  /// Remove harmful characters from text (Enhanced security)
  static String sanitizeText(String input) {
    // Remove HTML-like tags and attributes
    String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove script tags (case insensitive)
    sanitized = sanitized.replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '');
    
    // Remove event handlers (onclick, onload, etc.)
    sanitized = sanitized.replaceAll(RegExp(r'\s+on\w+\s*=', caseSensitive: false), '');
    
    // Remove data URLs that could contain scripts
    sanitized = sanitized.replaceAll(RegExp(r'data:\s*text/javascript', caseSensitive: false), '');
    
    // Remove potentially harmful characters for SQL injection
    sanitized = sanitized.replaceAll(RegExp(r'[\'";\\]'), '');
    
    // Remove potentially harmful characters for XSS
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}[\]]'), '');
    
    // Remove control characters
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    
    // Trim whitespace
    sanitized = sanitized.trim();
    
    return sanitized;
  }
  
  /// Sanitize username (Enhanced security)
  static String sanitizeUsername(String username) {
    // Remove @ symbol if present
    String sanitized = username.replaceAll('@', '');
    
    // Keep only alphanumeric and underscores, no special characters
    sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    
    // Convert to lowercase
    sanitized = sanitized.toLowerCase();
    
    // Additional security: limit length
    if (sanitized.length > 20) {
      sanitized = sanitized.substring(0, 20);
    }
    
    return sanitized;
  }
  
  /// Check for banned words (Enhanced implementation)
  static bool containsBannedWords(String text) {
    // Common banned words and patterns
    final bannedWords = [
      'spam', 'scam', 'hack', 'virus', 'malware',
      'phishing', 'fraud', 'attack', 'exploit',
      'password', 'hack', 'crack', 'keygen',
      'porn', 'adult', 'nsfw', 'xxx',
      'gambling', 'casino', 'bet', 'betting'
    ];
    
    // Common attack patterns
    final attackPatterns = [
      RegExp(r'\bselect\s+.*\s+from\b', caseSensitive: false),
      RegExp(r'\binsert\s+into\b', caseSensitive: false),
      RegExp(r'\bdelete\s+from\b', caseSensitive: false),
      RegExp(r'\bdrop\s+table\b', caseSensitive: false),
      RegExp(r'\bunion\s+select\b', caseSensitive: false),
      RegExp(r'\bor\s+1\s*=\s*1\b', caseSensitive: false),
      RegExp(r'\band\s+1\s*=\s*1\b', caseSensitive: false),
    ];
    
    final lowerText = text.toLowerCase();
    
    // Check banned words
    for (final word in bannedWords) {
      if (lowerText.contains(word)) {
        return true;
      }
    }
    
    // Check attack patterns
    for (final pattern in attackPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Sanitize message for storage (Enhanced security)
  static String sanitizeMessage(String message) {
    // Check message length first
    if (message.length > 10000) {
      throw Exception('Message too long');
    }
    
    String sanitized = sanitizeText(message);
    
    if (containsBannedWords(sanitized)) {
      throw Exception('Message contains inappropriate content or suspicious patterns');
    }
    
    // Additional check: prevent excessive repetition
    if (_hasExcessiveRepetition(sanitized)) {
      throw Exception('Message contains excessive repetition');
    }
    
    return sanitized;
  }
  
  /// Check for excessive repetition (spam prevention)
  static bool _hasExcessiveRepetition(String text) {
    // Check for repeated characters
    final repeatedChars = RegExp(r'(.)\1{9,}');
    if (repeatedChars.hasMatch(text)) {
      return true;
    }
    
    // Check for repeated words
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final wordCounts = <String, int>{};
    
    for (final word in words) {
      if (word.length > 3) {
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
        if (wordCounts[word]! > 10) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Sanitize email (Additional security)
  static String sanitizeEmail(String email) {
    // Remove potentially harmful characters
    String sanitized = email.replaceAll(RegExp(r'[<>"\';\\]'), '');
    
    // Convert to lowercase
    sanitized = sanitized.toLowerCase();
    
    // Validate format
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(sanitized)) {
      throw Exception('Invalid email format');
    }
    
    return sanitized;
  }
}
