// ============================================================================
// FILE: lib/providers/auth_provider.dart
// PURPOSE: Authentication state management - production-grade
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
  bool _isInitialized = false; // ← true after first Firebase auth state emission
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

      if (!_isInitialized) {
        _isInitialized = true;
      }

      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _userModel = await _authService.getUserData(uid);
    } catch (e) {
      // Non-fatal: user is still authenticated even if profile load fails
      debugPrint('AuthProvider: failed to load user data: $e');
    }
    notifyListeners();
  }

  // ── Sign In ────────────────────────────────────────────────────────────────

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

  // ── Sign Up ────────────────────────────────────────────────────────────────

  Future<bool> signUp(String email, String password, String username) async {
    _setLoading(true);
    _error = null;

    try {
      // 1. Validate username
      final trimmed = username.trim().toLowerCase();
      final isAvailable = await _authService.isUsernameAvailable(trimmed);
      if (!isAvailable) {
        _error = 'Username "@$trimmed" is already taken. Choose another.';
        _setLoading(false);
        return false;
      }

      // 2. Create Firebase Auth account
      final credential = await _authService.createUserWithEmailPassword(
        email.trim(),
        password,
      );

      // 3. Create Firestore profile (fire-and-forget if it fails we still proceed)
      try {
        await _authService.createUserDocument(
          credential.user!.uid,
          email.trim(),
          trimmed,
        );
      } catch (firestoreErr) {
        // Log but don't block — user is authenticated, profile can be created later
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

  // ── Password Reset ─────────────────────────────────────────────────────────

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

  // ── Update Username ────────────────────────────────────────────────────────

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

  // ── Sign Out ───────────────────────────────────────────────────────────────

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

  // ── Delete Account ─────────────────────────────────────────────────────────

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

  // ── Helpers ────────────────────────────────────────────────────────────────

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
