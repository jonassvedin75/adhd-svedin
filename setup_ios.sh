#!/bin/bash

# iOS-utvecklingsskript för ADHD-appen
# Kör detta skript när Xcode är installerat

echo "🚀 Förbereder iOS-utvecklingsmiljö för ADHD-appen..."

# Kontrollera Xcode-installation
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode är inte installerat eller inte konfigurerat korrekt"
    echo "📥 Vänta tills Xcode-nedladdningen är klar och kör sedan:"
    echo "   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo "   sudo xcodebuild -runFirstLaunch"
    exit 1
fi

echo "✅ Xcode hittades"

# Kontrollera Xcode-licens
if ! xcodebuild -checkFirstLaunchStatus &> /dev/null; then
    echo "📋 Accepterar Xcode-licens..."
    sudo xcodebuild -license accept
    sudo xcodebuild -runFirstLaunch
fi

# Konfigurera iOS-simulatorer
echo "📱 Installerar iOS-simulatorer..."
xcrun simctl list runtimes

# Installera iOS dependencies
echo "📦 Installerar iOS dependencies..."
cd ios
pod install
cd ..

# Kontrollera Flutter iOS-status
echo "🔍 Kontrollerar Flutter iOS-status..."
flutter doctor

# Visa tillgängliga iOS-simulatorer
echo "📱 Tillgängliga iOS-simulatorer:"
flutter emulators

echo "✅ iOS-miljö redo för utveckling!"
echo ""
echo "🎯 Nästa steg:"
echo "1. Starta iOS-simulator: flutter emulators --launch <simulator_id>"
echo "2. Kör appen: flutter run -d ios"
echo "3. Eller bygg för iOS: flutter build ios"
