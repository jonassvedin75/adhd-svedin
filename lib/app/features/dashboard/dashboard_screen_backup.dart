import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  Expanded(flex: 2, child: _buildQuickActions(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: _buildRecentActivity(context)),
                ],
              ),
            ),
            _buildProgressCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, User? user) {
    return _buildTabletLayout(context, user); // Samma som tablet för nu
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
        subtitle: 'Logga ditt humör',
        color: Colors.green,
        onTap: () => context.go('/mood-tracker'),
      ),
      _QuickAction(
        icon: Icons.psychology,
        title: 'AI Coach',
        subtitle: 'Få vägledning',
        color: Colors.purple,
        onTap: () => context.go('/ai-coach'),
      ),
    ];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Snabbåtgärder',
            style: const TextStyle(fontWeight: FontWeight.bold),
            mobileFontSize: 18,
            tabletFontSize: 20,
          ),
          const SizedBox(height: 16),
          ResponsiveGrid(
            children: actions.map((action) => _buildActionCard(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
  }

  Widget _buildRecentActivity(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ResponsiveText(
            'Senaste aktivitet',
            style: const TextStyle(fontWeight: FontWeight.bold),
            mobileFontSize: 18,
            tabletFontSize: 20,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ResponsiveText(
                'Inga aktiviteter än. Börja genom att använda någon av funktionerna ovan!',
                style: TextStyle(color: Colors.grey[600]),
                mobileFontSize: 14,
                tabletFontSize: 16,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ResponsiveText(
            'Dina framsteg',
            style: const TextStyle(fontWeight: FontWeight.bold),
            mobileFontSize: 18,
            tabletFontSize: 20,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProgressItem('Uppgifter slutförda', '0/0', 0.0),
                  const SizedBox(height: 16),
                  _buildProgressItem('Pomodoro-sessioner', '0', 0.0),
                  const SizedBox(height: 16),
                  _buildProgressItem('Humörloggningar', '0', 0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, double progress) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                title,
                mobileFontSize: 14,
                tabletFontSize: 16,
              ),
              ResponsiveText(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
                mobileFontSize: 14,
                tabletFontSize: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
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

// Lägg till i ios_security.dart senare
Future<bool?> iOSAdaptiveDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = 'OK',
  String? cancelText,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: Text(content),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
