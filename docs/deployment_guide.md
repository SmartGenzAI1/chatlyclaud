# Chatly App Deployment Guide

This guide provides comprehensive instructions for deploying your Chatly app to production, including hosting options, Firebase setup, and deployment steps.

## 🚀 Quick Start

### 1. Firebase Project Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and name it "Chatly"
3. Disable Google Analytics (for privacy-focused approach)
4. Note your project ID (e.g., `chatly-app-12345`)

#### Configure Firebase Services

**Authentication Setup:**
```bash
# In Firebase Console > Authentication > Sign-in method
# Enable these providers:
- Email/Password (Required)
- Google (Optional, for convenience)
- Anonymous (Required for anonymous mode)
```

**Firestore Database:**
```bash
# In Firebase Console > Firestore Database
# Create database in production mode
# Set security rules (see security_rules.txt)
```

**Storage:**
```bash
# In Firebase Console > Storage
# Create default bucket
# Set security rules (see storage_rules.txt)
```

**Cloud Functions:**
```bash
# Required for:
- Message encryption/decryption
- Security monitoring
- Rate limiting
- Analytics processing
```

### 2. Environment Configuration

#### Create `.env` file
```bash
# Copy from .env.example and fill in your Firebase config
API_BASE_URL=https://your-project-id.web.app
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# Optional: Analytics and monitoring
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
ENABLE_PERFORMANCE_MONITORING=true

# Security settings
ENCRYPTION_KEY=your-encryption-key-here
RATE_LIMIT_WINDOW_MS=60000
MAX_MESSAGES_PER_WINDOW=50
```

#### Update Firebase Config
Edit `lib/core/constants/app_constants.dart`:
```dart
class FirebaseConfig {
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY', 
      defaultValue: 'your-api-key-here');
  static const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN', 
      defaultValue: 'your-project-id.firebaseapp.com');
  // ... other config
}
```

### 3. Hosting Options

## 🌐 Web Hosting Options

### Option 1: Firebase Hosting (Recommended)

**Pros:**
- Free tier available
- Automatic SSL certificates
- Global CDN
- Easy Firebase integration
- Custom domain support

**Setup:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize hosting
firebase init hosting

# Configure build process
# Set public directory to 'build/web'
# Configure single-page app (SPA) rewrite
```

**firebase.json:**
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

**Deploy:**
```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Option 2: Vercel

**Pros:**
- Excellent performance
- Easy CI/CD
- Free tier available
- Custom domains

