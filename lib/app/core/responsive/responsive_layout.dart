import 'package:flutter/material.dart';

/// Responsiv layout-hantering för mobile-first design
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  // Breakpoints baserade på Material Design Guidelines
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Adaptiv padding baserat på skärmstorlek
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    
    if (ResponsiveLayout.isDesktop(context)) {
      padding = desktopPadding ?? tabletPadding ?? mobilePadding ?? const EdgeInsets.all(24);
    } else if (ResponsiveLayout.isTablet(context)) {
      padding = tabletPadding ?? mobilePadding ?? const EdgeInsets.all(20);
    } else {
      padding = mobilePadding ?? const EdgeInsets.all(16);
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// iOS-specifik responsiv widget med safe area hantering
class IOSResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool maintainBottomViewPadding;
  final bool handleKeyboard;

  const IOSResponsiveWrapper({
    super.key,
    required this.child,
    this.maintainBottomViewPadding = true,
    this.handleKeyboard = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: handleKeyboard
          ? KeyboardAwareScrollView(child: child)
          : child,
    );
  }
}

/// Adaptiv font-storlek för olika skärmstorlekar
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final TextAlign? textAlign;
  final int? maxLines;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;
    
    if (ResponsiveLayout.isDesktop(context)) {
      fontSize = desktopFontSize ?? tabletFontSize ?? mobileFontSize ?? 16;
    } else if (ResponsiveLayout.isTablet(context)) {
      fontSize = tabletFontSize ?? mobileFontSize ?? 14;
    } else {
      fontSize = mobileFontSize ?? 12;
    }

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

/// Keyboard-aware scroll view för iOS
class KeyboardAwareScrollView extends StatelessWidget {
  final Widget child;

  const KeyboardAwareScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}

/// Adaptiva grid/list layouts
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
  });

  @override
  Widget build(BuildContext context) {
    int crossAxisCount;
    
    if (ResponsiveLayout.isDesktop(context)) {
      crossAxisCount = 4;
    } else if (ResponsiveLayout.isTablet(context)) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing ?? 16,
      mainAxisSpacing: runSpacing ?? 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
