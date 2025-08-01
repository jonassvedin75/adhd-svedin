import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_kodhjalp/app/router.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';

// --- Theme Provider to manage theme state ---
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

// --- Main App Widget ---
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'ADHD Coach',
            debugShowCheckedModeBanner: false,
            // --- Applying the unified light theme ---
            theme: AppThemes.lightTheme,
            themeMode: ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
