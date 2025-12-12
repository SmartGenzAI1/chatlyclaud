// ============================================================================
// FILE: lib/router/app_router.dart
// PURPOSE: Application routing and navigation
// ============================================================================

import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/username_setup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/chat/presentation/screens/home_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/anonymous/presentation/screens/anonymous_feed_screen.dart';
import '../features/groups/presentation/screens/groups_list_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/premium/presentation/screens/premium_screen.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String usernameSetup = '/username-setup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String anonymousFeed = '/anonymous';
  static const String groupsList = '/groups';
  static const String settings = '/settings';
  static const String premium = '/premium';
  
  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      
      case usernameSetup:
        return MaterialPageRoute(builder: (_) => const UsernameSetupScreen());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: args?['chatId'] ?? '',
            otherUserId: args?['otherUserId'] ?? '',
            otherUsername: args?['otherUsername'] ?? '',
          ),
        );
      
      case anonymousFeed:
        return MaterialPageRoute(builder: (_) => const AnonymousFeedScreen());
      
      case groupsList:
        return MaterialPageRoute(builder: (_) => const GroupsListScreen());
      
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case premium:
        return MaterialPageRoute(builder: (_) => const PremiumScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
  
  /// Navigation helpers
  static void navigateTo(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }
  
  static void navigateAndReplace(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, route, arguments: arguments);
  }
  
  static void navigateAndRemoveUntil(BuildContext context, String route) {
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
  
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
