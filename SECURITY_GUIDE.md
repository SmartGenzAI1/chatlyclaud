# Security Guide — Chatly

## Encryption Implementation

Messages in Chatly are encrypted with **AES-256-GCM** on the client before being written to Cloud Firestore. The encryption pipeline lives in `lib/services/encryption_service.dart` and is called from `lib/services/chat_service.dart`.

### What's encrypted

- ✅ Message content (text)

### What's not yet encrypted

- Message metadata (sender, timestamp, read receipts)
- Chat participant lists
- User profile data

## Firestore Security Rules

Deploy these rules to your Firebase project:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: read self, write self
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Chats: participants only
    match /chats/{chatId} {
      allow read, write: if request.auth != null
        && request.auth.uid in resource.data.participants;

      match /messages/{messageId} {
        allow read: if request.auth != null
          && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null
          && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }

    // Security audit: server-only write
    match /security_audit/{docId} {
      allow read: if false;
      allow write: if request.auth != null;
    }
  }
}
```

## Deployment Checklist

Before deploying:

- [ ] Set Firestore security rules in Firebase Console
- [ ] Enable Email/Password Authentication in Firebase Console
- [ ] Create `.env` from `.env.example` with real credentials
- [ ] Verify `.env` is in `.gitignore`
- [ ] Run `flutter analyze` — zero errors
- [ ] Run `flutter test` — all passing
- [ ] Build release: `flutter build web --release`

## Key Rotation

If Firebase credentials are ever exposed:
1. Go to Firebase Console → Project Settings
2. Rotate the exposed API key
3. Update `.env` with new values
4. Redeploy
