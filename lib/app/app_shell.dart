import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_kodhjalp/app/shared/navigation/navigation_destinations.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage.label),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Meny',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ...allNavigationDestinations.map((d) {
              return ListTile(
                leading: Icon(currentPath.startsWith(d.path) ? d.selectedIcon : d.icon),
                title: Text(d.label),
                selected: currentPath.startsWith(d.path),
                onTap: () {
                  context.go(d.path);
                  Navigator.pop(context); // Close drawer
                },
              );
            }),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}
