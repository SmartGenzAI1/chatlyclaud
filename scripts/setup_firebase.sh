#!/bin/bash

# Chatly Firebase Setup Script
# This script helps configure Firebase for the Chatly app

echo "🚀 Setting up Firebase for Chatly App"
echo "======================================"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI found"

# Login to Firebase
echo "📝 Logging in to Firebase..."
firebase login

# Initialize Firebase project
echo "🏗️  Initializing Firebase project..."
firebase init

# Initialize Firestore
echo "🗄️  Initializing Firestore..."
firebase init firestore

# Initialize Storage
echo "💾 Initializing Storage..."
firebase init storage

# Initialize Hosting
echo "🌐 Initializing Hosting..."
firebase init hosting

# Initialize Functions
echo "⚡ Initializing Functions..."
firebase init functions

# Deploy security rules
echo "🔒 Deploying security rules..."
firebase deploy --only firestore:rules

# Deploy storage rules
echo "🔒 Deploying storage rules..."
firebase deploy --only storage:rules

# Deploy hosting
echo "🌐 Deploying to hosting..."
firebase deploy --only hosting

echo ""
echo "✅ Firebase setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Update your Firebase config in lib/core/constants/app_constants.dart"
echo "2. Set up environment variables in .env file"
echo "3. Configure custom domain if needed"
echo "4. Test your deployment"
echo ""
echo "🔗 Your app will be available at:"
echo "   https://your-project-id.web.app"
echo ""
echo "🎯 Happy coding with Chatly! 🚀"