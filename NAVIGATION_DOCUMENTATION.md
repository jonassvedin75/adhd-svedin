# 🧭 ADHD-stöd App - Navigation System Documentation

**VARNING: Denna navigering är FINAL och FÅR INTE ÄNDRAS utan godkännande!**

## 📋 Navigation Overview

Appen använder en **enhetlig navigationsstruktur** som ser **exakt likadan ut** på alla enheter (mobil, tablet, desktop).

## 🏗️ Navigation Architecture

### Huvudkomponenter:
1. **AppShell** (`lib/app/app_shell.dart`) - Centraliserad navigationslayout
2. **NavigationDestinations** (`lib/app/shared/navigation/navigation_destinations.dart`) - Definitioner av alla sidor
3. **Router** (`lib/app/router.dart`) - URL-routing med go_router

## 🎯 Navigation Elements

### 1. AppBar (Toppen)
- **Hamburgermeny** (☰) - Längst till vänster
- **Sidtitel** - Visar nuvarande sidas namn
- **Samma på alla enheter**

### 2. Hamburgermeny (Drawer)
**Aktiveras:** Klick på hamburgaren (☰)
**Innehåll:**
- Användarinfo (namn, email, profilbild)
- **ALLA sidor** i appen:
  - Dashboard
  - To-Do  
  - Inkorg
  - Uppgifter
  - Projekt
  - Idéer & Framtid
  - Referens
  - Planering
  - Timer
  - Kaos
  - Humör
  - Beteendekedja
  - Problemlösning
  - Belöning
  - AI Coach
- Logga ut (röd)

### 3. Bottom Navigation (Botten)
**4 huvudknappar:**
1. **Inkorg** (📥)
2. **Uppgifter** (✅) 
3. **Idéer** (💡)
4. **Projekt** (📁)

### 4. Floating Action Button
- **Orange Kaos-knapp** (🧯) - Centrerat mellan bottom navigation
- **Direkt åtkomst** till akut stöd

## 🔧 Technical Implementation

### Key Files:
```
lib/app/app_shell.dart                           # Main navigation wrapper
lib/app/shared/navigation/navigation_destinations.dart  # Route definitions  
lib/app/router.dart                              # URL routing
```

### Navigation Functions:
- `_onItemTapped()` - Hanterar bottom navigation klick
- `_buildDrawer()` - Bygger hamburgermeny
- `_buildCustomBottomNav()` - Bygger bottom navigation
- `_buildKaosButton()` - Skapar Kaos floating button

### Navigation Data:
- `allNavigationDestinations[]` - Alla sidor (för drawer)
- `bottomNavigationDestinations[]` - 4 huvudsidor (för bottom nav)

## ✅ Navigation Rules

### SKAL ALLTID:
1. ✅ Samma layout på mobil/tablet/desktop
2. ✅ Hamburgermeny syns på alla sidor
3. ✅ Bottom navigation med exakt 4 knappar
4. ✅ Kaos floating button alltid tillgänglig
5. ✅ Drawer innehåller ALLA sidor
6. ✅ Logga ut längst ner i drawer

### FÅR ALDRIG:
1. ❌ Olika layout för olika enheter
2. ❌ Ta bort hamburgermeny
3. ❌ Ändra antal bottom navigation knappar
4. ❌ Flytta Kaos-knappen
5. ❌ Skapa separata navigation rails
6. ❌ Duplicera navigation i individuella sidor

## 🚨 Critical Notes

- **AppShell wraps alla sidor** - inga individuella AppBars tillåtna
- **Consistent experience** - samma navigering överallt
- **Single source of truth** - navigation_destinations.dart
- **Emergency access** - Kaos-knappen alltid synlig

---

**Senast uppdaterad:** 2025-08-01  
**Status:** FINAL - Ändra inte utan godkännande!
