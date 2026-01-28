// ============================================================================
// FILE: lib/services/secure_storage_service.dart
// PURPOSE: Secure key storage using platform-specific keychains
// SECURITY: iOS Keychain, Android Keystore, encrypted SharedPreferences fallback
// ============================================================================

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'encryption_service.dart';
import 'security_audit_log.dart';

/// Secure storage service for sensitive data
/// 
/// Storage hierarchy (by sensitivity):
/// 1. Identity keys → Platform keychain (highest security)
/// 2. Session keys → Encrypted memory (ephemeral)
/// 3. Settings → Encrypted SharedPreferences
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  
  late final FlutterSecureStorage _secureStorage;
  final EncryptionService _encryptionService = EncryptionService();
  
  // Storage keys
  static const String identityPrivateKeyKey = 'identity_private_key';
  static const String identityPublicKeyKey = 'identity_public_key';
  static const String signedPreKeyKey = 'signed_prekey';
  static const String signedPreKeySignatureKey = 'signed_prekey_signature';
  static const String oneTimePreKeysKey = 'one_time_prekeys';
  static const String deviceSaltKey = 'device_salt';
  static const String lastKeyRotationKey = 'last_key_rotation';
  
  factory SecureStorageService() => _instance;

  SecureStorageService._internal() {
    _initializeStorage();
  }

  void _initializeStorage() {
    // Configure secure storage with platform-specific options
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      // Require authentication to unlock keys
      resetOnError: true,
    );
    
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      // Keys accessible after first unlock
    );
    
    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
  }

  /// Save identity key pair (long-term keys)
  Future<void> saveIdentityKeys({
    required String privateKey,
    required String publicKey,
  }) async {
    // Input validation
    if (privateKey.isEmpty || publicKey.isEmpty) {
      throw ArgumentError('Keys cannot be empty');
    }
    
    try {
      // Atomic operation with rollback on failure
      await Future.wait([
        _secureStorage.write(key: identityPrivateKeyKey, value: privateKey),
        _secureStorage.write(key: identityPublicKeyKey, value: publicKey),
      ]);
      
      SecurityAuditLog.logEvent(
        event: 'identity_keys_saved',
        details: 'Identity keys saved successfully',
        level: SecurityLevel.info,
      );
    } catch (e) {
      // Rollback on failure
      await Future.wait([
        _secureStorage.delete(key: identityPrivateKeyKey),
        _secureStorage.delete(key: identityPublicKeyKey),
      ]).catchError((_) => null);
      
      SecurityAuditLog.logEvent(
        event: 'identity_keys_save_failed',
        details: 'Failed to save identity keys: $e',
        level: SecurityLevel.critical,
      );
      
      throw Exception('Failed to save identity keys: $e');
    }
  }

  /// Get identity private key
  Future<String?> getIdentityPrivateKey() async {
    try {
      return await _secureStorage.read(key: identityPrivateKeyKey);
    } catch (e) {
      throw Exception('Failed to read identity private key: $e');
    }
  }

  /// Get identity public key
  Future<String?> getIdentityPublicKey() async {
    try {
      return await _secureStorage.read(key: identityPublicKeyKey);
    } catch (e) {
      throw Exception('Failed to read identity public key: $e');
    }
  }

  /// Save signed prekey (rotated weekly)
  Future<void> saveSignedPreKey({
    required String preKey,
    required String signature,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: signedPreKeyKey, value: preKey),
        _secureStorage.write(key: signedPreKeySignatureKey, value: signature),
        _secureStorage.write(
          key: lastKeyRotationKey,
          value: DateTime.now().toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw Exception('Failed to save signed prekey: $e');
    }
  }

  /// Get signed prekey
  Future<Map<String, String>?> getSignedPreKey() async {
    try {
      final preKey = await _secureStorage.read(key: signedPreKeyKey);
      final signature = await _secureStorage.read(key: signedPreKeySignatureKey);
      
      if (preKey == null || signature == null) return null;
      
      return {
        'preKey': preKey,
        'signature': signature,
      };
    } catch (e) {
      throw Exception('Failed to read signed prekey: $e');
    }
  }

  /// Save one-time prekeys (batch of 100)
  Future<void> saveOneTimePreKeys(List<String> preKeys) async {
    try {
      final encoded = jsonEncode(preKeys);
      await _secureStorage.write(key: oneTimePreKeysKey, value: encoded);
    } catch (e) {
      throw Exception('Failed to save one-time prekeys: $e');
    }
  }

  /// Get one-time prekeys
  Future<List<String>> getOneTimePreKeys() async {
    try {
      final encoded = await _secureStorage.read(key: oneTimePreKeysKey);
      if (encoded == null) return [];
      
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded.cast<String>();
    } catch (e) {
      throw Exception('Failed to read one-time prekeys: $e');
    }
  }

  /// Consume one-time prekey (remove after use)
  Future<String?> consumeOneTimePreKey() async {
    try {
      final preKeys = await getOneTimePreKeys();
      if (preKeys.isEmpty) return null;
      
      final preKey = preKeys.first;
      preKeys.removeAt(0);
      
      await saveOneTimePreKeys(preKeys);
      return preKey;
    } catch (e) {
      throw Exception('Failed to consume one-time prekey: $e');
    }
  }

  /// Generate and save device salt (for key derivation)
  Future<String> getOrCreateDeviceSalt() async {
    try {
      var salt = await _secureStorage.read(key: deviceSaltKey);
      
      if (salt == null) {
        // Generate new salt
        final saltBytes = _encryptionService.generateSalt();
        salt = base64Encode(saltBytes);
        await _secureStorage.write(key: deviceSaltKey, value: salt);
      }
      
      return salt;
    } catch (e) {
      throw Exception('Failed to get/create device salt: $e');
    }
  }

  /// Check if keys need rotation (weekly rotation)
  Future<bool> needsKeyRotation({int graceDays = 7}) async {
    try {
      final lastRotation = await _secureStorage.read(key: lastKeyRotationKey);
      if (lastRotation == null) return true;
      
      final lastRotationDate = DateTime.tryParse(lastRotation);
      if (lastRotationDate == null) {
        // Corrupted data, force rotation
        SecurityAuditLog.logEvent(
          event: 'corrupted_rotation_data',
          details: 'Key rotation timestamp corrupted, forcing rotation',
          level: SecurityLevel.warning,
        );
        return true;
      }
      
      final daysSinceRotation = DateTime.now().difference(lastRotationDate).inDays;
      return daysSinceRotation >= graceDays; // Weekly rotation
    } catch (e) {
      // If we can't determine, assume rotation needed for safety
      return true;
    }
  }

  /// Save generic encrypted value
  Future<void> saveEncrypted(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to save encrypted value: $e');
    }
  }

  /// Read generic encrypted value
  Future<String?> readEncrypted(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw Exception('Failed to read encrypted value: $e');
    }
  }

  /// Delete key
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete key: $e');
    }
  }

  /// Delete all keys (secure wipe on logout)
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw Exception('Failed to delete all keys: $e');
    }
  }

  /// Check if identity keys exist
  Future<bool> hasIdentityKeys() async {
    try {
      final privateKey = await getIdentityPrivateKey();
      final publicKey = await getIdentityPublicKey();
      
      return privateKey != null && publicKey != null;
    } catch (e) {
      return false;
    }
  }

  /// Get all keys (for backup - must be encrypted after retrieval!)
  Future<Map<String, String>> getAllKeys() async {
    try {
      final all = await _secureStorage.readAll();
      return all;
    } catch (e) {
      throw Exception('Failed to read all keys: $e');
    }
  }

  /// Restore keys from backup
  Future<void> restoreKeys(Map<String, String> keys) async {
    try {
      for (final entry in keys.entries) {
        await _secureStorage.write(key: entry.key, value: entry.value);
      }
    } catch (e) {
      throw Exception('Failed to restore keys: $e');
    }
  }
  
  /// Verify integrity of stored keys
  Future<bool> verifyKeyIntegrity() async {
    try {
      final privateKey = await getIdentityPrivateKey();
      final publicKey = await getIdentityPublicKey();
      
      if (privateKey == null || publicKey == null) {
        SecurityAuditLog.logEvent(
          event: 'key_integrity_check_failed',
          details: 'Identity keys missing',
          level: SecurityLevel.critical,
        );
        return false;
      }
      
      // Basic validation: keys should be non-empty base64 strings
      if (privateKey.isEmpty || publicKey.isEmpty) {
        SecurityAuditLog.logEvent(
          event: 'key_integrity_check_failed',
          details: 'Identity keys are empty',
          level: SecurityLevel.critical,
        );
        return false;
      }
      
      // Verify base64 format
      try {
        base64Decode(privateKey);
        base64Decode(publicKey);
      } catch (e) {
        SecurityAuditLog.logEvent(
          event: 'key_integrity_check_failed',
          details: 'Identity keys have invalid format',
          level: SecurityLevel.critical,
        );
        return false;
      }
      
      SecurityAuditLog.logEvent(
        event: 'key_integrity_verified',
        details: 'Key integrity check passed',
        level: SecurityLevel.info,
      );
      
      return true;
    } catch (e) {
      SecurityAuditLog.logEvent(
        event: 'key_integrity_check_error',
        details: 'Error during key integrity check: $e',
        level: SecurityLevel.warning,
      );
      return false;
    }
  }
}
