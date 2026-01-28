// ============================================================================
// FILE: lib/core/themes/modern_theme.dart
// PURPOSE: Enhanced themes using modern design system
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_colors.dart';
import 'typography.dart';
import 'app_spacing.dart';

/// Modern app themes with premium design
class ModernTheme {
  // ============================================================================
  // LIGHT THEME
  // ============================================================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: ModernColors.primary,
        onPrimary: Colors.white,
        primaryContainer: ModernColors.primaryLight,
        onPrimaryContainer: ModernColors.primaryDark,
        
        secondary: ModernColors.accentTertiary,
        onSecondary: Colors.white,
        secondaryContainer: ModernColors.successLight,
        onSecondaryContainer: ModernColors.successDark,
        
        tertiary: ModernColors.accent,
        onTertiary: Colors.white,
        
        error: ModernColors.error,
        onError: Colors.white,
        errorContainer: ModernColors.errorLight,
        onErrorContainer: ModernColors.errorDark,
        
        background: ModernColors.lightBackground,
        onBackground: ModernColors.textPrimaryLight,
        
        surface: ModernColors.lightSurface,
        onSurface: ModernColors.textPrimaryLight,
        surfaceVariant: ModernColors.lightSurfaceVariant,
        onSurfaceVariant: ModernColors.textSecondaryLight,
        
        outline: ModernColors.textTertiaryLight,
        outlineVariant: ModernColors.glassBorderLight,
      ),
      
      scaffoldBackgroundColor: ModernColors.lightBackground,
      
      // Typography
      textTheme: AppTypography.lightTextTheme,
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: ModernColors.lightSurface,
        foregroundColor: ModernColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.lightTextTheme.headlineSmall,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      // Card
      cardTheme: CardTheme(
        elevation: 0,
        color: ModernColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderLG,
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: ModernColors.primaryShadow,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderMD,
          ),
          textStyle: AppTypography.button(),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ModernColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.button(color: ModernColors.primary),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ModernColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderMD,
          ),
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ModernColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderMD,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderMD,
          borderSide: BorderSide(color: ModernColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderMD,
          borderSide: BorderSide(color: ModernColors.error, width: 2),
        ),
        contentPadding: AppSpacing.allMD,
      ),
      
      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ModernColors.lightSurface,
        selectedItemColor: ModernColors.primary,
        unselectedItemColor: ModernColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ModernColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderLG,
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: ModernColors.textTertiaryLight,
        thickness: 1,
        space: AppSpacing.xs,
      ),
    );
  }
  
  // ============================================================================
  // DARK THEME
  // ============================================================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: ModernColors.primary,
        onPrimary: Colors.white,
        primaryContainer: ModernColors.primaryDark,
        onPrimaryContainer: ModernColors.primaryLight,
        
        secondary: ModernColors.accentTertiary,
        onSecondary: Colors.white,
        secondaryContainer: ModernColors.successDark,
        onSecondaryContainer: ModernColors.successLight,
        
        tertiary: ModernColors.accent,
        onTertiary: Colors.white,
        
        error: ModernColors.error,
        onError: Colors.white,
        errorContainer: ModernColors.errorDark,
        onErrorContainer: ModernColors.errorLight,
        
        background: ModernColors.darkBackground,
        onBackground: ModernColors.textPrimaryDark,
        
        surface: ModernColors.darkSurface,
        onSurface: ModernColors.textPrimaryDark,
        surfaceVariant: ModernColors.darkSurfaceVariant,
        onSurfaceVariant: ModernColors.textSecondaryDark,
        
        outline: ModernColors.textTertiaryDark,
        outlineVariant: ModernColors.glassBorderDark,
      ),
      
      scaffoldBackgroundColor: ModernColors.darkBackground,
      
      // Typography
      textTheme: AppTypography.darkTextTheme,
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: ModernColors.darkSurface,
        foregroundColor: ModernColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.darkTextTheme.headlineSmall,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card
      cardTheme: CardTheme(
        elevation: 0,
        color: ModernColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderLG,
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: ModernColors.primaryShadow,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderMD,
          ),
          textStyle: AppTypography.button(),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ModernColors.primaryLight,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.button(color: ModernColors.primaryLight),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ModernColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderMD,
          ),
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ModernColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderMD,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderMD,
          borderSide: BorderSide(color: ModernColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderMD,
          borderSide: BorderSide(color: ModernColors.error, width: 2),
        ),
        contentPadding: AppSpacing.allMD,
      ),
      
      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ModernColors.darkSurface,
        selectedItemColor: ModernColors.primary,
        unselectedItemColor: ModernColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ModernColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderLG,
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: ModernColors.textTertiaryDark,
        thickness: 1,
        space: AppSpacing.xs,
      ),
    );
  }
  
  // ============================================================================
  // AMOLED BLACK THEME (Battery Saving)
  // ============================================================================
  
  static ThemeData get amoledTheme {
    return darkTheme.copyWith(
      scaffoldBackgroundColor: ModernColors.amoledBackground,
      colorScheme: darkTheme.colorScheme.copyWith(
        background: ModernColors.amoledBackground,
        surface: ModernColors.amoledSurface,
        surfaceVariant: ModernColors.amoledSurfaceVariant,
      ),
      appBarTheme: darkTheme.appBarTheme.copyWith(
        backgroundColor: ModernColors.amoledSurface,
      ),
      cardTheme: darkTheme.cardTheme.copyWith(
        color: ModernColors.amoledSurface,
      ),
      bottomNavigationBarTheme: darkTheme.bottomNavigationBarTheme.copyWith(
        backgroundColor: ModernColors.amoledSurface,
      ),
    );
  }
}
