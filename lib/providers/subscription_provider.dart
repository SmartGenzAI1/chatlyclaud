// ============================================================================
// FILE: lib/providers/subscription_provider.dart
// PURPOSE: Premium subscription state management
// ============================================================================

import 'package:flutter/material.dart';
import '../data/models/user_model.dart';

class SubscriptionProvider extends ChangeNotifier {
  UserTier _currentTier = UserTier.free;
  
  UserTier get currentTier => _currentTier;
  bool get isPremium => _currentTier != UserTier.free;
  bool get isPlus => _currentTier == UserTier.plus;
  bool get isPro => _currentTier == UserTier.pro;
  
  void setTier(UserTier tier) {
    _currentTier = tier;
    notifyListeners();
  }
  
  /// Get anonymous message limit
  int getAnonymousWeeklyLimit() {
    switch (_currentTier) {
      case UserTier.free:
        return 3;
      case UserTier.plus:
        return 10;
      case UserTier.pro:
        return 999999; // Unlimited
    }
  }
  
  /// Get anonymous character limit
  int getAnonymousCharLimit() {
    switch (_currentTier) {
      case UserTier.free:
        return 100;
      case UserTier.plus:
        return 250;
      case UserTier.pro:
        return 500;
    }
  }
  
  /// Get daily message limit
  int getDailyMessageLimit() {
    switch (_currentTier) {
      case UserTier.free:
        return 200;
      case UserTier.plus:
        return 500;
      case UserTier.pro:
        return 1000;
    }
  }
  
  /// Get group creation limit
  int getGroupCreationLimit() {
    switch (_currentTier) {
      case UserTier.free:
        return 0;
      case UserTier.plus:
        return 1;
      case UserTier.pro:
        return 2;
    }
  }
  
  /// Can create groups
  bool canCreateGroups() {
    return _currentTier != UserTier.free;
  }
  
  /// Can customize retention
  bool canCustomizeRetention() {
    return _currentTier != UserTier.free;
  }
}
