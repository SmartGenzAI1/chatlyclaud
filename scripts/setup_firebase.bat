@echo off
REM Chatly Firebase Setup Script for Windows
REM This script helps configure Firebase for the Chatly app

echo 🚀 Setting up Firebase for Chatly App
echo ======================================

REM Check if Firebase CLI is installed
where firebase >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Firebase CLI not found. Please install it first:
    echo    npm install -g firebase-tools
    pause
    exit /b 1
)

echo ✅ Firebase CLI found

REM Login to Firebase
echo 📝 Logging in to Firebase...
firebase login

REM Initialize Firebase project
echo 🏗️  Initializing Firebase project...
firebase init

REM Initialize Firestore
echo 🗄️  Initializing Firestore...
firebase init firestore

REM Initialize Storage
echo 💾 Initializing Storage...
firebase init storage

REM Initialize Hosting
echo 🌐 Initializing Hosting...
firebase init hosting

REM Initialize Functions
echo ⚡ Initializing Functions...
firebase init functions

REM Deploy security rules
echo 🔒 Deploying security rules...
firebase deploy --only firestore:rules

REM Deploy storage rules
echo 🔒 Deploying storage rules...
firebase deploy --only storage:rules

REM Deploy hosting
echo 🌐 Deploying to hosting...
firebase deploy --only hosting

echo.
echo ✅ Firebase setup complete!
echo.
echo 📋 Next steps:
echo 1. Update your Firebase config in lib/core/constants/app_constants.dart
echo 2. Set up environment variables in .env file
echo 3. Configure custom domain if needed
echo 4. Test your deployment
echo.
echo 🔗 Your app will be available at:
echo    https://your-project-id.web.app
echo.
echo 🎯 Happy coding with Chatly! 🚀

pause