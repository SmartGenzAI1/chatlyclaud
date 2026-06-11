// ============================================================================
// FILE: lib/providers/auth_provider.dart
// PURPOSE: Authentication state management with Google Sign-In
// ============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../services/auth_service.dart';
import '../core/errors/error_handler.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _userModel = null;
      }
      if (!_isInitialized) _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _userModel = await _authService.getUserData(uid);
    } catch (e) {
      debugPrint('AuthProvider: failed to load user data: $e');
    }
    notifyListeners();
  }

  /// Email Sign In
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signInWithEmailPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e, stack) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stack, context: 'AuthProvider.signIn');
      _setLoading(false);
      return false;
    }
  }

  /// Google Sign In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _authService.signInWithGoogle();
      _setLoading(false);
      return result != null;
    } catch (e, stack) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stack, context: 'AuthProvider.signInWithGoogle');
      _setLoading(false);
      return false;
    }
  }

  /// Sign Up
  Future<bool> signUp(String email, String password, String username) async {
    _setLoading(true);
    _error = null;
    try {
      final trimmed = username.trim().toLowerCase();
      final isAvailable = await _authService.isUsernameAvailable(trimmed);
      if (!isAvailable) {
        _error = 'Username "@$trimmed" is already taken.';
        _setLoading(false);
        return false;
      }
      final credential = await _authService.createUserWithEmailPassword(email.trim(), password);
      try {
        await _authService.createUserDocument(credential.user!.uid, email.trim(), trimmed);
      } catch (firestoreErr) {
        debugPrint('AuthProvider.signUp: Firestore write failed: $firestoreErr');
      }
      _setLoading(false);
      return true;
    } catch (e, stack) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stack, context: 'AuthProvider.signUp');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.sendPasswordResetEmail(email.trim());
      _setLoading(false);
      return true;
    } catch (e, stack) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stack, context: 'AuthProvider.resetPassword');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUsername(String username) async {
    if (_user == null) return false;
    _setLoading(true);
    _error = null;
    try {
      final trimmed = username.trim().toLowerCase();
      final isAvailable = await _authService.isUsernameAvailable(trimmed);
      if (!isAvailable) {
        _error = 'Username is already taken';
        _setLoading(false);
        return false;
      }
      await _authService.updateUsername(_user!.uid, trimmed);
      await _loadUserData(_user!.uid);
      _setLoading(false);
      return true;
    } catch (e, stack) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stack, context: 'AuthProvider.updateUsername');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _userModel = null;
    } catch (e, stack) {
      await ErrorHandler.logError(e, stack, context: 'AuthProvider.signOut');
    }
    _setLoading(false);
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.deleteAccount();
      _user = null;
      _userModel = null;
      _setLoading(false);
      return true;
    } catch (e, stack) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stack, context: 'AuthProvider.deleteAccount');
      _setLoading(false);
      return false;
    }
  }

  Future<void> refreshUserData() async {
    if (_user == null) return;
    await _loadUserData(_user!.uid);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
