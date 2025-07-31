# Produktionsbyggnadsskript för ADHD Stöd App

# 1. Rensa tidigare builds
flutter clean

# 2. Hämta dependencies
flutter pub get

# 3. Analysera kod
flutter analyze

# 4. Kör tester
flutter test

# 5. Bygg optimerad web-version
flutter build web --release --web-renderer canvaskit --dart-define=Dart2jsOptimization=O4

# 6. Optimera bundle size
# (Tree-shaking och minification sker automatiskt i release mode)

echo "✅ Produktionsbyggnad klar!"
echo "📁 Build finns i: build/web/"
echo "🚀 Deploy med: firebase deploy"
