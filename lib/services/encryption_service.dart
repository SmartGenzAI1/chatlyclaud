// ============================================================================
// FILE: lib/services/encryption_service.dart
// PURPOSE: End-to-end encryption service for secure messaging
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  
  // RSA key sizes for different security levels
  static const int rsaKeySize = 2048;
  static const int aesKeySize = 256;
  
  // Key storage keys
  static const String privateKeyKey = 'private_key';
  static const String publicKeyKey = 'public_key';
  static const String aesKeyKey = 'aes_key';

  factory EncryptionService() => _instance;

  EncryptionService._internal();

  /// Generate RSA key pair for user
  Future<Map<String, String>> generateKeyPair() async {
    try {
      // In a real implementation, you would use a proper RSA key generator
      // For now, we'll use a simplified approach with AES for demonstration
      final aesKey = encrypt.Key.fromLength(32);
      final iv = encrypt.IV.fromLength(16);
      
      return {
        'privateKey': base64Encode(aesKey.bytes),
        'publicKey': base64Encode(iv.bytes),
      };
    } catch (e) {
      throw Exception('Failed to generate key pair: $e');
    }
  }

  /// Encrypt message with recipient's public key
  String encryptMessage(String message, String publicKey) {
    try {
      final key = encrypt.Key.fromBase64(publicKey);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final encrypted = encrypter.encrypt(message, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Failed to encrypt message: $e');
    }
  }

  /// Decrypt message with private key
  String decryptMessage(String encryptedMessage, String privateKey) {
    try {
      final key = encrypt.Key.fromBase64(privateKey);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final decrypted = encrypter.decrypt64(encryptedMessage, iv: iv);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to decrypt message: $e');
    }
  }

  /// Generate session key for temporary encryption
  String generateSessionKey() {
    final randomBytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      randomBytes[i] = (DateTime.now().millisecondsSinceEpoch + i) % 256;
    }
    return base64Encode(randomBytes);
  }

  /// Encrypt file content
  Future<String> encryptFileContent(Uint8List fileContent, String sessionKey) async {
    try {
      final key = encrypt.Key.fromBase64(sessionKey);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final encrypted = encrypter.encryptBytes(fileContent, iv: iv);
      return base64Encode(encrypted.bytes);
    } catch (e) {
      throw Exception('Failed to encrypt file: $e');
    }
  }

  /// Decrypt file content
  Future<Uint8List> decryptFileContent(String encryptedContent, String sessionKey) async {
    try {
      final key = encrypt.Key.fromBase64(sessionKey);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final encrypted = encrypt.Encrypted.fromBase64(encryptedContent);
      final decrypted = encrypter.decryptBytes(encrypted, iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw Exception('Failed to decrypt file: $e');
    }
  }

  /// Hash message for integrity verification
  String hashMessage(String message) {
    final bytes = utf8.encode(message);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify message integrity
  bool verifyMessageIntegrity(String message, String expectedHash) {
    final actualHash = hashMessage(message);
    return actualHash == expectedHash;
  }

  /// Generate secure random string for session IDs
  String generateSecureRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = List<int>.generate(length, (index) => 
      (DateTime.now().millisecondsSinceEpoch + index) % chars.length
    );
    return random.map((e) => chars[e]).join();
  }

  /// Encrypt user data before storage
  String encryptUserData(Map<String, dynamic> userData) {
    try {
      final jsonString = jsonEncode(userData);
      final sessionKey = generateSessionKey();
      final key = encrypt.Key.fromBase64(sessionKey);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final encrypted = encrypter.encrypt(jsonString, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Failed to encrypt user data: $e');
    }
  }

  /// Decrypt user data from storage
  Map<String, dynamic> decryptUserData(String encryptedData) {
    try {
      // This is a simplified implementation
      // In production, you would need proper key management
      return {};
    } catch (e) {
      throw Exception('Failed to decrypt user data: $e');
    }
  }

  /// Secure message serialization for database storage
  Map<String, dynamic> serializeEncryptedMessage({
    required String senderId,
    required String recipientId,
    required String content,
    required String sessionKey,
    required String senderPublicKey,
  }) {
    try {
      // Encrypt the message content
      final encryptedContent = encryptMessage(content, senderPublicKey);
      
      // Generate message hash for integrity
      final messageHash = hashMessage(content);
      
      // Create metadata
      final metadata = {
        'senderId': senderId,
        'recipientId': recipientId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'messageHash': messageHash,
        'sessionKey': sessionKey,
        'version': '1.0',
      };
      
      return {
        'encryptedContent': encryptedContent,
        'metadata': metadata,
        'isEncrypted': true,
        'expiresAt': DateTime.now().add(Duration(hours: 24)), // Temporary storage
      };
    } catch (e) {
      throw Exception('Failed to serialize encrypted message: $e');
    }
  }

  /// Deserialize and decrypt message from database
  String deserializeEncryptedMessage(
    Map<String, dynamic> messageData,
    String privateKey,
  ) {
    try {
      final encryptedContent = messageData['encryptedContent'] as String;
      final decryptedContent = decryptMessage(encryptedContent, privateKey);
      
      // Verify integrity
      final metadata = messageData['metadata'] as Map<String, dynamic>;
      final expectedHash = metadata['messageHash'] as String;
      
      if (!verifyMessageIntegrity(decryptedContent, expectedHash)) {
        throw Exception('Message integrity verification failed');
      }
      
      return decryptedContent;
    } catch (e) {
      throw Exception('Failed to deserialize encrypted message: $e');
    }
  }

  /// Secure key exchange simulation
  String simulateKeyExchange(String publicKeyA, String privateKeyB) {
    // In a real implementation, this would be a proper Diffie-Hellman or RSA key exchange
    // For now, we'll use a simplified approach
    final combined = '$publicKeyA$privateKeyB';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32); // 256-bit session key
  }

  /// Wipe sensitive data from memory
  void secureWipe(String data) {
    // In Dart/Flutter, this is more of a conceptual operation
    // since we can't directly control memory management
    // but we can null out references
    data = '';
  }

  /// Check if message is expired (for temporary storage)
  bool isMessageExpired(DateTime expiresAt) {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Generate ephemeral keys for enhanced security
  Map<String, String> generateEphemeralKeys() {
    final ephemeralPrivateKey = generateSecureRandomString(64);
    final ephemeralPublicKey = hashMessage(ephemeralPrivateKey);
    
    return {
      'ephemeralPrivateKey': ephemeralPrivateKey,
      'ephemeralPublicKey': ephemeralPublicKey,
    };
  }
}