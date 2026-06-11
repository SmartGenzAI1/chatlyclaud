// ============================================================================
// FILE: lib/services/signal_protocol.dart
// PURPOSE: Signal Protocol-style Double Ratchet for end-to-end encryption
//          Implements DH ratchet + symmetric ratchet for PFS
// ============================================================================

import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256r1.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';

/// A simplified Signal Protocol implementation using:
/// - ECDH (P-256) for key agreement
/// - HKDF for key derivation
/// - AES-256-GCM for message encryption
/// - Double Ratchet for forward secrecy
class SignalProtocol {
  final int _maxSkip = 100; // Max skipped message keys to store

  // Ratchet state
  Uint8List? _rootKey;
  KeyPair<ECPublicKey, ECPrivateKey>? _dhPair;
  Uint8List? _sendingChainKey;
  Uint8List? _receivingChainKey;
  int _sendingIndex = 0;
  int _receivingIndex = 0;
  final Map<int, Uint8List> _skippedKeys = {};
  final Map<int, Uint8List> _messageKeys = {};

  /// Initialize a session from a shared secret (out-of-band)
  void initializeFromSharedSecret(Uint8List sharedSecret) {
    _rootKey = _hkdf(sharedSecret, Uint8List(0), 'ChatlySignalRoot', 32);
    _dhPair = _generateECKeyPair();
    _sendingChainKey = _hkdf(_rootKey!, _dhPair!.publicKey.Q!.x!.bigInt!.toRadixString(16).codeUnits.take(32).toList().let((l) => Uint8List.fromList(l)), 'ChatlySendChain', 32);
  }

  /// Generate a new DH key pair and perform a ratchet step
  RatchetStep performRatchetStep(Uint8List? remotePublicKeyBytes) {
    if (remotePublicKeyBytes != null) {
      // DH Ratchet: mix in remote public key
      final dhOutput = _ecdh(_dhPair!.privateKey!, _decodeECPublicKey(remotePublicKeyBytes));
      _rootKey = _hkdf(_rootKey!, dhOutput, 'ChatlyRootRatchet', 32);
      _sendingChainKey = _hkdf(_rootKey!, Uint8List(0), 'ChatlySendChain', 32);
      
      // Generate new DH pair
      _dhPair = _generateECKeyPair();
      
      _sendingIndex = 0;
    }
    
    // Symmetric ratchet: advance sending chain
    final messageKey = _hkdf(_sendingChainKey!, Uint8List(0), 'ChatlyMessageKey', 32);
    _sendingChainKey = _hkdf(_sendingChainKey!, Uint8List.fromList([1]), 'ChatlyNextChain', 32);
    
    final index = _sendingIndex++;
    _messageKeys[index] = messageKey;
    
    return RatchetStep(
      messageKey: messageKey,
      index: index,
      publicKey: _encodeECPublicKey(_dhPair!.publicKey!),
    );
  }

  /// Receive a message — perform receiving ratchet
  Uint8List? receiveRatchetStep(Uint8List remotePublicKeyBytes, int messageIndex) {
    // Check skipped keys first
    if (_skippedKeys.containsKey(messageIndex)) {
      final key = _skippedKeys[messageIndex]!;
      _skippedKeys.remove(messageIndex);
      return key;
    }
    
    // DH ratchet with remote key
    final remoteKey = _decodeECPublicKey(remotePublicKeyBytes);
    final dhOutput = _ecdh(_dhPair!.privateKey!, remoteKey);
    _rootKey = _hkdf(_rootKey!, dhOutput, 'ChatlyRootRatchet', 32);
    _receivingChainKey = _hkdf(_rootKey!, Uint8List(0), 'ChatlyRecvChain', 32);
    
    // Generate new DH pair
    _dhPair = _generateECKeyPair();
    _receivingIndex = 0;
    
    // Advance to the needed message key
    Uint8List messageKey = _receivingChainKey!;
    for (int i = 0; i <= messageIndex; i++) {
      messageKey = _hkdf(messageKey, Uint8List(0), 'ChatlyMessageKey', 32);
      if (i < messageIndex) {
        // Store skipped keys
        _skippedKeys[i] = messageKey;
      }
      _receivingChainKey = _hkdf(_receivingChainKey!, Uint8List.fromList([1]), 'ChatlyNextChain', 32);
    }
    
    // Cleanup old skipped keys
    if (_skippedKeys.length > _maxSkip) {
      final oldest = _skippedKeys.keys.reduce(min);
      _skippedKeys.remove(oldest);
    }
    
    return messageKey;
  }

