// ============================================================================
// FILE: lib/services/auth_service.dart
// PURPOSE: Firebase authentication with Google Sign-In support
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../core/errors/error_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthService() {
    if (kIsWeb) {
      _auth.setPersistence(Persistence.LOCAL);
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'signInWithEmailPassword');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create Firestore user document if new
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocumentFromGoogle(userCredential.user!);
      }
      
      return userCredential;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'signInWithGoogle');
      rethrow;
    }
  }

  /// Create user document from Google sign-in
  Future<void> _createUserDocumentFromGoogle(User user) async {
    try {
      final username = (user.displayName ?? 'user_${user.uid.substring(0, 6)}')
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      
      await createUserDocument(user.uid, user.email ?? '', username);
    } catch (e) {
      debugPrint('Failed to create Google user doc: $e');
    }
  }

  /// Create account with email and password
  Future<UserCredential> createUserWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      credential.user?.sendEmailVerification().catchError((_) {});
      return credential;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'createUserWithEmailPassword');
      rethrow;
    }
  }

  /// Create user document in Firestore
  Future<void> createUserDocument(String uid, String email, String username) async {
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
      await _firestore.collection('users').doc(uid).set(user.toFirestore());
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'createUserDocument');
      rethrow;
    }
  }

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

  Future<void> updateUsername(String uid, String username) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'username': username.toLowerCase()
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'updateUsername');
      rethrow;
    }
  }

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

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) return UserModel.fromFirestore(query.docs.first);
      return null;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'getUserByUsername');
      return null;
    }
  }

  Future<void> updateLastSeen(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'updateLastSeen');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'sendPasswordResetEmail');
      rethrow;
    }
  }

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

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'signOut');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'deleteAccount');
      rethrow;
    }
  }
}
