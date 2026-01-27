// ============================================================================
// FILE: lib/core/utils/validators.dart
// PURPOSE: Input validation utilities
// ============================================================================

class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate password strength (Enhanced security)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    // Check for common patterns
    final commonPatterns = [
      RegExp(r'(.)\1{2,}'), // Repeated characters (aaa, 111)
      RegExp(r'(012|123|234|345|456|567|678|789|890)'), // Sequential numbers
      RegExp(r'(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)'), // Sequential letters
    ];
    
    for (final pattern in commonPatterns) {
      if (pattern.hasMatch(value.toLowerCase())) {
        return 'Password cannot contain common patterns or sequences';
      }
    }
    
    // Check against common passwords (simplified check)
    final commonPasswords = ['password', '12345678', 'qwerty123', 'admin123'];
    if (commonPasswords.contains(value.toLowerCase())) {
      return 'Password is too common. Please choose a more unique password';
    }
    
    return null;
  }
  
  /// Validate username format
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }
  
  /// Validate message content
  static String? validateMessage(String? value, int maxLength) {
    if (value == null || value.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    
    if (value.length > maxLength) {
      return 'Message exceeds maximum length of $maxLength characters';
    }
    
    return null;
  }
  
  /// Validate group name
  static String? validateGroupName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Group name is required';
    }
    
    if (value.length < 3) {
      return 'Group name must be at least 3 characters';
    }
    
    if (value.length > 50) {
      return 'Group name must be less than 50 characters';
    }
    
    return null;
  }
}