  /// Encrypt a message with a message key
  String encryptWithKey(String plaintext, Uint8List messageKey) {
    final key = encrypt.Key(messageKey);
    final nonce = _randomBytes(12);
    final iv = encrypt.IV(nonce);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    
    final combined = Uint8List(nonce.length + encrypted.bytes.length)
      ..setAll(0, nonce)
      ..setAll(nonce.length, encrypted.bytes);
    
    return base64Encode(combined);
  }

  /// Decrypt a message with a message key
  String decryptWithKey(String ciphertext, Uint8List messageKey) {
    final combined = base64Decode(ciphertext);
    final nonce = combined.sublist(0, 12);
    final encrypted = combined.sublist(12);
    
    final key = encrypt.Key(messageKey);
    final iv = encrypt.IV(nonce);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    
    return encrypter.decrypt(encrypt.Encrypted(Uint8List.fromList(encrypted)), iv: iv);
  }

  /// Get current public key for sharing
  Uint8List getPublicKey() => _encodeECPublicKey(_dhPair!.publicKey!);

  /// Generate fresh DH keys
  KeyPair<ECPublicKey, ECPrivateKey> _generateECKeyPair() {
    final keyGen = ECKeyGenerator();
    final params = ECKeyGeneratorParameters(ECCurve_secp256r1());
    keyGen.init(ParametersWithRandom(params, _secureRandom()));
    return keyGen.generateKeyPair() as KeyPair<ECPublicKey, ECPrivateKey>;
  }

  /// ECDH key agreement
  Uint8List _ecdh(ECPrivateKey private, ECPublicKey remote) {
    final p = remote.Q!;
    final ecPoint = (p * private.d!)!;
    final x = ecPoint.x!.bigInt!.toRadixString(16).padLeft(64, '0');
    return Uint8List.fromList(sha256.convert(utf8.encode(x)).bytes);
  }

  /// HKDF implementation
  Uint8List _hkdf(Uint8List key, Uint8List salt, String info, int length) {
    final hmac = crypto.Hmac(crypto.sha256, key);
    final infoBytes = Uint8List.fromList(utf8.encode(info));
    final input = Uint8List(salt.length + infoBytes.length)
      ..setAll(0, salt)
      ..setAll(salt.length, infoBytes);
    
    final digest = hmac.convert(input);
    return Uint8List.fromList(digest.bytes.take(length).toList());
  }

  SecureRandom _secureRandom() {
    final random = Random.secure();
    return _FixedSecureRandom(random);
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }

  Uint8List _encodeECPublicKey(ECPublicKey key) {
    final x = key.Q!.x!.bigInt!.toRadixString(16).padLeft(64, '0');
    final y = key.Q!.y!.bigInt!.toRadixString(16).padLeft(64, '0');
    return Uint8List.fromList(utf8.encode('$x$y'));
  }

  ECPublicKey _decodeECPublicKey(Uint8List bytes) {
    final hex = utf8.decode(bytes);
    final x = BigInt.parse(hex.substring(0, 64), radix: 16);
    final y = BigInt.parse(hex.substring(64, 128), radix: 16);
    final curve = ECCurve_secp256r1();
    final point = curve.curve.createPoint(x, y);
    return ECPublicKey(point, ECKeyGeneratorParameters(curve));
  }
}

/// Result of a sending ratchet step
class RatchetStep {
  final Uint8List messageKey;
  final int index;
  final Uint8List publicKey;
  
  RatchetStep({required this.messageKey, required this.index, required this.publicKey});
}

/// SecureRandom that uses Dart's Random.secure()
class _FixedSecureRandom implements SecureRandom {
  final Random _random;
  _FixedSecureRandom(this._random);
  
  @override
  Uint8List nextBytes(int count) {
    return Uint8List.fromList(List.generate(count, (_) => _random.nextInt(256)));
  }
}

// Extension for cleaner chaining
extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
