import 'package:flutter/material.dart';

// --- DESKTOP/TABLET: Navigation Rail (Alla länkar) ---
const List<NavigationRailDestination> navRailDestinations = [
  NavigationRailDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: Text('ToDo')),
  NavigationRailDestination(icon: Icon(Icons.psychology_outlined), selectedIcon: Icon(Icons.psychology), label: Text('AI Coach')),
  NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: Text('Planera')),
  NavigationRailDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: Text('Kaos (Oro)')),
  NavigationRailDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: Text('Pomodoro')),
  NavigationRailDestination(icon: Icon(Icons.sentiment_satisfied_alt_outlined), selectedIcon: Icon(Icons.sentiment_satisfied_alt), label: Text('Humör')),
  NavigationRailDestination(icon: Icon(Icons.lightbulb_outline), selectedIcon: Icon(Icons.lightbulb), label: Text('Lösning')),
  NavigationRailDestination(icon: Icon(Icons.link_outlined), selectedIcon: Icon(Icons.link), label: Text('Analys')),
  NavigationRailDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: Text('Belöning')),
];


// --- MOBIL: Bottom Navigation Bar (4 huvudlänkar) ---
const List<Widget> navBarDestinations = [
  NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'ToDo'),
  NavigationDestination(icon: Icon(Icons.psychology_outlined), selectedIcon: Icon(Icons.psychology), label: 'Coach'),
  NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Planera'),
  NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Kaos'),
];
