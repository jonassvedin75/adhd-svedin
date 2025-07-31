# ADHD Stöd - Produktionsguide

## 🚀 Produktionsdeployment

### Förutsättningar
- Flutter 3.32.8 eller senare
- Firebase CLI installerat och konfigurerat
- Chrome för webbtestning

### Snabb deployment

```bash
# 1. Kör produktionsbyggnadsskriptet
./build_production.sh

# 2. Deploy till Firebase Hosting
firebase deploy
```

### Manuell deployment

```bash
# 1. Rensa och hämta dependencies
flutter clean
flutter pub get

# 2. Kör tester och analys
flutter analyze
flutter test

# 3. Bygg för produktion
flutter build web --release --web-renderer canvaskit

# 4. Deploy
firebase deploy
```

## 🔧 Konfiguration

### Firebase Setup
1. Säkerställ att Firebase-projektet är konfigurerat
2. Kontrollera att Firestore Security Rules är deployade:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Environment Variables
Appen använder Firebase-konfiguration från `firebase_options.dart` som genereras automatiskt.

## 🛡️ Säkerhet

### Implementerade säkerhetsåtgärder:
- ✅ Firebase Security Rules för alla samlingar
- ✅ Användarautentisering krävs för all data
- ✅ Input-sanering för användardata
- ✅ Error handling för produktion
- ✅ Lösenordsstyrkevalidering

### Security Rules
Firestore-regler finns i `firestore.rules` och säkerställer att:
- Användare bara kan läsa/skriva sina egna data
- All åtkomst kräver autentisering
- Obehörig åtkomst blockeras

## 📊 Prestanda

### Optimeringar:
- ✅ Tree-shaking för mindre bundle-storlek
- ✅ Code-splitting med lazy loading
- ✅ Optimerade webbresurser
- ✅ Caching av statiska tillgångar
- ✅ PWA-stöd för offlineanvändning

### Prestandamätning
```bash
# Analysera bundle-storlek
flutter build web --analyze-size

# DevTools för prestanda
flutter run -d chrome --web-port 8080
# Öppna sedan DevTools för analys
```

## 🧪 Testning

### Köra tester
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (om implementerade)
flutter drive --target=test_driver/app.dart
```

## 📱 PWA-funktioner

Appen är konfigurerad som en Progressive Web App med:
- Offline-stöd
- Installationsbar på mobila enheter
- Push-notifikationer (kan implementeras)
- App-liknande upplevelse

## 🔍 Övervakning

### Logs och felsökning
- Produktionsloggar filtreras för säkerhet
- Fel rapporteras till Firebase Crashlytics (kan aktiveras)
- Användaraktiviteter loggas för analys

### Firebase Console
Använd Firebase Console för att övervaka:
- Användaraktivitet
- Prestanda
- Fel och crashes
- Säkerhetsregler

## 📋 Checklista före produktion

- [ ] Alla tester passerar
- [ ] Firebase Security Rules är deployade
- [ ] Web-metadata är korrekt konfigurerad
- [ ] PWA-manifest är uppdaterat
- [ ] Produktionsbyggnad fungerar lokalt
- [ ] SSL/HTTPS är konfigurerat
- [ ] Error handling är testat
- [ ] Backup-strategier är på plats

## 🆘 Felsökning

### Vanliga problem:
1. **Firebase-anslutning misslyckas**: Kontrollera `firebase_options.dart`
2. **Security Rules blockerar åtkomst**: Verifiera användarautentisering
3. **Långsam laddning**: Analysera bundle-storlek
4. **PWA installeras inte**: Kontrollera manifest.json

### Support
- Loggar finns i browser developer tools
- Firebase Console för backend-problem
- Flutter DevTools för prestandaanalys

## 📄 Licens

Detta projekt är utvecklat för ADHD-stöd och följer lämpliga sekretess- och säkerhetsriktlinjer för hälsoapplikationer.
