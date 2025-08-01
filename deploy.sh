#!/bin/bash

# ADHD Stöd App - Deployment Script
echo "🚀 Starting deployment of ADHD Stöd App..."

# Build the app
echo "📦 Building app for production..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "⚠️ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Deploy to Firebase Hosting
echo "🌐 Deploying to Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    echo "🎉 Deployment successful!"
    echo "🌍 Your app is now live!"
else
    echo "❌ Deployment failed!"
    echo "💡 Alternative deployment options:"
    echo "   1. Upload build/web/ to Netlify"
    echo "   2. Upload build/web/ to Vercel"
    echo "   3. Use GitHub Pages"
fi 