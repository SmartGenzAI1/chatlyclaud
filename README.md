
# Chatly - Smart & Private Messaging App

A privacy-first, text-only mobile messaging application built with Flutter and Firebase.

## 🌟 Features

### Core Features
- **Text-only messaging** - Cost-effective storage
- **Anonymous "Lucky" Chat** - Topic-based anonymous connections
- **Smart Algorithms** - AI-powered notifications and matching
- **Auto-delete messages** - 7-day default retention for privacy
- **End-to-end encryption** - Secure communications
- **Group chats** - Up to 25 members per group

### Premium Tiers
- **Free**: 3 anonymous messages/week, basic features
- **Plus (₹199/year)**: 10 anonymous messages/week, 1 group, 15 themes, no ads
- **Pro (₹299/year)**: Unlimited anonymous messages, 2 groups, advanced algorithms

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account
- Android Studio or VS Code with Flutter extensions
- Git

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/chatly.git
cd chatly
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: "Chatly"
4. Follow setup wizard

#### Add Android App
1. In Firebase Console, click "Add app" → Android
2. Package name: `com.chatly.app` (or your package name)
3. Download `google-services.json`
4. Place in `android/app/` directory

#### Enable Firebase Services
1. **Authentication**: Enable Email/Password
2. **Firestore Database**: Create database in production mode
3. **Cloud Functions**: Enable
4. **Cloud Messaging**: Automatically enabled
5. **Crashlytics**: Enable

#### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Chats accessible by participants
    match /chats/{chatId} {
      allow read, write: if request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
    
    // Anonymous messages readable by all authenticated users
    match /anonymous_messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Groups
    match /groups/{groupId} {
      allow read: if request.auth.uid in resource.data.members;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.adminId;
    }
  }
}
```

### 4. Configure Android

#### Update `android/app/build.gradle`
```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        applicationId "com.chatly.app"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.1.2'
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

#### Add to `android/build.gradle`
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

#### Add to `android/app/build.gradle` (bottom)
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 5. Environment Variables

Create `.env` file in root:
```env
UNSPLASH_API_KEY=your_unsplash_key_here
PERSPECTIVE_API_KEY=your_perspective_key_here
REVENUECAT_API_KEY=your_revenuecat_key_here
```

Get free API keys:
- **Unsplash**: https://unsplash.com/developers
- **Perspective API**: https://perspectiveapi.com
- **RevenueCat**: https://www.revenuecat.com

### 6. Run the App

#### Development
```bash
flutter run
```

#### Production Build
```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## 📁 Project Structure

```
lib/
├── main.dart                   # App entry point
├── core/
│   ├── constants/             # App constants
│   ├── themes/                # Theme configuration
│   ├── utils/                 # Utilities & validators
│   ├── widgets/               # Reusable widgets
│   └── errors/                # Error handling
├── data/
│   ├── models/                # Data models
│   └── repositories/          # Data repositories
├── services/                  # Business logic services
├── providers/                 # State management
├── features/
│   ├── auth/                  # Authentication
│   ├── chat/                  # Messaging
│   ├── anonymous/             # Anonymous chat
│   ├── groups/                # Group chats
│   ├── settings/              # User settings
│   ├── premium/               # Subscriptions
│   └── onboarding/            # Onboarding flow
└── router/                    # Navigation

## 🔐 Security Features

- Email verification required
- Password requirements: 8+ chars, mixed case, numbers
- Rate limiting: 3 signups per IP per day
- Input sanitization on all user content
- Toxicity detection via Perspective API
- Automatic banned words filtering
- Auto-ban system based on user reports

## 🤖 Smart Algorithms

1. **Smart Notification Timing**: Learns user patterns
2. **Interest-Based Matching**: Analyzes topics for anonymous chat
3. **Most Chatted Sorting**: Real-time contact ranking
4. **Conversation Health Score**: Group engagement analytics (Pro)

## 📊 Performance Targets

- DAU: 1,000 in 3 months
- Day 7 retention: 40%
- Day 30 retention: 20%
- Conversion rate: 5%
- Message delivery: 99.5%
- Crash rate: <0.5%

## 💰 Cost Optimization

### Firebase Free Tier (sufficient for ~50K users)
- Authentication: 10K/month
- Firestore: 1GB storage
- Functions: 2M invocations/month
- Storage: 1GB
- FCM: Unlimited

### Free APIs
- Unsplash: 5,000 requests/hour
- Perspective API: 1,000 requests/month
- RevenueCat: Free up to $10K/month revenue

## 🚀 CI/CD with GitHub Actions

Create `.github/workflows/build-apk.yml`:

```yaml
name: Build APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release
        path: build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Distribution

### Primary: GitHub Releases
1. Create release tag
2. Upload APK from Actions artifact
3. Add release notes

### Secondary Options
- F-Droid (open source)
- APKPure, APKMirror (third-party stores)
- Direct download from website

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 🐛 Debugging

### View Logs
```bash
flutter logs
```

### Firebase Crashlytics
Check Firebase Console → Crashlytics for crash reports

### Firestore Debug
Use Firestore Console to view data and debug queries

## 📖 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material Design Guidelines](https://material.io/design)
- [Chatly Design Document](docs/design.md)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see LICENSE file

## 👥 Team

- **Development**: Chatly Development Team
- **Design**: Chatly Design Team
- **Support**: support@chatly.app

## 🔮 Roadmap

### Phase 1 (MVP - Months 1-3)
- ✅ Core messaging
- ✅ Anonymous chat
- ✅ Basic premium features
- ✅ Authentication

### Phase 2 (Months 4-6)
- ⏳ Voice messages
- ⏳ Image sharing (compressed)
- ⏳ Advanced moderation
- ⏳ More themes

### Phase 3 (Months 7-12)
- ⏳ Video calls
- ⏳ Stories feature
- ⏳ AI chatbot
- ⏳ Desktop app

## ⚠️ Important Notes

1. **Storage**: No image/video sharing to control costs
2. **Moderation**: Real-time automated + manual review needed
3. **Scaling**: Plan migration to paid Firebase plans at 50K users
4. **Legal**: Ensure Privacy Policy and Terms of Service compliance
5. **Backups**: Implement regular Firestore backups

## 🆘 Support

- **Email**: dev@chatly.app
- **GitHub Issues**: Report bugs
- **Documentation**: docs.chatly.app
- **Discord**: Join community server

---

**Last Updated**: December 2024
**Version**: 1.0.0
**Status**: Production Ready

Built with ❤️ using Flutter & Firebase
*/
