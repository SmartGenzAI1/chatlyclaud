// ============================================================================
// FILE: lib/features/onboarding/presentation/screens/splash_screen.dart
// PURPOSE: Premium animated splash — waits for Firebase auth to initialize
//          before routing, so web-refresh sessions are restored correctly.
// ============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _textSlideAnim;

  bool _routed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _scaleAnim = CurvedAnimation(
        parent: _scaleController, curve: Curves.elasticOut);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _textSlideAnim = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleController.forward().then((_) => _fadeController.forward());

    // Minimum visual time so splash doesn't flash
    Future.delayed(const Duration(milliseconds: 1800), _tryRoute);
  }

  /// Called after minimum splash duration AND whenever AuthProvider updates.
  void _tryRoute() {
    if (_routed || !mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Wait until Firebase has resolved the auth state (first emission)
    if (!auth.isInitialized) {
      // Not ready yet — will be called again from Consumer below
      return;
    }

    _routed = true;
    if (auth.isAuthenticated) {
      AppRouter.navigateAndRemoveUntil(context, AppRouter.home);
    } else {
      AppRouter.navigateAndRemoveUntil(context, AppRouter.onboarding);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Every time AuthProvider notifies (including when isInitialized flips),
        // try to route — this is what fixes the web-refresh session bug.
        if (auth.isInitialized && !_routed) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _tryRoute());
        }
        return child!;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              ..._buildDecorations(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, child) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: child,
                        ),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF6366F1).withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.chat_bubble_rounded,
                              size: 56, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    AnimatedBuilder(
                      animation: _fadeAnim,
                      builder: (_, child) => Opacity(
                        opacity: _fadeAnim.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlideAnim.value),
                          child: child,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Chatly',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Smart. Private. Connected.',
                            style: TextStyle(
                              color: Color(0xFFB8BCC8),
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Loading bar at bottom
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _fadeAnim,
                  builder: (_, child) =>
                      Opacity(opacity: _fadeAnim.value, child: child),
                  child: Center(
                    child: SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDecorations() {
    final rng = math.Random(42);
    return List.generate(6, (i) {
      final size = 80.0 + rng.nextDouble() * 180;
      final size2 = MediaQuery.of(context).size;
      return Positioned(
        left: size2.width * rng.nextDouble() - size / 2,
        top: size2.height * rng.nextDouble() - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF6366F1).withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
      );
    });
  }
}
