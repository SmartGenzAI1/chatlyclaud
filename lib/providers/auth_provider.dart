// ============================================================================
// FILE: lib/providers/auth_provider.dart
// PURPOSE: Authentication state management
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
  String? _error;
  
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
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
      
      notifyListeners();
    });
  }
  
  Future<void> _loadUserData(String uid) async {
    _userModel = await _authService.getUserData(uid);
    notifyListeners();
  }
  
  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _authService.signInWithEmailPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'AuthProvider.signIn');
      _setLoading(false);
      return false;
    }
  }
  
  /// Create account
  Future<bool> signUp(String email, String password, String username) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Check username availability
      final isAvailable = await _authService.isUsernameAvailable(username);
      if (!isAvailable) {
        _error = 'Username is already taken';
        _setLoading(false);
        return false;
      }
      
      // Create account
      final credential = await _authService.createUserWithEmailPassword(
        email,
        password,
      );
      
      // Create user document
      await _authService.createUserDocument(
        credential.user!.uid,
        email,
        username,
      );
      
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'AuthProvider.signUp');
      _setLoading(false);
      return false;
    }
  }
  
  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'AuthProvider.resetPassword');
      _setLoading(false);
      return false;
    }
  }
  
  /// Update username
  Future<bool> updateUsername(String username) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _error = null;
    
    try {
      final isAvailable = await _authService.isUsernameAvailable(username);
      if (!isAvailable) {
        _error = 'Username is already taken';
        _setLoading(false);
        return false;
      }
      
      await _authService.updateUsername(_user!.uid, username);
      await _loadUserData(_user!.uid);
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'AuthProvider.updateUsername');
      _setLoading(false);
      return false;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
      _user = null;
      _userModel = null;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'AuthProvider.signOut');
    }
    
    _setLoading(false);
  }
  
  /// Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _error = null;
    
    try {
      await _authService.deleteAccount();
      _user = null;
      _userModel = null;
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'AuthProvider.deleteAccount');
      _setLoading(false);
      return false;
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
