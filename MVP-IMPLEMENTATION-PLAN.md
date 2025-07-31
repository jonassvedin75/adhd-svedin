# ADHD-stödsapp MVP Implementation Plan
*Forskningsbaserad implementation av kärnfunktioner*

## Översikt
Denna plan beskriver implementation av MVP (Minimum Viable Product) för ADHD-stödsappen, baserat på den forskningsdrivna funktionsanalysen och Flutter-komponentkartering.

## MVP Kärnfunktioner (Fas 1) ✅

### 1. Universal Inbox - "Externa hjärnan" ✅
**Status:** Implementerad i `/lib/app/shared/widgets/universal_inbox.dart`

**ADHD-optimering:**
- Minimal friktion: Ett textfält + knapp för snabb fångst
- Kontexttaggar: Automatisk kategorisering (uppgift, idé, anteckning, påminnelse, fråga)
- Offline-first: Sparar lokalt i Firestore för senare bearbetning
- Haptic feedback: Bekräftar actions för kinestetic learners
- Auto-expand: Visar alternativ när användaren fokuserar

**Teknisk implementation:**
- `TextField` med `autofocus` för minimal friktion
- `FilterChip` widgets för snabbkategorisering
- `AnimatedContainer` för mjuka övergångar
- Firestore integration för persistent lagring

### 2. Visual Timer - "Tidstämjaren" ✅
**Status:** Implementerad i `/lib/app/shared/widgets/visual_timer.dart`

**ADHD-optimering:**
- Lugnande design: Mjuka färger, gradients istället för alarm-röd
- Flexibla intervall: 15-45min istället för rigid 25min Pomodoro
- Visuell representation: Krympande cirkel inspirerad av TimeTock
- Taktil feedback: Haptic feedback vid milstolpar (25%, 50%, 75%)
- Minimal stress: Inga alarmerande ljud eller färger

**Teknisk implementation:**
- `CustomPainter` för cirkulär timer
- `AnimationController` för mjuka övergångar
- `TweenAnimationBuilder` för progressanimationer
- Platform-specific haptic feedback

### 3. ADHD Dashboard - "Kognitiv kontrollpanel" ✅
**Status:** Implementerad i `/lib/app/features/dashboard/adhd_dashboard.dart`

**ADHD-optimering:**
- Energimedvetenhet: Adaptiva funktioner baserat på energinivå
- Minimal kognitiv belastning: Clean design, tydlig hierarki
- Snabb överblick: Dagens fokus, senaste fångster, energistatus
- Anpassningsbar navigation: Föreslår aktiviteter baserat på energi
- Mjuka övergångar: Förebygger sensory overload

**Teknisk implementation:**
- Responsive design för mobil, tablet och desktop
- StreamBuilder för realtidsdata från Firestore
- Adaptiv logic baserat på användarens energinivå
- Integration med UniversalInbox och VisualTimer

### 4. Förbättrad Pomodoro - "Flexibel fokus" ✅
**Status:** Implementerad i `/lib/app/features/pomodoro/pomodoro_screen.dart`

**ADHD-optimering:**
- Flexibla intervall: 15, 20, 25, 30, 45 minuter
- ADHD-vänlig pausstruktur: 5-30 min pauser
- Uppgiftskontext: Vad arbetar du med?
- Visuell framsteg: Antal genomförda sessioner
- Historik: Spåra mönster och framsteg

**Teknisk implementation:**
- Integrerad med VisualTimer komponenten
- Firestore för sessionshistorik
- Flexible duration selection
- Session analytics och tracking

## Pågående development (Fas 2)

### 5. Förbättrad Todo-lista ⏳
**Status:** Behöver uppdatering med ADHD-funktioner
**Nuvarande fil:** `/lib/app/features/todo/todo_screen.dart`

**Planerade förbättringar:**
- Energifilter: Visa uppgifter baserat på nuvarande energinivå
- Kontexttaggar: @kontext, #projekt, !prioritet
- Snabbactions: Swipe-to-defer, snooze, delegera
- Visuell progress: Progress bars för projekt
- Smart scheduling: Föreslå när uppgifter ska göras

### 6. Rutinbyggare ⏳
**Status:** Inte implementerad än

**ADHD-funktioner:**
- Visuella checklistor med ikoner
- Flexibla rutiner (morgon, kväll, arbete)
- Gamification: Streak counters, achievements
- Mjuk guidance: Step-by-step utan stress
- Adaptiva rutiner: Justerar baserat på energi/humör

### 7. Humörlogg & Energitracker ⏳
**Status:** Grundläggande implementation i dashboard

**Utökade funktioner:**
- Detaljerad humörlogging med triggers
- Energimönster över tid
- Korrelationer: Humör vs produktivitet
- Personliga insikter och rekommendationer
- Export för vårdgivare

