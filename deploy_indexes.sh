#!/bin/bash

# Script to deploy Firestore indexes
echo "🚀 Deploying Firestore indexes..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "🔐 Please login to Firebase first:"
    firebase login
fi

# Deploy only the indexes
echo "📦 Deploying indexes to Firebase..."
firebase deploy --only firestore:indexes

echo "✅ Index deployment completed!"
echo "⏳ Note: Index building can take 1-5 minutes. Check Firebase Console for status." 