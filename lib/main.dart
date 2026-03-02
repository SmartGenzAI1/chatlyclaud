// ============================================================================
// FILE: lib/main.dart
// PURPOSE: Application entry point with error handling and initialization
// AUTHOR: Chatly Development Team
// VERSION: 1.0.0
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/themes/modern_theme.dart';
import 'core/errors/error_handler.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/subscription_provider.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'services/performance_monitor.dart';

/// Global navigator key for navigation without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Crashlytics (mobile only — not supported on web)
  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize notification service
  await NotificationService.instance.initialize();
  
  // Run app with error handling
  runApp(
    const ErrorHandler(
      child: ChatlyApp(),
    ),
  );
}

/// Main application widget with multi-provider setup
class ChatlyApp extends StatefulWidget {
  const ChatlyApp({super.key});

  @override
  State<ChatlyApp> createState() => _ChatlyAppState();
}

class _ChatlyAppState extends State<ChatlyApp> {
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Log app open event
    await _analyticsService.logAppOpen();
    
    // Monitor app startup performance
    await PerformanceMonitor.monitorAppStartup();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: ModernTheme.lightTheme,
            darkTheme: ModernTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.splash,
            navigatorObservers: [
              _analyticsService.observer,
            ],
          );
        },
      ),
    );
  }
}
