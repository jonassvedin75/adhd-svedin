# 🤖 AI-Kodhjälp Guide för ADHD Stöd-appen

## 📋 Projektöversikt

Detta är en Flutter-baserad ADHD-stödapp med följande funktioner:
- **ADHD-optimerad dashboard** med minimal kognitiv belastning
- **Universal inbox** för att fånga tankar och idéer
- **Fokustimer** med visuell feedback
- **Energinivå-tracking** och humörstämning
- **Anpassade aktiviteter** baserat på användarens energinivå
- **Firebase-integration** för datalagring

## 🚀 Startinstruktioner

### Webbversion (Rekommenderad för utveckling)
```bash
# 1. Navigera till projektmappen
cd /Users/jonassvedin/ADHD-svedin/adhd-svedin

# 2. Hämta dependencies
flutter pub get

# 3. Starta webbversionen
flutter run -d chrome --web-port 8080
```

**Resultat:** Appen körs på `http://localhost:8080`

### iOS Simulator (Kräver speciell konfiguration)

**Förutsättningar:**
- Xcode installerat lokalt (finns i projektet under `Xcode.app/`)
- Developer path konfigurerat

```bash
# 1. Sätt DEVELOPER_DIR för lokal Xcode
export DEVELOPER_DIR="/Users/jonassvedin/ADHD-svedin/adhd-svedin/Xcode.app/Contents/Developer"

# 2. Kontrollera tillgängliga enheter
flutter devices

# 3. Öppna iOS Simulator
open -a Simulator

# 4. Starta appen på iOS (när simulator syns)
flutter run -d "ADHD iPhone 15"
```

**Viktigt:** iOS-bygget kan ta 5-15 minuter första gången!

## 🔧 Felsökning

### Problem: iOS Simulator syns inte
**Lösning:**
```bash
export DEVELOPER_DIR="/Users/jonassvedin/ADHD-svedin/adhd-svedin/Xcode.app/Contents/Developer"
flutter devices
```

### Problem: iOS-bygget hänger sig
**Lösning:**
```bash
# Stoppa hängande processer
pkill -f "flutter run"

# Rensa bygget och försök igen
flutter clean
flutter pub get
```

### Problem: Firebase-anslutning misslyckas
**Kontrollera:**
- `firebase_options.dart` finns och är korrekt
- Firebase-projektet är konfigurerat
- Användaren är autentiserad

## 📱 Plattformar

### ✅ Webbversion (Primär)
- **URL:** `http://localhost:8080`
- **Status:** Fullt funktionell
- **Användning:** Utveckling och demo
- **Hot Reload:** Aktiverat

### 📱 iOS Simulator
- **Status:** Fungerar men långsam byggprocess
- **Användning:** Native iOS-testning
- **Krav:** Lokal Xcode-installation

### 🖥️ macOS Desktop
```bash
flutter run -d macos
```

## 🏗️ Projektstruktur

```
lib/
├── app/
│   ├── features/
│   │   ├── dashboard/
│   │   │   └── adhd_dashboard.dart     # Huvuddashboard
│   │   ├── auth/                       # Autentisering
│   │   ├── todo/                       # Att-göra lista
│   │   └── pomodoro/                   # Fokustimer
│   ├── shared/
│   │   └── widgets/
│   │       ├── universal_inbox.dart    # Inkorg-widget
│   │       └── visual_timer.dart       # Timer-widget
│   └── core/
│       ├── theme/                      # App-tema
│       └── responsive/                 # Responsiv layout
```

## 🎯 Viktiga Funktioner

### 1. Universal Inbox
- Fånga tankar, idéer och uppgifter
- Taggar för kategorisering
- Firebase-synkronisering

### 2. Energinivå-tracking
- 1-10 skala för energinivå
- Humörsindikatorer
- Anpassade aktivitetsförslag

### 3. Fokustimer
- Expanderbar timer-widget
- Visuell feedback
- Notifikationer vid slutförande

### 4. Responsiv Design
- Mobil, tablet och desktop-layout
- iOS-optimerade komponenter
- Tillgänglighetsanpassat

## 🔥 Firebase Deployment

```bash
# Bygg för produktion
flutter build web --release

# Deploy till Firebase Hosting
firebase deploy
```

## 🛠️ Development Tips

### Hot Reload
- **Webb:** Automatiskt vid filändringar
- **iOS:** Tryck `r` i terminalen

### Debug-läge
- Använd Chrome DevTools för webb
- VS Code Flutter extension för debug

### Performance
- Webbversion: Snabb utveckling
- iOS: Långsammare men native känsla

## 📝 Vanliga Kommandon

```bash
# Rensa allt och starta om
flutter clean && flutter pub get

# Kontrollera hälsa
flutter doctor

# Lista enheter
flutter devices

# Bygg för release
flutter build web --release
flutter build ios --release

# Kör tester
flutter test
```

## 🚨 Viktiga Noter för AI-assistenter

1. **Använd alltid webbversionen** för snabb utveckling och demo
2. **iOS kräver speciell setup** - använd export DEVELOPER_DIR först
3. **Första iOS-bygget tar lång tid** - var tålmodig eller använd webb
4. **Firebase är redan konfigurerat** - inga extra steg behövs
5. **Appen är optimerad för ADHD-användare** - håll interface enkelt

## 🎨 UI/UX Principer

- **Minimal kognitiv belastning**
- **Stora, lätta att träffa knappar**
- **Lugna färger och animationer**
- **Konsekvent navigation**
- **Snabb åtkomst till huvudfunktioner**

## 📞 Support

Vid problem:
1. Kontrollera denne guide först
2. Kör `flutter doctor` för systemhälsa
3. Använd webbversionen som fallback
4. Kontrollera Firebase Console för backend-problem
