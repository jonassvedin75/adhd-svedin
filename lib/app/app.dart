import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_kodhjalp/app/router.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';

// --- Theme Provider to manage theme state ---
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Använd systemets tema som standard

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
          // Create text theme
          TextTheme textTheme = GoogleFonts.interTextTheme();
          
          // Create MaterialTheme instance
          MaterialTheme materialTheme = MaterialTheme(textTheme);
          
          return MaterialApp.router(
            title: 'ADHD Coach',
            debugShowCheckedModeBanner: false,
            theme: materialTheme.light(),
            darkTheme: materialTheme.dark(),
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
