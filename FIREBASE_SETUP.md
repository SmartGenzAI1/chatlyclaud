# ============================================================================
# Firebase Setup Instructions
# ============================================================================

## CRITICAL: Firebase Must Be Configured Before Running

Your app currently has placeholder Firebase configuration. Follow these steps:

## Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 2: Configure Firebase

```bash
# Navigate to project directory
cd c:\Users\HP\OneDrive\Desktop\chatlyclaud

# Run FlutterFire configuration
flutterfire configure
```

This will:
1. Connect to your Firebase project
2. Generate `lib/firebase_options.dart` with real credentials
3. Download `google-services.json` for Android
4. Download `GoogleService-Info.plist` for iOS
5. Configure web settings

## Step 3: Verify Configuration

After running `flutterfire configure`, verify these files exist:

- ✅ `lib/firebase_options.dart` (generated, not placeholder)
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist` (if using iOS)

## Step 4: Test the App

```bash
flutter run
```

The app should now start without Firebase errors.

## Troubleshooting

### "No Firebase project found"
- Create a Firebase project at: https://console.firebase.google.com
- Enable Firebase Authentication  
- Enable Cloud Firestore
- Enable Firebase Storage

### "FlutterFire CLI not found"
```bash
# Add Dart pub cache to PATH (Windows)
$env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"

# Then retry
dart pub global activate flutterfire_cli
```

### "Permission denied"
Run your terminal as Administrator and retry.

## Important Notes

1. **Never commit** `firebase_options.dart` to version control
2. It's already in `.gitignore` for security
3. Each developer needs to run `flutterfire configure` locally
4. Different environments (dev/prod) need different configurations

## Alternative: Manual Configuration

If FlutterFire CLI doesn't work, manual setup:

1. Download `google-services.json` from Firebase Console → Project Settings → Android
2. Place in `android/app/google-services.json`
3. Edit `lib/firebase_options.dart` with values from Firebase Console

## Need Help?

- FlutterFire Docs: https://firebase.flutter.dev/docs/overview
- Firebase Console: https://console.firebase.google.com
- FlutterFire CLI: https://github.com/invertase/flutterfire_cli
