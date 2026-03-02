// ============================================================================
// FILE: lib/services/auth_service.dart
// PURPOSE: Firebase authentication service
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../core/errors/error_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    if (kIsWeb) {
      // Explicitly set LOCAL persistence on web so sessions survive refresh
      _auth.setPersistence(Persistence.LOCAL);
    }
  }
  
  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Get current user
  User? get currentUser => _auth.currentUser;
  
  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'signInWithEmailPassword');
      rethrow;
    }
  }
  
  /// Create account with email and password
  Future<UserCredential> createUserWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification (non-blocking — don't fail signup if this fails)
      credential.user?.sendEmailVerification().catchError((_) {});
      
      return credential;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'createUserWithEmailPassword');
      rethrow;
    }
  }
  
  /// Create user document in Firestore
  Future<void> createUserDocument(
    String uid,
    String email,
    String username,
  ) async {
    try {
      final user = UserModel(
        uid: uid,
        email: email,
        username: username,
        tier: UserTier.free,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        settings: UserSettings(),
        limits: UserLimits(),
      );
      
      await _firestore
          .collection('users')
          .doc(uid)
          .set(user.toFirestore());
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'createUserDocument');
      rethrow;
    }
  }
  
  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      
      return query.docs.isEmpty;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'isUsernameAvailable');
      return false;
    }
  }
  
  /// Update username
  Future<void> updateUsername(String uid, String username) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'username': username.toLowerCase()});
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'updateUsername');
      rethrow;
    }
  }
  
  /// Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'getUserData');
      return null;
    }
  }

  /// Look up a user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'getUserByUsername');
      return null;
    }
  }


  /// Update last seen
  Future<void> updateLastSeen(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'updateLastSeen');
    }
  }
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'sendPasswordResetEmail');
      rethrow;
    }
  }
  
  /// Update user settings in Firestore
  Future<void> updateUserSettings(String uid, UserSettings settings) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'settings': settings.toMap(),
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'updateUserSettings');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'signOut');
      rethrow;
    }
  }
  
  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user document
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user account
        await user.delete();
      }
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'deleteAccount');
      rethrow;
    }
  }
}
