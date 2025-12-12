// ============================================================================
// FILE: lib/core/themes/app_theme.dart
// PURPOSE: Complete theme configuration for light and dark modes
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme_constants.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: ThemeConstants.primaryIndigo,
      scaffoldBackgroundColor: ThemeConstants.lightBackground,
      
      colorScheme: const ColorScheme.light(
        primary: ThemeConstants.primaryIndigo,
        secondary: ThemeConstants.secondaryEmerald,
        tertiary: ThemeConstants.accentAmber,
        error: ThemeConstants.errorRed,
        background: ThemeConstants.lightBackground,
        surface: Colors.white,
      ),
      
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.textPrimaryLight,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.textPrimaryLight,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.textPrimaryLight,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ThemeConstants.textPrimaryLight,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeConstants.textPrimaryLight,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeConstants.textPrimaryLight,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: ThemeConstants.textPrimaryLight,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: ThemeConstants.textSecondaryLight,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: ThemeConstants.textSecondaryLight,
          ),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: ThemeConstants.primaryIndigo),
        titleTextStyle: TextStyle(
          color: ThemeConstants.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryIndigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          elevation: 2,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: ThemeConstants.primaryIndigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: ThemeConstants.errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
      
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ThemeConstants.primaryIndigo,
        unselectedItemColor: ThemeConstants.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: ThemeConstants.primaryIndigo,
      scaffoldBackgroundColor: ThemeConstants.darkBackground,
      
      colorScheme: const ColorScheme.dark(
        primary: ThemeConstants.primaryIndigo,
        secondary: ThemeConstants.secondaryEmerald,
        tertiary: ThemeConstants.accentAmber,
        error: ThemeConstants.errorRed,
        background: ThemeConstants.darkBackground,
        surface: Color(0xFF1F2937),
      ),
      
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.textPrimaryDark,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.textPrimaryDark,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.textPrimaryDark,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ThemeConstants.textPrimaryDark,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeConstants.textPrimaryDark,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeConstants.textPrimaryDark,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: ThemeConstants.textPrimaryDark,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: ThemeConstants.textSecondaryDark,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: ThemeConstants.textSecondaryDark,
          ),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        elevation: 0,
        iconTheme: IconThemeData(color: ThemeConstants.primaryIndigo),
        titleTextStyle: TextStyle(
          color: ThemeConstants.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryIndigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          elevation: 2,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: ThemeConstants.primaryIndigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: ThemeConstants.errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
      
      cardTheme: CardTheme(
        elevation: 2,
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F2937),
        selectedItemColor: ThemeConstants.primaryIndigo,
        unselectedItemColor: ThemeConstants.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
