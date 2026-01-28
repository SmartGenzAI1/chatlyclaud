// ============================================================================
// FILE: lib/core/themes/app_spacing.dart
// PURPOSE: Consistent spacing and layout constants
// ============================================================================

import 'package:flutter/material.dart';

/// Consistent spacing system for the entire app
/// Based on 4px grid system for perfect alignment
class AppSpacing {
  // ============================================================================
  // BASE UNIT - All spacing is a multiple of 4px
  // ============================================================================
  
  static const double base = 4.0;
  
  // ============================================================================
  // SPACING SCALE
  // ============================================================================
  
  /// 4px - Minimal spacing
  static const double xxs = base;
  
  /// 8px - Extra small spacing
  static const double xs = base * 2;
  
  /// 12px - Small spacing
  static const double sm = base * 3;
  
  /// 16px - Medium spacing (default)
  static const double md = base * 4;
  
  /// 20px - Medium-large spacing
  static const double mlg = base * 5;
  
  /// 24px - Large spacing
  static const double lg = base * 6;
  
  /// 32px - Extra large spacing
  static const double xl = base * 8;
  
  /// 40px - 2X large spacing
  static const double xxl = base * 10;
  
  /// 48px - 3X large spacing
  static const double xxxl = base * 12;
  
  // ============================================================================
  // EDGE INSETS
  // ============================================================================
  
  /// Zero padding
  static const EdgeInsets zero = EdgeInsets.zero;
  
  /// All sides - XXS (4px)
  static const EdgeInsets allXXS = EdgeInsets.all(xxs);
  
  /// All sides - XS (8px)
  static const EdgeInsets allXS = EdgeInsets.all(xs);
  
  /// All sides - SM (12px)
  static const EdgeInsets allSM = EdgeInsets.all(sm);
  
  /// All sides - MD (16px)
  static const EdgeInsets allMD = EdgeInsets.all(md);
  
  /// All sides - LG (24px)
  static const EdgeInsets allLG = EdgeInsets.all(lg);
  
  /// All sides - XL (32px)
  static const EdgeInsets allXL = EdgeInsets.all(xl);
  
  /// Horizontal - MD (16px)
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  
  /// Horizontal - LG (24px)
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  
  /// Vertical - MD (16px)
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  
  /// Vertical - LG (24px)
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  
  /// Page padding (horizontal only)
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );
  
  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  
  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  
  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  
  /// None (0px)
  static const double radiusNone = 0.0;
  
  /// Small radius (8px)
  static const double radiusSM = xs;
  
  /// Medium radius (12px)
  static const double radiusMD = sm;
  
  /// Large radius (16px)
  static const double radiusLG = md;
  
  /// Extra large radius (20px)
  static const double radiusXL = mlg;
  
  /// XX large radius (24px)
  static const double radiusXXL = lg;
  
  /// Circle/pill radius (999px)
  static const double radiusFull = 999.0;
  
  // ============================================================================
  // BORDER RADIUS INSTANCES
  // ============================================================================
  
  /// No radius
  static const BorderRadius borderNone = BorderRadius.zero;
  
  /// Small rounded corners
  static BorderRadius borderSM = BorderRadius.circular(radiusSM);
  
  /// Medium rounded corners
  static BorderRadius borderMD = BorderRadius.circular(radiusMD);
  
  /// Large rounded corners
  static BorderRadius borderLG = BorderRadius.circular(radiusLG);
  
  /// Extra large rounded corners
  static BorderRadius borderXL = BorderRadius.circular(radiusXL);
  
  /// XX large rounded corners
  static BorderRadius borderXXL = BorderRadius.circular(radiusXXL);
  
  /// Fully rounded (circle/pill)
  static BorderRadius borderFull = BorderRadius.circular(radiusFull);
  
  // ============================================================================
  // SIZED BOXES (Spacers)
  // ============================================================================
  
  /// Vertical space - XXS (4px)
  static const SizedBox vSpaceXXS = SizedBox(height: xxs);
  
  /// Vertical space - XS (8px)
  static const SizedBox vSpaceXS = SizedBox(height: xs);
  
  /// Vertical space - SM (12px)
  static const SizedBox vSpaceSM = SizedBox(height: sm);
  
  /// Vertical space - MD (16px)
  static const SizedBox vSpaceMD = SizedBox(height: md);
  
  /// Vertical space - LG (24px)
  static const SizedBox vSpaceLG = SizedBox(height: lg);
  
  /// Vertical space - XL (32px)
  static const SizedBox vSpaceXL = SizedBox(height: xl);
  
  /// Horizontal space - XXS (4px)
  static const SizedBox hSpaceXXS = SizedBox(width: xxs);
  
  /// Horizontal space - XS (8px)
  static const SizedBox hSpaceXS = SizedBox(width: xs);
  
  /// Horizontal space - SM (12px)
  static const SizedBox hSpaceSM = SizedBox(width: sm);
  
  /// Horizontal space - MD (16px)
  static const SizedBox hSpaceMD = SizedBox(width: md);
  
  /// Horizontal space - LG (24px)
  static const SizedBox hSpaceLG = SizedBox(width: lg);
  
  /// Horizontal space - XL (32px)
  static const SizedBox hSpaceXL = SizedBox(width: xl);
  
  // ============================================================================
  // ICON SIZES
  // ============================================================================
  
  /// Small icon (16px)
  static const double iconSM = md;
  
  /// Medium icon (24px)
  static const double iconMD = lg;
  
  /// Large icon (32px)
  static const double iconLG = xl;
  
  /// Extra large icon (48px)
  static const double iconXL = xxxl;
  
  // ============================================================================
  // AVATAR SIZES
  // ============================================================================
  
  /// Small avatar (32px)
  static const double avatarSM = xl;
  
  /// Medium avatar (40px)
  static const double avatarMD = xxl;
  
  /// Large avatar (56px)
  static const double avatarLG = base * 14;
  
  /// Extra large avatar (72px)
  static const double avatarXL = base * 18;
  
  // ============================================================================
  // BUTTON HEIGHTS
  // ============================================================================
  
  /// Small button height (32px)
  static const double buttonSM = xl;
  
  /// Medium button height (44px)
  static const double buttonMD = base * 11;
  
  /// Large button height (52px)
  static const double buttonLG = base * 13;
  
  // ============================================================================
  // APP BAR
  // ============================================================================
  
  /// App bar height (56px)
  static const double appBarHeight = base * 14;
  
  /// App bar elevation
  static const double appBarElevation = 0.0;
  
  // ============================================================================
  // BOTTOM NAV
  // ============================================================================
  
  /// Bottom navigation height (60px)
  static const double bottomNavHeight = base * 15;
  
  // ============================================================================
  // DIVIDER
  // ============================================================================
  
  /// Thin divider (1px)
  static const double dividerThin = 1.0;
  
  /// Medium divider (2px)
  static const double dividerMedium = 2.0;
  
  /// Thick divider (4px)
  static const double dividerThick = xxs;
}
