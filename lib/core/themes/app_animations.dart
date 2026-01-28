// ============================================================================
// FILE: lib/core/themes/app_animations.dart
// PURPOSE: Animation configurations and constants
// ============================================================================

import 'package:flutter/material.dart';

/// Centralized animation configurations for consistent motion design
class AppAnimations {
  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================
  
  /// Instant (no animation) - 0ms
  static const Duration instant = Duration.zero;
  
  /// Very fast - 100ms (micro-interactions)
  static const Duration veryFast = Duration(milliseconds: 100);
  
  /// Fast - 200ms (button presses, small UI changes)
  static const Duration fast = Duration(milliseconds: 200);
  
  /// Normal - 300ms (standard transitions)
  static const Duration normal = Duration(milliseconds: 300);
  
  /// Medium - 400ms (page transitions)
  static const Duration medium = Duration(milliseconds: 400);
  
  /// Slow - 600ms (complex animations)
  static const Duration slow = Duration(milliseconds: 600);
  
  /// Very slow - 800ms (special effects)
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // ============================================================================
  // EASING CURVES
  // ============================================================================
  
  /// Standard easing - Natural motion
  static const Curve standard = Curves.easeInOut;
  
  /// Emphasized easing - More pronounced
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  
  /// Decelerate - Element entering screen
  static const Curve decelerate = Curves.easeOut;
  
  /// Accelerate - Element leaving screen
  static const Curve accelerate = Curves.easeIn;
  
  /// Sharp - Quick entry with snap
  static const Curve sharp = Curves.easeInOutQuart;
  
  /// Bounce - Playful effect
  static const Curve bounce = Curves.bounceOut;
  
  /// Elastic - Spring-like effect
  static const Curve elastic = Curves.elasticOut;
  
  /// Linear - Constant speed
  static const Curve linear = Curves.linear;
  
  // ============================================================================
  // PAGE TRANSITIONS
  // ============================================================================
  
  /// Slide transition from right
  static Widget slideTransitionFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: emphasized,
      )),
      child: child,
    );
  }
  
  /// Fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
  
  /// Scale transition
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: emphasized,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  /// Slide and fade transition
  static Widget slideAndFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: emphasized,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  // ============================================================================
  // CUSTOM PAGE ROUTE
  // ============================================================================
  
  /// Create custom page route with specified transition
  static PageRoute createRoute({
    required Widget page,
    RouteTransitionsBuilder? transitionsBuilder,
    Duration? duration,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? medium,
      transitionsBuilder: transitionsBuilder ?? slideTransitionFromRight,
    );
  }
  
  // ============================================================================
  // STAGGER DELAYS
  // ============================================================================
  
  /// Calculate stagger delay for list items
  /// [index] - Item index in list
  /// [baseDelay] - Base delay in milliseconds (default: 50ms)
  static Duration staggerDelay(int index, {int baseDelay = 50}) {
    return Duration(milliseconds: index * baseDelay);
  }
  
  // ============================================================================
  // SHAKE ANIMATION (For errors)
  // ============================================================================
  
  /// Create shake animation controller
  static AnimationController createShakeController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );
  }
  
  /// Shake animation tween
  static Animation<double> createShakeTween(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticIn,
    ));
  }
  
  // ============================================================================
  // PULSE ANIMATION (For notifications)
  // ============================================================================
  
  /// Create pulse animation controller
  static AnimationController createPulseController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    )..repeat(reverse: true);
  }
  
  /// Pulse animation tween
  static Animation<double> createPulseTween(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  // ============================================================================
  // ROTATION ANIMATION
  // ============================================================================
  
  /// Create rotation animation controller
  static AnimationController createRotationController(
    TickerProvider vsync, {
    Duration? duration,
  }) {
    return AnimationController(
      duration: duration ?? const Duration(milliseconds: 300),
      vsync: vsync,
    );
  }
  
  /// Rotation animation tween (quarter turn)
  static Animation<double> createRotationTween(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(
        parent: controller,
        curve: emphasized,
      ),
    );
  }
}
