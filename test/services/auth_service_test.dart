import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:chatly/services/auth_service.dart';
import 'package:chatly/services/encryption_service.dart';

@GenerateMocks([])
void main() {
  late AuthService authService;
  late EncryptionService encryptionService;

  setUp(() {
    authService = AuthService();
    encryptionService = EncryptionService();
  });

  group('AuthService', () {
    test('should expose auth state changes stream', () {
      final stream = authService.authStateChanges;
      expect(stream, isA<Stream>());
    });

    test('currentUser is null when not authenticated', () {
      // In test environment without Firebase, currentUser should be null
      expect(authService.currentUser, isNull);
    });
  });

  group('EncryptionService + AuthService integration', () {
    test('can generate and use session keys for message encryption', () {
      final key = encryptionService.generateSessionKey();
      expect(key, isNotEmpty);

      final message = 'User authentication successful';
      final encrypted = encryptionService.encryptMessage(message, key);
      final decrypted = encryptionService.decryptMessage(encrypted, key);

      expect(decrypted, equals(message));
    });
  });
}
