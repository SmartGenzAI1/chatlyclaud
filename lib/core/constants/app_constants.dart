// ============================================================================
// FILE: lib/core/constants/app_constants.dart
// PURPOSE: Application-wide constants and configuration
// ============================================================================

class AppConstants {
  // App Information
  static const String appName = 'Chatly';
  static const String appTagline = 'Smart. Private. Connected.';
  static const String appVersion = '1.0.0';
  
  // API & Backend
  static const String apiBaseUrl = 'https://api.chatly.app';
  static const String unsplashApiKey = 'YOUR_UNSPLASH_API_KEY';
  static const String perspectiveApiKey = 'YOUR_PERSPECTIVE_API_KEY';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String groupsCollection = 'groups';
  static const String anonymousCollection = 'anonymous_messages';
  
  // Message Limits
  static const int freeUserDailyMessageLimit = 200;
  static const int plusUserDailyMessageLimit = 500;
  static const int proUserDailyMessageLimit = 1000;
  
  // Anonymous Chat Limits
  static const int freeAnonymousWeeklyLimit = 3;
  static const int plusAnonymousWeeklyLimit = 10;
  static const int freeAnonymousCharLimit = 100;
  static const int plusAnonymousCharLimit = 250;
  static const int proAnonymousCharLimit = 500;
  
  // Group Limits
  static const int maxGroupMembers = 25;
  static const int plusGroupCreationLimit = 1;
  static const int proGroupCreationLimit = 2;
  
  // Message Retention
  static const int defaultRetentionDays = 7;
  static const int minRetentionDays = 2;
  static const int maxRetentionDays = 7;
  
  // Account Deletion
  static const int minInactivityDaysBeforeDeletion = 40;
  static const int maxInactivityDaysBeforeDeletion = 70;
  static const int deletionGracePeriodDays = 30;
  
  // Security
  static const int maxSignupsPerIPPerDay = 3;
  static const int minPasswordLength = 8;
  static const double toxicityThreshold = 0.7;
  
  // Ban System
  static const int reports24hFor1DayBan = 2;
  static const int reports24hFor3DayBan = 5;
  static const int reports24hFor7DayBan = 10;
  static const int reports30dFor1WeekBan = 10;
  static const int reports30dForPermaBan = 26;
  
  // Subscription Pricing (in INR)
  static const int plusYearlyPrice = 199;
  static const int proYearlyPrice = 299;
  static const double targetConversionRate = 0.05; // 5%
  
  // KPI Targets
  static const int targetDAUIn3Months = 1000;
  static const double targetDay7Retention = 0.40;
  static const double targetDay30Retention = 0.20;
  static const double targetMessageDeliveryRate = 0.995;
  static const double maxCrashRate = 0.005;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
}
