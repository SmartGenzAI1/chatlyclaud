// ============================================================================
// FILE: lib/core/themes/typography.dart
// PURPOSE: Modern typography system with Inter and Poppins fonts
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern typography system for professional messaging app
/// Uses Inter for body text and Poppins for headings
class AppTypography {
  // ============================================================================
  // FONT FAMILIES
  // ============================================================================
  
  /// Primary font family (Inter) - Excellent for body text
  static String get primaryFontFamily => GoogleFonts.inter().fontFamily!;
  
  /// Display font family (Poppins) - Perfect for headings
  static String get displayFontFamily => GoogleFonts.poppins().fontFamily!;
  
  /// Monospace font family (JetBrains Mono) - For code/technical text
  static String get monospaceFontFamily => GoogleFonts.jetBrainsMono().fontFamily!;
  
  // ============================================================================
  // TEXT THEMES
  // ============================================================================
  
  /// Light theme typography
  static TextTheme lightTextTheme = GoogleFonts.interTextTheme(
    const TextTheme(
      // Display styles (Poppins) - Large headings
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
        color: Color(0xFF1F2937),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
        color: Color(0xFF1F2937),
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.25,
        color: Color(0xFF1F2937),
      ),
      
      // Headline styles - Section headings
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: Color(0xFF1F2937),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: Color(0xFF1F2937),
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        color: Color(0xFF1F2937),
      ),
      
      // Title styles - Card titles, list items
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.15,
        color: Color(0xFF1F2937),
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.15,
        color: Color(0xFF374151),
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
        color: Color(0xFF374151),
      ),
      
      // Body styles - Main content
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: Color(0xFF1F2937),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
        color: Color(0xFF374151),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.4,
        color: Color(0xFF6B7280),
      ),
      
      // Label styles - Buttons, chips
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
        color: Color(0xFF1F2937),
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: Color(0xFF374151),
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: Color(0xFF6B7280),
      ),
    ),
  ).copyWith(
    // Override display styles to use Poppins
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.5,
      color: const Color(0xFF1F2937),
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.5,
      color: const Color(0xFF1F2937),
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.3,
      letterSpacing: -0.25,
      color: const Color(0xFF1F2937),
    ),
  );
  
  /// Dark theme typography
  static TextTheme darkTextTheme = GoogleFonts.interTextTheme(
    const TextTheme(
      // Display styles (Poppins)
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
        color: Color(0xFFF9FAFB),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
        color: Color(0xFFF9FAFB),
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.25,
        color: Color(0xFFF9FAFB),
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: Color(0xFFF9FAFB),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: Color(0xFFF9FAFB),
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
        color: Color(0xFFF9FAFB),
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.15,
        color: Color(0xFFF9FAFB),
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.15,
        color: Color(0xFFE5E7EB),
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
        color: Color(0xFFE5E7EB),
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: Color(0xFFF9FAFB),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
        color: Color(0xFFD1D5DB),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.4,
        color: Color(0xFF9CA3AF),
      ),
      
      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
        color: Color(0xFFF9FAFB),
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: Color(0xFFD1D5DB),
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: Color(0xFF9CA3AF),
      ),
    ),
  ).copyWith(
    // Override display styles to use Poppins
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.5,
      color: const Color(0xFFF9FAFB),
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.5,
      color: const Color(0xFFF9FAFB),
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.3,
      letterSpacing: -0.25,
      color: const Color(0xFFF9FAFB),
    ),
  );
  
  // ============================================================================
  // CUSTOM TEXT STYLES
  // ============================================================================
  
  /// Chat message text style
  static TextStyle chatMessage({Color color = const Color(0xFF1F2937)}) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color,
    );
  }
  
  /// Chat timestamp
  static TextStyle chatTimestamp({Color color = const Color(0xFF6B7280)}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color,
    );
  }
  
  /// Username
  static TextStyle username({Color color = const Color(0xFF1F2937)}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: color,
    );
  }
  
  /// Button text
  static TextStyle button({Color color = Colors.white}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0.5,
      color: color,
    );
  }
  
  /// Premium badge
  static TextStyle premiumBadge({Color color = Colors.white}) {
    return GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 0.8,
      color: color,
    );
  }
}
