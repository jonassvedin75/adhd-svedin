# App Blueprint

## Översikt

Detta dokument beskriver arkitekturen, designprinciperna och de implementerade funktionerna för ADHD-Coachen-appen. Målet är att skapa en strukturerad och underhållbar kodbas.

---

## Aktuell Plan: Implementation av "Kaos"-läget

**Mål:** Att skapa en omedelbar "pattern interrupt" för att hjälpa användare att hantera akut emotionell dysreglering.

**Fas 1: Ombyggnation av Navigationen**
1.  **Plats för Ändring:** Fokusera på `lib/app/app_shell.dart`.
2.  **Implementera `BottomAppBar`:** Ersätt `NavigationBar` med en `BottomAppBar` med ett "hack" (`CircularNotchedRectangle`) för att ge plats åt en central knapp.
3.  **Implementera `FloatingActionButton`:** Skapa en distinkt, orange "Kaos"-knapp som en `FloatingActionButton`. Ett tryck navigerar till `/kaos`.
4.  **Skapa Egna Nav-knappar:** Bygg de övriga navigeringsknapparna ("Inkorg", "Uppgifter", etc.) som `IconButton`-widgets i en `Row` inuti `BottomAppBar`.

**Fas 2: Bygga "Kaos"-skärmen (`KaosView`)**
1.  **Skapa Filen:** Skapa `lib/app/features/kaos/kaos_view.dart` som en `StatefulWidget`.
2.  **Installera Beroenden:** Lägg till `flutter_sound` och `permission_handler`.
3.  **Implementera Steg 1 (Identifiera):** Bygg UI med val för känslor eller röstinspelning.
4.  **Implementera Steg 2 (Spela in):**
    *   Skapa inspelnings-UI med en stor stoppknapp.
    *   Implementera logik för mikrofontillstånd, inspelning och uppladdning av ljudfil till Firebase Storage.
    *   Spara en referens till filen i en ny `chaos_entries`-collection i Firestore.
5.  **Implementera Steg 3 (Agera):** Skapa det avslutande steget med en enkel, fysisk handling.

**Fas 3: Routing**
1.  **Skapa Route:** Lägg till en ny route, `/kaos`, i `lib/app/router.dart` som pekar till `KaosView`.

---

## Implementerade Funktioner

*(Denna sektion kommer att uppdateras löpande i takt med att nya funktioner läggs till.)*

*   **Databasintegration:** Kärnfunktionerna (Inkorg, Uppgifter, Projekt, Idéer) är anslutna till Firestore med en centraliserad `FirestoreService`.
*   **Initial Projektstruktur:** Grundläggande app-struktur med navigation och platshållare för funktioner.
*   **Temahantering:** Centraliserad temahantering för ett konsekvent utseende.
