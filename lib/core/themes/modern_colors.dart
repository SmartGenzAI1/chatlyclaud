// ============================================================================
// FILE: lib/core/themes/modern_colors.dart
// PURPOSE: Premium color palette with gradients for modern UI
// ============================================================================

import 'package:flutter/material.dart';

/// Modern color palette with HSL-based colors and premium gradients
/// Designed for accessibility with WCAG AA contrast ratios
class ModernColors {
  // ============================================================================
  // PRIMARY COLORS - Deep Purple to Blue spectrum
  // ============================================================================
  
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF5A67D8);
  static const Color primaryLight = Color(0xFF7F9CF5);
  
  // ============================================================================
  // ACCENT COLORS - Vibrant and professional
  // ============================================================================
  
  static const Color accent = Color(0xFF764BA2);
  static const Color accentSecondary = Color(0xFFEC4899); // Pink
  static const Color accentTertiary = Color(0xFF10B981); // Emerald
  
  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================
  
  // Light theme backgrounds
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  
  // Dark theme backgrounds
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  
  // AMOLED theme (pure black for battery saving)
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0A0A);
  static const Color amoledSurfaceVariant = Color(0xFF1A1A1A);
  
  // ============================================================================
  // TEXT COLORS
  // ============================================================================
  
  // Light theme text
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  
  // Dark theme text
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);
  
  // ============================================================================
  // STATUS & SEMANTIC COLORS
  // ============================================================================
  
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFF34D399); // Emerald 400
  static const Color successDark = Color(0xFF059669); // Emerald 600
  
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFFFFFF); // Red 400
  static const Color errorDark = Color(0xFFDC2626); // Red 600
  
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFBBF24); // Amber 400
  static const Color warningDark = Color(0xFFD97706); // Amber 600
  
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFF60A5FA); // Blue 400
  static const Color infoDark = Color(0xFF2563EB); // Blue 600
  
  // ============================================================================
  // CHAT-SPECIFIC COLORS
  // ============================================================================
  
  // Message bubbles
  static const Color sentBubbleStart = Color(0xFF667EEA);
  static const Color sentBubbleEnd = Color(0xFF764BA2);
  static const Color receivedBubbleLight = Color(0xFFF3F4F6);
  static const Color receivedBubbleDark = Color(0xFF374151);
  
  // Online status
  static const Color onlineGreen = Color(0xFF10B981);
  static const Color awayYellow = Color(0xFFF59E0B);
  static const Color offlineGray = Color(0xFF6B7280);
  
  // ============================================================================
  // PREMIUM COLORS
  // ============================================================================
  
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumPurple = Color(0xFF8B5CF6);
  static const Color premiumPink = Color(0xFFEC4899);
  
  // ============================================================================
  // GRADIENTS - Premium visual effects
  // ============================================================================
  
  /// Primary gradient (Purple to Blue)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
  
  /// Sent message bubble gradient
  static const LinearGradient sentMessageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
  
  /// Success gradient (Emerald)
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
  
  /// Premium badge gradient
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );
  
  /// Subtle shimmer gradient
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [
      Color(0x00FFFFFF),
      Color(0x33FFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Accent gradient (Pink to Purple)
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
  );
  
  /// Warm sunset gradient
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  );
  
  /// Cool ocean gradient
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
  );
  
  // ============================================================================
  // GLASSMORPHISM COLORS
  // ============================================================================
  
  /// Glass effect for light theme
  static Color glassLight = Colors.white.withOpacity(0.7);
  
  /// Glass effect for dark theme
  static Color glassDark = const Color(0xFF1E293B).withOpacity(0.7);
  
  /// Glass border light
  static Color glassBorderLight = Colors.white.withOpacity(0.2);
  
  /// Glass border dark
  static Color glassBorderDark = Colors.white.withOpacity(0.1);
  
  // ============================================================================
  // SHADOW COLORS
  // ============================================================================
  
  /// Soft shadow for light theme
  static Color shadowLight = Colors.black.withOpacity(0.08);
  
  /// Soft shadow for dark theme
  static Color shadowDark = Colors.black.withOpacity(0.25);
  
  /// Colored shadow for primary elements
  static Color primaryShadow = primary.withOpacity(0.3);
  
  /// Colored shadow for accent elements
  static Color accentShadow = accent.withOpacity(0.3);
  
  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Get appropriate text color based on background brightness
  static Color getTextColor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;
  }
  
  /// Get appropriate secondary text color based on background brightness
  static Color getSecondaryTextColor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;
  }
  
  /// Create a gradient with custom colors
  static LinearGradient createGradient({
    required Color start,
    required Color end,
    Alignment begin = Alignment.topLeft,
    Alignment endAlignment = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: endAlignment,
      colors: [start, end],
    );
  }
}
