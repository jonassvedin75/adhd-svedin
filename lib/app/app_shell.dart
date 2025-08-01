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
  bool _isExtended = false;

  void _onItemTapped(BuildContext context, int index) {
    if (index >= 0 && index < bottomNavigationDestinations.length) {
      context.go(bottomNavigationDestinations[index].path);
    }
  }
  
    void _onRailItemTapped(BuildContext context, int index) {
    if (index >= 0 && index < allNavigationDestinations.length) {
      context.go(allNavigationDestinations[index].path);
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

    final selectedRailIndex = allNavigationDestinations.indexWhere(
      (d) => currentPath.startsWith(d.path),
    );

    return IosAdaptiveWidget(
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context, currentPage, selectedBottomIndex),
        tablet: _buildDesktopLayout(context, currentPage, selectedRailIndex), 
        desktop: _buildDesktopLayout(context, currentPage, selectedRailIndex),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppNavigationDestination currentPage, int selectedBottomIndex) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildCustomBottomNav(context, selectedBottomIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildKaosButton(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppNavigationDestination currentPage, int selectedRailIndex) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage.label),
        leading: IconButton(
          icon: Icon(_isExtended ? Icons.menu_open : Icons.menu),
          onPressed: () {
            setState(() {
              _isExtended = !_isExtended;
            });
          },
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedRailIndex,
            onDestinationSelected: (index) => _onRailItemTapped(context, index),
            labelType: NavigationRailLabelType.none,
            extended: _isExtended,
            destinations: allNavigationDestinations.map((d) {
              return NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: Text(d.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildKaosButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.go('/kaos'),
      backgroundColor: AppColors.warning,
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
          _buildNavItem(context, icon: FontAwesomeIcons.inbox, label: 'Inkorg', index: 0, selectedIndex: selectedIndex),
          _buildNavItem(context, icon: FontAwesomeIcons.listCheck, label: 'Uppgifter', index: 1, selectedIndex: selectedIndex),
          const SizedBox(width: 48), // Spacer for the Kaos button
          _buildNavItem(context, icon: FontAwesomeIcons.lightbulb, label: 'Idéer', index: 2, selectedIndex: selectedIndex),
          _buildNavItem(context, icon: FontAwesomeIcons.layerGroup, label: 'Projekt', index: 3, selectedIndex: selectedIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index, required int selectedIndex}) {
    final isSelected = selectedIndex == index;
    return IconButton(
      icon: FaIcon(icon, color: isSelected ? AppColors.primary : AppColors.bordersAndIcons),
      onPressed: () => _onItemTapped(context, index),
      tooltip: label,
    );
  }
}