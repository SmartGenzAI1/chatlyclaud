// ============================================================================
// FILE: lib/core/constants/theme_constants.dart
// PURPOSE: Color schemes and theme-related constants
// ============================================================================

import 'package:flutter/material.dart';

class ThemeConstants {
  // Primary Colors
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color secondaryEmerald = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  
  // Background Colors
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color darkBackground = Color(0xFF111827);
  
  // Status Colors
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF3B82F6);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  
  // Chat Bubble Colors
  static const Color sentMessageBubble = Color(0xFF6366F1);
  static const Color receivedMessageBubble = Color(0xFFE5E7EB);
  
  // Anonymous Chat
  static const Color anonymousMask = Color(0xFFF59E0B);
  static const Color anonymousBackground = Color(0xFFFEF3C7);
  
  // Premium Badges
  static const Color plusBadge = Color(0xFF10B981);
  static const Color proBadge = Color(0xFF8B5CF6);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, secondaryEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryIndigo.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
}
