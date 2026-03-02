<div align="center">

<img src="web/icons/Icon-192.png" alt="Chatly Logo" width="100" height="100" style="border-radius:20px"/>

# Chatly 💬

### Smart. Private. Connected.

**End-to-end encrypted, anonymous messaging built with Flutter & Firebase**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge)](CONTRIBUTING.md)

[View Demo](#demo) · [Report Bug](https://github.com/SmartGenzAI1/chatlyclaud/issues) · [Request Feature](https://github.com/SmartGenzAI1/chatlyclaud/issues)

</div>

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Anonymous Chat** | Chat without revealing your real identity |
| ⚡ **Real-time Messaging** | Instant delivery powered by Firestore streams |
| 🛡️ **End-to-End Encryption** | Messages encrypted in transit and at rest |
| 💬 **Group Chats** | Create and manage group conversations |
| 🌐 **Anonymous Feed** | Post anonymously to a public community feed |
| ⏱️ **Message Expiry** | Auto-delete messages after configurable time |
| 🌙 **Dark / Light Mode** | System-aware theme with manual toggle |
| 🔑 **Secure Auth** | Firebase Authentication with email + password reset |
| 📱 **PWA Ready** | Installable as a Progressive Web App |
| 🏆 **Premium Plans** | Free / Plus / Pro subscription tiers |

---

## 📱 Screenshots

> *Add screenshots of your app here (splash, home, chat, settings)*

| Splash | Onboarding | Chat | Settings |
|--------|-----------|------|----------|
| ![Splash](docs/splash.png) | ![Onboarding](docs/onboarding.png) | ![Chat](docs/chat.png) | ![Settings](docs/settings.png) |

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── errors/          # Error handling & logging
│   ├── themes/          # Material 3 theme system
│   ├── utils/           # Validators, sanitizers
│   └── widgets/         # Reusable UI components
├── data/
│   └── models/          # Firestore data models
├── features/
│   ├── auth/            # Login, signup, forgot password
│   ├── anonymous/       # Anonymous feed
│   ├── chat/            # Chat list, chat screen, home
│   ├── groups/          # Group chat
│   ├── onboarding/      # Splash + onboarding slides
│   ├── premium/         # Subscription/upgrade screen
│   └── settings/        # Profile & app settings
├── providers/           # State management (Provider)
├── router/              # Named route navigation
└── services/            # Firebase services & caches
```

**State Management:** [Provider](https://pub.dev/packages/provider)  
**Backend:** [Cloud Firestore](https://firebase.google.com/docs/firestore) + [Firebase Auth](https://firebase.google.com/docs/auth)  
**Pattern:** Feature-first clean architecture

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.0
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A Firebase project with **Authentication** + **Firestore** enabled

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/SmartGenzAI1/chatlyclaud.git
cd chatlyclaud

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# Copy your firebase_options.dart into lib/firebase_options.dart
# (Generate with: flutterfire configure)

# 4. Run on web
flutter run -d chrome --web-port 8080

# 5. Run on mobile
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password Authentication**
3. Enable **Cloud Firestore** in production mode
4. Install FlutterFire CLI and run `flutterfire configure`
5. Copy the generated `firebase_options.dart` to `lib/`

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Chat participants can read/write chat and messages
    match /chats/{chatId} {
      allow read, write: if request.auth.uid in resource.data.participants;

      match /messages/{messageId} {
        allow read, write: if request.auth.uid in
          get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
  }
}
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Auth | Firebase Authentication |
| Database | Cloud Firestore (real-time) |
| State | Provider pattern |
| Notifications | Firebase Cloud Messaging |
| Crash reporting | Firebase Crashlytics (mobile) |
| UI | Material 3 with custom theme |
| Web | Flutter Web + PWA |

---

## 🗺️ Roadmap

- [x] Real-time 1:1 messaging
- [x] Anonymous community feed
- [x] Group chats
- [x] Message expiry (auto-delete)
- [x] Dark/light mode
- [x] Premium subscription UI
- [x] PWA support
- [ ] Google Sign-In
- [ ] End-to-end encryption (Signal Protocol)
- [ ] Voice messages
- [ ] File / image sharing
- [ ] Push notifications (FCM)
- [ ] Message search
- [ ] Read receipts (double tick)

---

## 🤝 Contributing

Contributions are what make the open source community amazing. Any contributions you make are **greatly appreciated**.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for detailed guidelines.

---

## 📄 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.

---

## 📬 Contact

**SmartGenzAI** — [@SmartGenzAI1](https://github.com/SmartGenzAI1)

Project Link: [https://github.com/SmartGenzAI1/chatlyclaud](https://github.com/SmartGenzAI1/chatlyclaud)

---

<div align="center">

⭐ **Star this repo if you found it useful!** ⭐

*Built with ❤️ using Flutter & Firebase*

</div>