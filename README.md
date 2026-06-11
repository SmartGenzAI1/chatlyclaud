# Chatly 💬

### Private, encrypted messaging built with Flutter & Firebase

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

---

## ⚠️ Status: Beta

Chatly is an **actively developed** chat application. It works for one-to-one messaging with client-side encryption, but several features are still being built. See [ROADMAP.md](ROADMAP.md) for what's done and what's coming.

---

## ✨ Current Features

| Feature | Status | Notes |
|---|---|---|
| 🔐 **Client-side Encryption** | ✅ Done | AES-256-GCM per message |
| ⚡ **Real-time Messaging** | ✅ Done | Firestore streams |
| 🔑 **Email/Password Auth** | ✅ Done | Firebase Auth |
| 🌙 **Dark / Light Mode** | ✅ Done | Material 3 theming |
| 📱 **PWA Support** | ✅ Done | Installable web app |
| ⏱️ **Message Expiry** | ✅ Done | Configurable auto-delete |
| 💬 **1-to-1 Chat** | ✅ Done | Real-time with encryption |
| 🌐 **Anonymous Feed** | 🚧 Beta | Public community feed |
| 👥 **Group Chats** | 🚧 Beta | Basic group support |
| 🏆 **Premium Plans** | 🚧 UI Only | Payment integration pending |
| 🔵 **Google Sign-In** | ❌ TODO | Coming soon |
| 🎤 **Voice Messages** | ❌ TODO | Planned |
| 📎 **File Sharing** | ❌ TODO | Planned |

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── config/         # Environment configuration
│   ├── constants/      # App-wide constants
│   ├── errors/         # Error handling
│   ├── themes/         # Material 3 theme system
│   ├── utils/          # Validators, sanitizers
│   └── widgets/        # Reusable UI components
├── data/
│   └── models/         # Firestore data models
├── features/
│   ├── auth/           # Login, signup, password reset
│   ├── anonymous/      # Anonymous feed
│   ├── chat/           # Chat list, chat screen, home
│   ├── groups/         # Group chat
│   ├── onboarding/     # Splash + onboarding
│   ├── premium/        # Subscription UI
│   └── settings/       # Profile & app settings
├── providers/          # State management (Provider)
├── router/             # Named route navigation
└── services/           # Auth, chat, encryption, notifications
```

**State Management:** Provider  
**Backend:** Cloud Firestore + Firebase Auth  
**Pattern:** Feature-first clean architecture

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.0
- A Firebase project with **Authentication** + **Firestore** enabled

### Setup

```bash
# 1. Clone
git clone https://github.com/SmartGenzAI1/chatlyclaud.git
cd chatlyclaud

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# Copy .env.example to .env and fill in your Firebase credentials:
cp .env.example .env
# Edit .env with your Firebase project values

# 4. Run on web
flutter run -d chrome --web-port 8080

# 5. Run on mobile
flutter run
```

### Firebase Setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password Authentication**
3. Enable **Cloud Firestore**
4. Copy your Firebase config values into `.env`

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Encryption | AES-256-GCM (client-side) |
| State | Provider pattern |
| UI | Material 3 |

---

## 📄 License

MIT License. See [`LICENSE`](LICENSE).

---

## 🤝 Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

*Built with Flutter & Firebase*
