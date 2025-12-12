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
  
  /// Validate password strength
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
