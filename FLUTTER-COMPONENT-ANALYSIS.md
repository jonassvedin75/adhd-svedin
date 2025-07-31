# Flutter-komponentanalys för ADHD-stödsapp
*Baserat på forskningsdriven funktionsplan*

## Översikt
Detta dokument kartlägger befintliga Flutter-widgets och paket som kan anpassas för ADHD-specifika funktioner enligt forskningsplanen. Fokus ligger på att identifiera komponenter som kan utökas med neuro-inkluderande design.

## Kärnfunktionsmoduler - Flutter-implementering

### 1. "Externa hjärnan"-modulen: Uppgifts- och projekthantering

#### GTD-inspirerad universell inkorg
**Flutter-komponenter:**
- `FloatingActionButton` - För alltid synlig "fånga-knapp"
- `TextField` - För snabb textinmatning 
- `ListView.builder` - För inkorgslista
- `Dismissible` - För swipe-to-action på inkorgsobjekt

**Anpassningar för ADHD:**
- Minimal friktion: Auto-focus på textfält
- Röstinmatning: `speech_to_text` paket
- Snabbtaggar: `Chip` widgets för kategorisering
- Offline-first: `sqflite` för lokal lagring

#### Strukturerade projekt- och uppgiftslistor
**Flutter-komponenter:**
- `ExpansionTile` - För hierarkiska projekt/underuppgifter
- `CheckboxListTile` - För att-göra objekt
- `ReorderableListView` - För drag-and-drop omorganisering
- `Card` - För visuell gruppering av relaterade uppgifter

**Anpassningar för ADHD:**
- Energifilter: `FilterChip` med färgkodning
- Visuell progress: `LinearProgressIndicator` för projektframsteg
- Kontexttaggar: `Wrap` med `Chip` widgets för @-kontexter

### 2. "Tidstämjaren"-modulen: Visualisera och hantera tid

#### Visuella timers
**Flutter-komponenter:**
- `CircularProgressIndicator` - Bas för cirkulär timer
- `CustomPainter` - För anpassade visuella representationer
- `AnimatedContainer` - För mjuka övergångar
- `TweenAnimationBuilder` - För tidsstyrda animationer

**Anpassningar för ADHD:**
- Timstock-liknande design: Custom painter för krympande cirklar
- Lugnande färger: Gradients med `LinearGradient`
- Taktil feedback: `HapticFeedback` för milstolpar
- Minimal stress: Inga alarmerande färger eller ljud

#### Flexibel Pomodoro/Fokus-timer
**Flutter-komponenter:**
- `TabBar`/`TabBarView` - För växling mellan arbete/paus
- `Slider` - För justering av intervallängd
- `IconButton` - För play/pause/reset kontroller

**Relevanta paket:**
- `flutter_local_notifications` - För påminnelser
- `wakelock` - För att hålla skärmen aktiv
- `timer_count_down` - Bas för nedräkning

### 3. "Rutinmotorn"-modulen: Vanor och automatisering

#### Checklistebaserad rutinbyggare
**Flutter-komponenter:**
- `Stepper` - För sekventiella rutinsteg
- `CheckboxListTile` - För rutinpunkter
- `PageView` - För guidning genom rutiner
- `FloatingActionButton` - För snabbstart av rutiner

**Anpassningar för ADHD:**
- Visuella cues: `CircleAvatar` med ikoner för varje steg
- Framstegsvisualisering: `LinearProgressIndicator`
- Mjuk feedback: Subtila animationer med `AnimatedOpacity`

#### Gamification för vanebildning
**Flutter-komponenter:**
- `AnimatedContainer` - För växande växter/framstegsbarer
- `Stack` - För overlay av belöningar
- `Hero` - För belöningsanimationer
- `CustomPaint` - För unika visualiseringar

**Relevanta paket:**
- `lottie` - För mjuka animationer
- `confetti` - För celebrerande effekter (diskret)
- `shared_preferences` - För beständig progress

### 4. "Fokusfristaden"-modulen: Minimera distraktioner

#### Anpassningsbara ljudlandskap
**Flutter-komponenter:**
- `Slider` - För volymkontroll
- `ToggleButtons` - För ljudval
- `Card` - För ljudpresenter
- `IconButton` - För play/pause kontroller

**Relevanta paket:**
- `audioplayers` - För ljuduppspelning
- `audio_session` - För ljudsessionshantering
- `flutter_audio_service` - För bakgrundsuppspelning

