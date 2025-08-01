import 'package:flutter/material.dart';

// Renamed to avoid conflict with Flutter's own NavigationDestination
class AppNavigationDestination {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const AppNavigationDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

// ALL destinations for the Drawer
const List<AppNavigationDestination> allNavigationDestinations = [
  AppNavigationDestination(
    path: '/dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  AppNavigationDestination(
    path: '/inbox',
    label: 'Inkorg',
    icon: Icons.inbox_outlined,
    selectedIcon: Icons.inbox,
  ),
  AppNavigationDestination(
    path: '/tasks',
    label: 'Uppgifter',
    icon: Icons.task_outlined,
    selectedIcon: Icons.task,
  ),
  AppNavigationDestination(
    path: '/projects',
    label: 'Projekt',
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder,
  ),
  AppNavigationDestination(
    path: '/ideas',
    label: 'Idéer & Framtid',
    icon: Icons.lightbulb_outline,
    selectedIcon: Icons.lightbulb,
  ),
   AppNavigationDestination(
    path: '/planning',
    label: 'Planering',
    icon: Icons.edit_calendar_outlined,
    selectedIcon: Icons.edit_calendar,
  ),
  AppNavigationDestination(
    path: '/pomodoro',
    label: 'Timer',
    icon: Icons.timer_outlined,
    selectedIcon: Icons.timer,
  ),
  AppNavigationDestination(
    path: '/kaos',
    label: 'Kaos',
    icon: Icons.storm_outlined,
    selectedIcon: Icons.storm,
  ),
  AppNavigationDestination(
    path: '/mood',
    label: 'Humör',
    icon: Icons.sentiment_satisfied_outlined,
    selectedIcon: Icons.sentiment_satisfied,
  ),
   AppNavigationDestination(
    path: '/chain',
    label: 'Beteendekedja',
    icon: Icons.link_outlined,
    selectedIcon: Icons.link,
  ),
   AppNavigationDestination(
    path: '/solving',
    label: 'Problemlösning',
    icon: Icons.lightbulb_outline,
    selectedIcon: Icons.lightbulb,
  ),
  AppNavigationDestination(
    path: '/worry',
    label: 'Hantera Oro',
    icon: Icons.psychology_outlined,
    selectedIcon: Icons.psychology,
  ),
  AppNavigationDestination(
    path: '/rewards',
    label: 'Belöning',
    icon: Icons.star_outline,
    selectedIcon: Icons.star,
  ),
  AppNavigationDestination(
    path: '/coach',
    label: 'AI Coach',
    icon: Icons.computer_outlined,
    selectedIcon: Icons.computer,
  ),
];

// The FOUR specific destinations for the Bottom Navigation Bar
final List<AppNavigationDestination> bottomNavigationDestinations = [
  allNavigationDestinations[0], // Dashboard
  allNavigationDestinations[2], // Uppgifter 
  allNavigationDestinations[6], // Timer (Pomodoro)
  allNavigationDestinations[5], // Planering
];
