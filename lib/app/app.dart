import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';
import 'package:ai_kodhjalp/app/router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdhdSupportApp extends StatelessWidget {
  const AdhdSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ADHD Stöd',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Add error handling
      builder: (context, child) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Show loading during initial auth check
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Laddar ADHD Stöd...'),
                      ],
                    ),
                  ),
                ),
              );
            }
            
            // Return the normal app
            return child ?? const SizedBox();
          },
        );
      },
    );
  }
}
