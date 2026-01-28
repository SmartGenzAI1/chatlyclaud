#!/bin/bash

# Vercel Environment Variables Setup Script
# Run these commands in Vercel Dashboard or use Vercel CLI

# Instructions:
# 1. Go to https://vercel.com/dashboard
# 2. Select your project: web-sigma-topaz-12
# 3. Go to Settings → Environment Variables
# 4. Add each variable below for Production, Preview, and Development

echo "Setting up Vercel environment variables..."

# Firebase Configuration
vercel env add FIREBASE_API_KEY
# Value: AIzaSyD8F8O5dENFxGnYEQF0vHfb174r3TtdY4k

vercel env add FIREBASE_AUTH_DOMAIN
# Value: bubbldrop2025.firebaseapp.com

vercel env add FIREBASE_DATABASE_URL
# Value: https://bubbldrop2025-default-rtdb.asia-southeast1.firebasedatabase.app

vercel env add FIREBASE_PROJECT_ID
# Value: bubbldrop2025

vercel env add FIREBASE_STORAGE_BUCKET
# Value: bubbldrop2025.firebasestorage.app

vercel env add FIREBASE_MESSAGING_SENDER_ID
# Value: 455624929536

vercel env add FIREBASE_APP_ID
# Value: 1:455624929536:web:a5cf99597b88413fe103e5

vercel env add FIREBASE_MEASUREMENT_ID
# Value: G-4KDQMLK235

echo "Environment variables configured!"
echo "Now redeploy: vercel --prod"