**Setup:**
1. Create account at [Vercel](https://vercel.com/)
2. Connect your GitHub repository
3. Configure build settings:
   - Framework: Custom
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`
   - Install Command: `flutter pub get`

### Option 3: Netlify

**Pros:**
- Simple deployment
- Free SSL
- Form handling
- Edge functions

**Setup:**
1. Create account at [Netlify](https://netlify.com/)
2. Connect GitHub repository
3. Configure build settings:
   - Build Command: `flutter build web --release`
   - Publish Directory: `build/web`

### Option 4: AWS Amplify

**Pros:**
- Enterprise-grade
- Custom domains
- Advanced features
- Pay-as-you-go

**Setup:**
1. Create AWS account
2. Go to AWS Amplify Console
3. Connect repository and configure build settings

## 📱 Mobile App Distribution

### iOS App Store

**Requirements:**
- Apple Developer Account ($99/year)
- iOS device for testing
- App Store Connect account

**Steps:**
1. Create App Store Connect app
2. Generate certificates and provisioning profiles
3. Update bundle identifier in `ios/Runner/Info.plist`
4. Build iOS app:
   ```bash
   flutter build ios --release
   ```
5. Upload via Xcode or Application Loader
6. Submit for review

### Google Play Store

**Requirements:**
- Google Play Console account ($25 one-time)
- Signed APK/AAB

**Steps:**
1. Create Google Play Console account
2. Generate signing key:
   ```bash
   keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```
3. Configure signing in `android/app/build.gradle`
4. Build release APK/AAB:
   ```bash
   flutter build appbundle --release
   ```
5. Upload to Google Play Console
6. Configure store listing and submit

## 🔧 Additional Setup

### Custom Domain

**Firebase Hosting:**
```bash
# Add custom domain in Firebase Console
# Verify domain ownership
# Configure DNS settings
```

**SSL Certificate:**
- Firebase: Automatic
- Vercel/Netlify: Automatic
- Self-hosted: Use Let's Encrypt

### Environment Variables

**For Production:**
```bash
# Set environment variables in your hosting platform
FIREBASE_API_KEY=your-production-api-key
FIREBASE_PROJECT_ID=your-production-project
# ... other variables
```

### Security Considerations

**HTTPS Only:**
- Ensure all hosting uses HTTPS
- Update API endpoints to use HTTPS
- Configure CORS properly

**Security Headers:**
- Already configured in `web/security_headers.js`
- Verify headers are applied in production

**Firebase Security Rules:**
- Deploy security rules to production
- Test rules thoroughly
- Monitor for security issues

## 📊 Monitoring & Analytics

### Firebase Analytics
```bash
# Enable in Firebase Console
# Configure privacy settings
# Set up custom events
```

### Performance Monitoring
```bash
# Enable Firebase Performance Monitoring
# Set up custom traces
# Monitor app performance
```

### Error Tracking
```bash
# Enable Firebase Crashlytics
# Configure error reporting
# Set up alerts
```

## 🔄 CI/CD Setup

### GitHub Actions

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy Chatly

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
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.0'
        
    - name: Get dependencies
      run: flutter pub get
      
    - name: Run tests
      run: flutter test
      
    - name: Build web
      run: flutter build web --release
      
    - name: Deploy to Firebase
      uses: w9jdtj/action-firebase-hosting@v1.4.0
      with:
        args: '--only hosting'
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

### Environment Secrets
Add to GitHub repository secrets:
- `FIREBASE_TOKEN`: Firebase CLI token
- `FIREBASE_PROJECT_ID`: Your Firebase project ID

## 🚀 Launch Checklist

### Pre-Launch
- [ ] Firebase project configured
- [ ] Security rules deployed
- [ ] Custom domain configured
- [ ] SSL certificates active
- [ ] Environment variables set
- [ ] Analytics configured
- [ ] Error tracking enabled
- [ ] Performance monitoring setup

### Testing
- [ ] Web app functionality tested
- [ ] Mobile app builds tested
- [ ] Security rules tested
- [ ] Performance tested
- [ ] Cross-browser compatibility tested
- [ ] Mobile responsiveness tested

### Launch
- [ ] Deploy to production
- [ ] Monitor for errors
- [ ] Verify analytics tracking
- [ ] Test all core features
- [ ] Monitor performance metrics

### Post-Launch
- [ ] Monitor user feedback
- [ ] Track performance metrics
- [ ] Monitor security alerts
- [ ] Plan for scaling
- [ ] Schedule regular updates

## 💰 Cost Estimation

### Firebase Costs (Monthly)
- **Authentication**: Free up to 10K MAU
- **Firestore**: $0.06/100k reads, $0.18/100k writes
- **Storage**: $0.026/GB/month
- **Hosting**: $0.026/GB/month
- **Functions**: $0.0000004 per GB-second

### Estimated Monthly Costs
- **< 1K users**: ~$5-10/month
- **1K-10K users**: ~$20-50/month
- **10K+ users**: ~$100+/month

### Other Hosting Costs
- **Vercel**: Free-$20/month
- **Netlify**: Free-$19/month
- **AWS Amplify**: $0-50/month

## 🆘 Troubleshooting

### Common Issues
1. **CORS errors**: Check Firebase security rules
2. **Authentication failures**: Verify API keys
3. **Performance issues**: Enable caching and monitoring
4. **Deployment failures**: Check build logs

### Support Resources
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Web Docs](https://docs.flutter.dev/deployment/web)
- [Chatly GitHub Issues](https://github.com/your-repo/issues)

## 📞 Support

For deployment assistance:
- Check the [Troubleshooting Guide](./troubleshooting.md)
- Review [Firebase Documentation](https://firebase.google.com/docs)
- Join [Flutter Community](https://flutter.dev/community)

---

**Next Steps**: Choose your hosting option and follow the corresponding setup guide above. Start with Firebase Hosting for the easiest setup and best Firebase integration.