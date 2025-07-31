import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_kodhjalp/app/shared/navigation/navigation_destinations.dart';
import 'package:ai_kodhjalp/app/core/responsive/responsive_layout.dart';
import 'package:ai_kodhjalp/app/core/ios/ios_security.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    // Find the title for the current page from ALL possible destinations
    final currentPage = allNavigationDestinations.firstWhere(
      (d) => currentPath.startsWith(d.path),
      // Use our own, non-conflicting class here
      orElse: () => const AppNavigationDestination(path: '/', label: 'Hem', icon: Icons.home, selectedIcon: Icons.home),
    );

    // Calculate the selected index for the bottom navigation bar
    final selectedBottomIndex = bottomNavigationDestinations.indexWhere(
      (d) => currentPath.startsWith(d.path)
    );

    return IosAdaptiveWidget(
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context, currentPage, selectedBottomIndex),
        tablet: _buildTabletLayout(context, currentPage, selectedBottomIndex),
        desktop: _buildDesktopLayout(context, currentPage, selectedBottomIndex),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppNavigationDestination currentPage, int selectedBottomIndex) {
    return Scaffold(
      appBar: IosAppBar(
        title: currentPage.label,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Logga ut',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: ResponsivePadding(
        mobilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: child,
      ),
      bottomNavigationBar: _buildBottomNav(context, selectedBottomIndex),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AppNavigationDestination currentPage, int selectedBottomIndex) {
    return Scaffold(
      appBar: IosAppBar(
        title: currentPage.label,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Logga ut',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: ResponsivePadding(
        tabletPadding: const EdgeInsets.all(24),
        child: child,
      ),
      bottomNavigationBar: _buildBottomNav(context, selectedBottomIndex),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppNavigationDestination currentPage, int selectedBottomIndex) {
    return _buildTabletLayout(context, currentPage, selectedBottomIndex);
  }

  Widget _buildDrawer(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'ADHD Stöd',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...allNavigationDestinations.map((d) {
            final isSelected = currentPath.startsWith(d.path);
            return ListTile(
              leading: Icon(
                isSelected ? d.selectedIcon : d.icon,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(
                d.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
              selected: isSelected,
              onTap: () {
                context.go(d.path);
                Navigator.pop(context); // Close drawer
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int selectedBottomIndex) {
    return BottomNavigationBar(
      currentIndex: selectedBottomIndex > -1 ? selectedBottomIndex : 0,
      onTap: (index) {
        context.go(bottomNavigationDestinations[index].path);
      },
      items: bottomNavigationDestinations.map((d) {
        return BottomNavigationBarItem(
          icon: Icon(d.icon),
          activeIcon: Icon(d.selectedIcon),
          label: d.label,
        );
      }).toList(),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 10,
    );
  }
}
