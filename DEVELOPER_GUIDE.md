# Developer Guide — Chatly

## Project Overview

Chatly is a Flutter chat application with client-side encryption. It uses Firebase for authentication and real-time data storage, with AES-256-GCM encryption applied to messages before they leave the device.

## Encryption Architecture

### How It Works

1. **Key Generation**: A random 256-bit session key is generated per conversation
2. **Encryption**: Messages are encrypted with AES-256-GCM before being sent to Firestore
3. **Storage**: Only ciphertext is stored in Firestore (`isEncrypted: true`)
4. **Decryption**: Messages are decrypted on the receiving device using the shared session key

### Key Files

| File | Purpose |
|---|---|
| `lib/services/encryption_service.dart` | AES-256-GCM, RSA key pairs, PBKDF2, HMAC |
| `lib/services/chat_service.dart` | Message sending with encryption pipeline |
| `lib/providers/chat_provider.dart` | State management with decryption access |

### Message Flow

```
User types → Sanitize → Encrypt with session key → Write to Firestore
                                                          ↓
User reads ← Decrypt with session key ← Read from Firestore
```

## Setup (First Time)

```bash
# 1. Install dependencies
flutter pub get

# 2. Configure Firebase
cp .env.example .env
# Edit .env with your Firebase project credentials

# 3. Run the app
flutter run -d chrome
```

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/chat_service_test.dart

# Run with coverage
flutter test --coverage
```

## Code Quality

```bash
# Analyze for issues
flutter analyze

# Format code
dart format lib/ test/
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase config (from env vars)
├── core/                     # Shared core code
│   ├── config/               # Env config
│   ├── constants/            # App constants
│   ├── errors/               # Error handling
│   ├── themes/               # Material 3 themes
│   ├── utils/                # Sanitizers, validators
│   └── widgets/              # Reusable widgets
├── data/models/              # Data models
├── features/                 # Feature modules
│   ├── auth/                 # Authentication
│   ├── anonymous/            # Anonymous feed
│   ├── chat/                 # Chat messaging
│   ├── groups/               # Group chats
│   ├── onboarding/           # Onboarding flow
│   ├── premium/              # Premium plans
│   └── settings/             # User settings
├── providers/                # State management
├── router/                   # Navigation
└── services/                 # Business logic
```

## Security

- Messages are encrypted client-side before Firestore write
- Session keys are generated per conversation
- Each encryption uses a random nonce (different ciphertexts for same plaintext)
- Authentication is handled by Firebase Auth
- Input sanitization prevents XSS and injection
- `.env` is gitignored — never commit credentials

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run `flutter analyze` — no errors
5. Run `flutter test` — all passing
6. Submit a PR
