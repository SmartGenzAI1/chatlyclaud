// ============================================================================
// FILE: lib/core/widgets/glass_container.dart
// PURPOSE: Reusable glassmorphism container widget
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../themes/app_spacing.dart';

/// Glassmorphic container with blur effect and optional border
/// Perfect for premium UI elements like app bars, modals, and cards
class GlassContainer extends StatelessWidget {
  /// Child widget
  final Widget child;
  
  /// Blur intensity (0-20, default: 10)
  final double blur;
  
  /// Background opacity (0-1, default: 0.2)
  final double opacity;
  
  /// Border radius (default: 16)
  final double borderRadius;
  
  /// Container padding
  final EdgeInsetsGeometry? padding;
  
  /// Container margin
  final EdgeInsetsGeometry? margin;
  
  /// Container width
  final double? width;
  
  /// Container height
  final double? height;
  
  /// Show border (default: true)
  final bool showBorder;
  
  /// Border color (default: white with 0.2 opacity)
  final Color? borderColor;
  
  /// Border width (default: 1.5)
  final double borderWidth;
  
  /// Background color (null for automatic theme-based color)
  final Color? backgroundColor;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 1.5,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final defaultBgColor = isDark
        ? Colors.white.withOpacity(opacity)
        : Colors.white.withOpacity(opacity);
    
    final defaultBorderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.3);
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? defaultBorderColor,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? defaultBgColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Preset glassmorphic app bar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final double blur;
  final double opacity;
  
  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.blur = 10.0,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: blur,
      opacity: opacity,
      borderRadius: 0,
      showBorder: false,
      height: preferredSize.height,
      child: AppBar(
        title: title,
        leading: leading,
        actions: actions,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Preset glassmorphic bottom navigation
class GlassBottomNav extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  
  const GlassBottomNav({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: blur,
      opacity: opacity,
      borderRadius: 0,
      showBorder: false,
      child: child,
    );
  }
}

/// Glassmorphic card
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  
  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.15,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = GlassContainer(
      blur: blur,
      opacity: opacity,
      borderRadius: AppSpacing.radiusLG,
      padding: padding ?? AppSpacing.allMD,
      margin: margin,
      child: child,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        child: container,
      );
    }
    
    return container;
  }
}
