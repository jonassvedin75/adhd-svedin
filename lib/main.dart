import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ai_kodhjalp/firebase_options.dart';
import 'package:ai_kodhjalp/app/core/config/production_config.dart';
import 'package:ai_kodhjalp/app/core/ios/ios_security.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

void main() async {
  // Säkerställer att all Flutter-bindning är initierad
  WidgetsFlutterBinding.ensureInitialized();
  
  // Konfigurera app för produktion
  ProductionConfig.configure();
  
  // Konfigurera iOS-specifik säkerhet (endast på iOS)
  if (!kIsWeb && Platform.isIOS) {
    iOSSecurityConfig.configure();
  }
  
  // Visa loading screen medan Firebase initialiseras
  runApp(const ProviderScope(child: LoadingApp()));
  
  // Initialiserar Firebase med felhantering
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🎉 Firebase initialized successfully');
    
    // Nu startar vi den riktiga appen
    runApp(
      const ProviderScope(
        child: AdhdSupportApp(),
      ),
    );
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    // Visa error screen istället för att krascha
    runApp(ProviderScope(child: ErrorApp(error: e.toString())));
  }
}

// Loading screen under Firebase-initialisering
class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Startar appen...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

// Error screen om Firebase-initialisering misslyckas
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Ett fel uppstod', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Error: $error', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Försök starta om appen
                    main();
                  },
                  child: const Text('Försök igen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
