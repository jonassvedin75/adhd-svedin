import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_kodhjalp/app/shared/navigation/navigation_destinations.dart';
import 'package:ai_kodhjalp/app/core/responsive/responsive_layout.dart';
import 'package:ai_kodhjalp/app/core/ios/ios_security.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  void _onItemTapped(BuildContext context, int index) {
    if (index >= 0 && index < bottomNavigationDestinations.length) {
      context.go(bottomNavigationDestinations[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    final currentPage = allNavigationDestinations.firstWhere(
      (d) => currentPath.startsWith(d.path),
      orElse: () => const AppNavigationDestination(path: '/', label: 'Hem', icon: Icons.home, selectedIcon: Icons.home),
    );

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
      // The AppBar is now defined in each view for more control
      // appBar: IosAppBar(
      //   title: currentPage.label,
      // ),
      body: child,
      bottomNavigationBar: _buildCustomBottomNav(context, selectedBottomIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildKaosButton(context),
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

  Widget _buildTabletLayout(BuildContext context, AppNavigationDestination currentPage, int selectedBottomIndex) {
    return _buildMobileLayout(context, currentPage, selectedBottomIndex);
  }

  Widget _buildDesktopLayout(BuildContext context, AppNavigationDestination currentPage, int selectedBottomIndex) {
    return _buildMobileLayout(context, currentPage, selectedBottomIndex);
  }
}
