// ============================================================================
// FILE: lib/services/biometric_auth_service.dart
// PURPOSE: Biometric authentication (Face ID, Touch ID, Fingerprint)
// SECURITY: Platform biometric APIs with secure key unlock
//============================================================================

import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Biometric authentication service
/// 
/// Supports:
/// - iOS: Face ID, Touch ID
/// - Android: Fingerprint, Face unlock
/// - Windows: Hello
/// 
/// Fallback: PIN/Password
class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  factory BiometricAuthService() => _instance;

  BiometricAuthService._internal();

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric or device credentials are available
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate with biometrics
  /// 
  /// [reason] - Message shown to user explaining why auth is needed
  /// [useErrorDialogs] - Show error dialogs on failed authentication
  /// [stickyAuth] - Keep auth state across app restarts
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool biometricOnly = false,
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        throw Exception('Device does not support biometric authentication');
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        throw Exception('Biometric authentication not available');
      } else if (e.code == 'NotEnrolled') {
        throw Exception('No biometrics enrolled on this device');
      } else if (e.code == 'LockedOut') {
        throw Exception('Too many failed attempts. Biometrics locked.');
      } else if (e.code == 'PermanentlyLockedOut') {
        throw Exception('Biometrics permanently locked. Use device password.');
      }
      rethrow;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  /// Quick authentication (app unlock)
  Future<bool> authenticateQuick() async {
    return await authenticate(
      reason: 'Unlock Chatly',
      useErrorDialogs: false,
      stickyAuth: false,
      biometricOnly: false, // Allow PIN/Password fallback
    );
  }

  /// Sensitive operation authentication (accessing keys)
  Future<bool> authenticateForKeyAccess() async {
    return await authenticate(
      reason: 'Access encryption keys',
      useErrorDialogs: true,
      stickyAuth: true,
      biometricOnly: false,
    );
  }

  /// Ultra-sensitive operation (account deletion, key export)
  Future<bool> authenticateStrict() async {
    return await authenticate(
      reason: 'Verify your identity',
      useErrorDialogs: true,
      stickyAuth: true,
      biometricOnly: true, // Require biometrics, no fallback
    );
  }

  /// Stop authentication (cancel ongoing auth)
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      return false;
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.isEmpty) return 'Device credentials';
    
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometrics';
    } else if (types.contains(BiometricType.weak)) {
      return 'Quick unlock';
    }
    
    return 'Biometrics';
  }

  /// Check if specific biometric type is available
  Future<bool> hasBiometricType(BiometricType type) async {
    final available = await getAvailableBiometrics();
    return available.contains(type);
  }

  /// Check if Face ID is available (iOS)
  Future<bool> hasFaceID() async {
    return await hasBiometricType(BiometricType.face);
  }

  /// Check if fingerprint is available
  Future<bool> hasFingerprint() async {
    return await hasBiometricType(BiometricType.fingerprint);
  }
}