#### "Fokusläge"-integration
**iOS-specifika funktioner:**
- `ios_focus_mode` (custom implementation)
- Platform channels för iOS Shortcuts integration
- `permission_handler` för nödvändiga behörigheter

### 5. "Känslotermometern"-modulen: Självmedvetenhet

#### Enkel humör- och energilogg
**Flutter-komponenter:**
- `Slider` - För energi/humörnivåer
- `GridView` - För emoji-val
- `Calendar` - För historisk data
- `Charts` - För trendvisualisering

**Relevanta paket:**
- `fl_chart` - För datavisualisering
- `table_calendar` - För kalendervy
- `flutter_emoji` - För humörikoner

#### Guidad "Mindful paus"-knapp
**Flutter-komponenter:**
- `FloatingActionButton` - För lättåtkomlig paus-knapp
- `ModalBottomSheet` - För guidning overlay
- `AnimatedBuilder` - För andningsanimationer
- `AudioPlayer` - För guidad meditation

### 6. "Minnesvalvet"-modulen: Informationsinsamling

#### Snabba anteckningar med OCR
**Relevanta paket:**
- `camera` - För bildtagning
- `google_ml_kit` - För textigenkänning
- `image_picker` - För galleriåtkomst
- `pdf` - För dokumentgenerering

#### Röstmemon med transkribering
**Relevanta paket:**
- `speech_to_text` - För rösttranskribering
- `record` - För ljudinspelning
- `permission_handler` - För mikrofonbehörigheter

## UI/UX Komponenter för neuro-inkluderande design

### Grundläggande designsystem
**Flutter-komponenter:**
- `ThemeData` - För konsekvent färgpalett och typografi
- `MediaQuery` - För responsiv design
- `Accessibility` widgets - För tillgänglighet
- `AnimatedTheme` - För mjuka temabyte (mörkt läge)

### Personalisering och kontroll
**Flutter-komponenter:**
- `Drawer`/`NavigationRail` - För anpassningsbar navigation
- `Switch`/`Checkbox` - För funktionsaktivering
- `SegmentedButton` - För layoutval
- `ColorScheme` - För temapersonalisering

### Användarstyrda notiser
**Relevanta paket:**
- `flutter_local_notifications` - För lokala påminnelser
- `timezone` - För schemalagda notiser
- `shared_preferences` - För notisinställningar

## Implementation strategi

### MVP (Minimum Viable Product)
**Prioriterade komponenter:**
1. `FloatingActionButton` + `TextField` - Universell inkorg
2. `ListView` + `CheckboxListTile` - Grundläggande uppgiftslista  
3. `CircularProgressIndicator` + `Timer` - Enkel visuell timer

### Fas 2 (Förbättring)
**Tillägg:**
1. `Stepper` + `PageView` - Rutinbyggare
2. `Slider` + `Calendar` - Humörlogg
3. `ExpansionTile` - Hierarkiska projekt

### Fas 3 (Integration & finslipning)
**Avancerade funktioner:**
1. `CustomPainter` - Avancerade timers
2. `AudioPlayers` - Ljudlandskap
3. `Camera` + `ML Kit` - OCR funktionalitet

## Tekniska överväganden

### Performance för ADHD-användare
- Minimal laddningstid: `flutter_native_splash` för snabb start
- Offline-first: `sqflite` + `hive` för lokal data
- Mjuka animationer: `AnimationController` med curves.easeInOut
- Låg minnesanvändning: Lazy loading med `ListView.builder`

### Accessibility
- Screen reader support: `Semantics` widgets
- Hög kontrast: Anpassningsbara `ColorScheme`
- Större touch targets: Minimum 44px enligt iOS guidelines
- Röststyrning: `SpeechToText` integration

### iOS-specifik optimering
- Platform-specifik kod: `Platform.isIOS` checks
- iOS design language: `CupertinoIcons` och `CupertinoButton`
- Haptic feedback: `HapticFeedback.selectionClick()`
- iOS Shortcuts: Platform channels för automation

## Nästa steg

1. **MVP Implementation**: Börja med kärnkomponenterna för inkorg och uppgiftslista
2. **UI System**: Etablera designsystem med neuro-inkluderande riktlinjer
3. **User Testing**: Testa med målgrupp för feedback på kognitiv belastning
4. **Iteration**: Raffinera baserat på användarfeedback och prestandamätningar

Denna komponentanalys ger en tydlig roadmap för hur befintliga Flutter-widgets kan anpassas och utökas för att skapa ett verkligt ADHD-vänligt digitalt stödsystem.