## Tekisk arkitektur

### Komponentstruktur
```
lib/
├── app/
│   ├── core/
│   │   ├── theme/           # ADHD-anpassat designsystem
│   │   ├── responsive/      # Mobile-first responsive layout
│   │   └── ios/            # iOS-specifika optimeringar
│   ├── shared/
│   │   └── widgets/        # Återanvändbara ADHD-komponenter
│   │       ├── universal_inbox.dart ✅
│   │       ├── visual_timer.dart ✅
│   │       ├── energy_slider.dart ⏳
│   │       ├── routine_checklist.dart ⏳
│   │       └── mood_selector.dart ⏳
│   └── features/
│       ├── dashboard/
│       │   └── adhd_dashboard.dart ✅
│       ├── pomodoro/
│       │   └── pomodoro_screen.dart ✅
│       ├── todo/          # Behöver ADHD-uppdatering
│       ├── planning/      # Kommande
│       └── mood_tracker/  # Kommande
```

### Datamodeller
```dart
// Energy & Mood tracking
class EnergyLog {
  String userId;
  int energyLevel;     // 1-10
  String mood;         // happy, tired, stressed, focused, etc.
  DateTime timestamp;
  Map<String, dynamic> triggers; // Optional context
}

// Inbox items för GTD-bearbetning
class InboxItem {
  String content;
  String tag;          // task, idea, note, reminder, question
  bool processed;
  DateTime captured;
}

// Pomodoro sessions
class PomodoroSession {
  String sessionType; // work, break
  int duration;       // minutes
  String taskName;
  DateTime completedAt;
}
```

### Firebase Collections
- `energy_logs` - Energi och humördata
- `inbox` - Universella inbox-objekt
- `pomodoro_sessions` - Pomodoro/fokussessioner
- `tasks` - Uppgifter och projekt
- `routines` - Användardefinierade rutiner
- `user_preferences` - ADHD-anpassningar per användare

## Testing Strategy

### Användarfeedback prioriteter
1. **Kognitiv belastning:** Är interfacet överväldigande?
2. **Friktion:** Hur många steg tar det att fånga en tanke?
3. **Adaptation:** Anpassar sig appen till energinivå?
4. **Motivation:** Känns gamification lagom eller störande?
5. **Utility:** Löser appen verkliga ADHD-utmaningar?

### A/B testing områden
- Timer-design: Cirkulär vs linear progressbar
- Energi-input: Slider vs emoji-val
- Notifications: Frekvens och timing
- Färgschema: Lugn blå vs varma toner
- Navigation: Bottom tabs vs drawer

## Implementation Timeline

### Sprint 1 (Vecka 1-2) ✅ KLAR
- [x] Universal Inbox
- [x] Visual Timer  
- [x] ADHD Dashboard
- [x] Förbättrad Pomodoro

### Sprint 2 (Vecka 3-4) ⏳ PÅGÅENDE
- [ ] Uppdatera Todo-lista med ADHD-funktioner
- [ ] Rutinbyggare MVP
- [ ] Detaljerad humörlogg
- [ ] Energimönster-analys

### Sprint 3 (Vecka 5-6) 📋 PLANERAT
- [ ] AI Coach integration
- [ ] Ljudlandskap för fokus
- [ ] Avancerad planering
- [ ] Användaronboarding

### Sprint 4 (Vecka 7-8) 📋 PLANERAT
- [ ] iOS-optimering och native features
- [ ] Performance optimering
- [ ] Accessibility improvements  
- [ ] Beta-testing med målgrupp

## Success Metrics

### Kvantitativa mått
- Daily Active Users (DAU)
- Session length och frekvens
- Task completion rate
- Pomodoro sessions per dag
- User retention (1v, 1m, 3m)

### Kvalitativa mått
- Cognitive load assessment (1-10 scale)
- Feature utility rating
- Emotional response to notifications
- Accessibility compliance
- User satisfaction surveys

### ADHD-specifika mått
- Energy-produktivitet korrelation
- Inbox processing rate
- Routine adherence
- Symptom improvement (self-reported)
- Executive function confidence

## Nästa steg

1. **Testa nuvarande implementation:** Kör appen på iOS och samla initial feedback
2. **Uppdatera Todo-lista:** Lägg till energifilter och kontexttaggar  
3. **Skapa rutinbyggare:** Fokus på visuella checklistor
4. **Användartest:** Rekrytera 5-10 vuxna med ADHD för feedback
5. **Iterera baserat på feedback:** Refinera UI/UX baserat på verklig användning

Detta MVP ger en solid grund för en forskningsbaserad ADHD-stödsapp som adresserar verkliga kognitiva utmaningar med evidensbaserade lösningar.
