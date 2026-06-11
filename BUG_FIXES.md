# Bug Tracking — Chatly

## Fixed ✅

- [x] `.env` committed to public repo — scrubbed from git history
- [x] `firebase_options.dart` missing — created template using env vars
- [x] Encryption not wired in — AES-256-GCM now applied in `chat_service.dart`
- [x] `dart:io` import breaking web — removed from `security_audit.dart`
- [x] SQL injection patterns for NoSQL DB — removed from sanitizers
- [x] 13 dead service files — deleted
- [x] `pubspec.yaml` unused dependencies — cleaned up
- [x] Encryption claims in README now match reality
- [x] Tests rewritten to actually compile and run

## Known Issues

- [ ] Google Sign-In not implemented
- [ ] Payment processing (RevenueCat) not integrated
- [ ] Group chat needs polish
- [ ] Push notifications (FCM) not configured
- [ ] Key exchange protocol needs hardening (currently session keys stored alongside messages)
