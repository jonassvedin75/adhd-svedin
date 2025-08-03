import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_kodhjalp/app/shared/navigation/navigation_destinations.dart';
import 'package:ai_kodhjalp/app/core/responsive/responsive_layout.dart';
import 'package:ai_kodhjalp/app/core/ios/ios_security.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  void _onItemTapped(BuildContext context, int index) {
    if (index >= 0 && index < bottomNavigationDestinations.length) {
      final destination = bottomNavigationDestinations[index];
      print('🔥 Navigation Debug: Index $index -> Path: ${destination.path} (${destination.label})');
      context.go(destination.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    final currentPage = allNavigationDestinations.firstWhere(
      (d) => currentPath.startsWith(d.path),
      orElse: () => allNavigationDestinations.first,
    );

    final selectedBottomIndex = bottomNavigationDestinations.indexWhere(
      (d) => currentPath.startsWith(d.path),
    );

    return IosAdaptiveWidget(
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context, currentPage, selectedBottomIndex),
        tablet: _buildMobileLayout(context, currentPage, selectedBottomIndex), 
        desktop: _buildMobileLayout(context, currentPage, selectedBottomIndex),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppNavigationDestination currentPage, int selectedBottomIndex) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage.label),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: widget.child,
      bottomNavigationBar: _buildCustomBottomNav(context, selectedBottomIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildKaosButton(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            accountName: Text(currentUser?.displayName ?? 'Användare'),
            accountEmail: Text(currentUser?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                (currentUser?.displayName?.substring(0, 1) ?? 'U').toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: allNavigationDestinations.map((destination) {
                final isSelected = currentPath.startsWith(destination.path);
                return ListTile(
                  leading: Icon(
                    isSelected ? destination.selectedIcon : destination.icon,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(
                    destination.label,
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    Navigator.of(context).pop(); // Close drawer
                    context.go(destination.path);
                  },
                );
              }).toList(),
            ),
          ),
          
          // Logout option
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Logga ut',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              Navigator.of(context).pop(); // Close drawer
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildKaosButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.go('/kaos'),
      backgroundColor: AppColors.kaosBackground,
      elevation: 4.0,
      child: const FaIcon(FontAwesomeIcons.fireExtinguisher, size: 26, color: Colors.white),
      tooltip: 'Kaos',
    );
  }

  Widget _buildCustomBottomNav(BuildContext context, int selectedIndex) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(context, icon: FontAwesomeIcons.house, label: 'Dashboard', index: 0, selectedIndex: selectedIndex),
          _buildNavItem(context, icon: FontAwesomeIcons.listCheck, label: 'Uppgifter', index: 1, selectedIndex: selectedIndex),
          const SizedBox(width: 48), // Spacer for the Kaos button
          _buildNavItem(context, icon: FontAwesomeIcons.clock, label: 'Timer', index: 2, selectedIndex: selectedIndex),
          _buildNavItem(context, icon: FontAwesomeIcons.calendar, label: 'Planering', index: 3, selectedIndex: selectedIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index, required int selectedIndex}) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(context, index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0), // Minska från 8.0 till 6.0
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon, 
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(height: 2), // Minska från 4 till 2
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // Minska från 11 till 10
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}