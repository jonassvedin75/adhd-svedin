import 'package:flutter/material.dart';
import 'package:myapp/app/core/theme/app_theme.dart';
import 'package:myapp/app/router.dart'; // Importera den nya routern

class AdhdSupportApp extends StatelessWidget {
  const AdhdSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Använd MaterialApp.router för att aktivera GoRouter
    return MaterialApp.router(
      title: 'ADHD Stöd',
      theme: appTheme,
      // Koppla in routerns konfiguration
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
