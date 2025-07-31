/// iOS-säkerhetsmodul för ADHD-appen - utökad version
/// Förbättrad för fullständig Xcode-miljö

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

/// iOS-specifik säkerhet och optimering för ADHD-appen
class IosSecurityConfig {
  static bool _initialized = false;
  
  /// Konfigurera iOS-specifika säkerhetsinställningar
  static Future<void> configure() async {
    if (_initialized) return;
    
    if (Platform.isIOS || _isWebWithIosUserAgent()) {
      await _configureStatusBar();
      await _configureScreenCapture();
      await _configureAccessibility();
      await _configureMemoryManagement();
      await _configureNotifications();
      _initialized = true;
    }
  }

  /// Kontrollera om vi är på web med iOS user agent
  static bool _isWebWithIosUserAgent() {
    // För web-baserad iOS-liknande upplevelse
    return true; // Alltid aktivera iOS-stil för denna ADHD-app
  }

  /// Konfigurera status bar för iOS
  static Future<void> _configureStatusBar() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Förhindra skärmdumpar på känsligt innehåll (iOS)
  static Future<void> _configureScreenCapture() async {
    // Säkerhet för ADHD-användardata
    // I framtiden när vi lägger till känslig data
    // kan vi använda flutter_windowmanager eller liknande
  }

  /// Tillgänglighet för iOS och ADHD-användare
  static Future<void> _configureAccessibility() async {
    // Konfigurera för VoiceOver och andra tillgänglighetstjänster
    // Särskilt viktigt för ADHD-användare som kan ha tillgänglighetsbehov
  }

  /// Minneshantering för ADHD-appen
  static Future<void> _configureMemoryManagement() async {
    // Optimera minnesanvändning för bättre prestanda på iOS
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Konfigurera notifikationer för ADHD-appen
  static Future<void> _configureNotifications() async {
    // Förbereder för iOS-notifikationer
    // Kommer att implementeras när fullständig iOS-miljö är redo
  }

  /// Kontrollera om iOS-simulator är tillgänglig
  static bool get isSimulatorAvailable {
    return Platform.isIOS; // Kommer att vara true när vi kör på simulator
  }

  /// iOS-specifika utvecklingsinställningar
  static void enableDevelopmentMode() {
    if (Platform.isIOS) {
      // Aktivera debug-funktioner för iOS-utveckling
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.red, // Debug-indikator
        ),
      );
    }
  }
}

/// iOS-anpassade widgets för ADHD-appen
class IosAdaptiveWidget extends StatelessWidget {
  final Widget child;
  final bool useIosDesign;
  final EdgeInsets? padding;

  const IosAdaptiveWidget({
    super.key,
    required this.child,
    this.useIosDesign = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (useIosDesign) {
      return SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      );
    }
    return child;
  }
}

/// iOS-anpassad AppBar för ADHD-appen
class IosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  const IosAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true, // iOS-stil
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// iOS haptic feedback för ADHD-appen
class IosHapticFeedback {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Specialiserad feedback för ADHD-användare
  static void focusConfirmation() {
    // Mjuk feedback när användaren fokuserar på en uppgift
    lightImpact();
  }

  static void taskCompleted() {
    // Positiv feedback när en uppgift slutförs
    mediumImpact();
  }

  static void alertFeedback() {
    // För påminnelser och varningar
    heavyImpact();
  }
}

/// iOS-stil knappar för ADHD-appen
class IosButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isDestructive;
  final bool isLoading;

  const IosButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: isLoading ? null : () {
        IosHapticFeedback.selectionClick();
        onPressed?.call();
      },
      color: isDestructive 
          ? CupertinoColors.destructiveRed 
          : (backgroundColor ?? CupertinoColors.activeBlue),
      child: isLoading 
          ? const CupertinoActivityIndicator(color: Colors.white)
          : Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

/// iOS-stil listtile för ADHD-appen
class IosListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const IosListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: subtitle != null 
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              )
            : null,
        leading: leading,
        trailing: trailing ?? (showChevron && onTap != null 
            ? const Icon(CupertinoIcons.chevron_right)
            : null),
        onTap: onTap != null ? () {
          IosHapticFeedback.selectionClick();
          onTap!();
        } : null,
      ),
    );
  }
}
