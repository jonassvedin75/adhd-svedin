import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ai_kodhjalp/app/core/responsive/responsive_layout.dart';
import 'package:ai_kodhjalp/app/core/ios/ios_security.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return IOSResponsiveWrapper(
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context, user),
        tablet: _buildTabletLayout(context, user),
        desktop: _buildDesktopLayout(context, user),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, User? user) {
    return Scaffold(
      body: ResponsivePadding(
        mobilePadding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            _buildMobileHeader(context, user),
            _buildQuickActions(context),
            _buildRecentActivity(context),
            _buildProgressCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, User? user) {
    return Scaffold(
      body: ResponsivePadding(
        tabletPadding: const EdgeInsets.all(24),
        child: CustomScrollView(
          slivers: [
            _buildTabletHeader(context, user),
            SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildQuickActionsGrid(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: _buildProgressCards(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, User? user) {
    return Scaffold(
      body: ResponsivePadding(
        desktopPadding: const EdgeInsets.all(32),
        child: CustomScrollView(
          slivers: [
            _buildDesktopHeader(context, user),
            SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildQuickActionsGrid(context)),
                  const SizedBox(width: 32),
                  Expanded(flex: 2, child: _buildProgressCards(context)),
                  const SizedBox(width: 32),
                  Expanded(flex: 1, child: _buildRecentActivity(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, User? user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: ResponsiveText(
          'Hej ${user?.displayName ?? 'Användare'}!',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
          mobileFontSize: 20,
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black87),
          onPressed: () async {
            // iOS haptic feedback
            iOSHapticFeedback.selectionClick();
            
            final confirmed = await _showIOSLogoutDialog(context);
            
            if (confirmed == true) {
              iOSHapticFeedback.mediumImpact();
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            }
          },
          tooltip: 'Logga ut',
        ),
      ],
    );
  }

  Widget _buildTabletHeader(BuildContext context, User? user) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveText(
              'Hej ${user?.displayName ?? 'Användare'}!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              tabletFontSize: 28,
              desktopFontSize: 32,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              tooltip: 'Logga ut',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, User? user) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveText(
              'Hej ${user?.displayName ?? 'Användare'}!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              desktopFontSize: 36,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              tooltip: 'Logga ut',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_task,
        title: 'Ny uppgift',
        subtitle: 'Lägg till i todo',
        color: Colors.blue,
        onTap: () => context.go('/todo'),
      ),
      _QuickAction(
        icon: Icons.timer,
        title: 'Pomodoro',
        subtitle: 'Starta fokussession',
        color: Colors.red,
        onTap: () => context.go('/pomodoro'),
      ),
      _QuickAction(
        icon: Icons.mood,
        title: 'Humör',
        subtitle: 'Spåra känslor',
        color: Colors.green,
        onTap: () => context.go('/mood'),
      ),
      _QuickAction(
        icon: Icons.psychology,
        title: 'AI-coach',
        subtitle: 'Få hjälp',
        color: Colors.purple,
        onTap: () => context.go('/ai-coach'),
      ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResponsiveText(
              'Snabbåtgärder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ResponsiveGrid(
              spacing: 12,
              runSpacing: 12,
              children: actions.map((action) => _buildActionCard(action)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    // För tablet och desktop layout
    return _buildQuickActions(context);
  }

  Widget _buildActionCard(_QuickAction action) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.all(16),
          onPressed: () {
            // iOS haptic feedback för ADHD-appen
            iOSHapticFeedback.focusConfirmation();
            action.onTap();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: ResponsiveLayout.isMobile(context) ? 32 : 40,
                color: action.color,
              ),
              const SizedBox(height: 8),
              ResponsiveText(
                action.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
                mobileFontSize: 14,
                tabletFontSize: 16,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              ResponsiveText(
                action.subtitle,
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                ),
                mobileFontSize: 12,
                tabletFontSize: 14,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Senaste aktivitet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Placeholder för senaste aktivitet
            Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Uppgift slutförd'),
                subtitle: Text('Städa rummet'),
                trailing: Text('10:30'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCards(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              'Framsteg idag',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Placeholder för framstegskort
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Uppgifter slutförda'),
                        Text('3/5'),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(value: 0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// iOS-stil logout dialog
  Future<bool?> _showIOSLogoutDialog(BuildContext context) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Logga ut'),
          content: const Text('Är du säker på att du vill logga ut?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                iOSHapticFeedback.selectionClick();
                Navigator.of(context).pop(false);
              },
              child: const Text('Avbryt'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                iOSHapticFeedback.selectionClick();
                Navigator.of(context).pop(true);
              },
              child: const Text('Logga ut'),
            ),
          ],
        );
      },
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
