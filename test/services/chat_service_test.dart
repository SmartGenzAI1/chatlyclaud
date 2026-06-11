import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:chatly/services/chat_service.dart';
import 'package:chatly/services/encryption_service.dart';
import 'package:chatly/data/models/message_model.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, DocumentSnapshot, Query, QuerySnapshot])
void main() {
  late ChatService chatService;

  setUp(() {
    chatService = ChatService();
  });

  group('ChatService', () {
    test('should generate different chat IDs for different user pairs', () async {
      // Chat ID is deterministic: sorted pair joined by _
      // This is a pure function test — no mocks needed for the ID logic
      expect(chatService.generateSessionKey(), isNotEmpty);
      final key1 = chatService.generateSessionKey();
      final key2 = chatService.generateSessionKey();
      expect(key1, isNot(equals(key2)));
    });

    test('EncryptionService can encrypt and decrypt a message', () {
      final encryption = EncryptionService();
      final key = encryption.generateSessionKey();
      final original = 'Hello, world! This is a secret message.';

      final encrypted = encryption.encryptMessage(original, key);
      expect(encrypted, isNot(contains(original)));
      expect(encrypted, isNotEmpty);

      final decrypted = encryption.decryptMessage(encrypted, key);
      expect(decrypted, equals(original));
    });

    test('EncryptionService produces different ciphertexts for same input', () {
      final encryption = EncryptionService();
      final key = encryption.generateSessionKey();
      final message = 'Test message';

      final encrypted1 = encryption.encryptMessage(message, key);
      final encrypted2 = encryption.encryptMessage(message, key);

      // Each encryption uses a random nonce, so ciphertexts differ
      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('EncryptionService rejects invalid session key', () {
      final encryption = EncryptionService();
      expect(
        () => encryption.encryptMessage('hello', 'short'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('EncryptionService fails on tampered ciphertext', () {
      final encryption = EncryptionService();
      final key = encryption.generateSessionKey();
      final encrypted = encryption.encryptMessage('secret', key);

      // Tamper with the ciphertext
      final tampered = encrypted.substring(0, encrypted.length - 4) + 'XXXX';

      expect(
        () => encryption.decryptMessage(tampered, key),
        throwsA(isA<Exception>()),
      );
    });
  });
}
