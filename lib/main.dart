import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_kodhjalp/firebase_options.dart';
import 'package:ai_kodhjalp/app/core/config/production_config.dart';
import 'package:ai_kodhjalp/app/core/ios/ios_security.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:developer' as developer;

void main() async {
  // Säkerställer att all Flutter-bindning är initierad
  WidgetsFlutterBinding.ensureInitialized();
  
  // Konfigurera app för produktion
  ProductionConfig.configure();
  
  // Konfigurera iOS-specifik säkerhet (endast på iOS)
  if (!kIsWeb && Platform.isIOS) {
    IosSecurityConfig.configure();
  }
  
  // Visa loading screen medan Firebase initialiseras
  runApp(const ProviderScope(child: LoadingApp()));
  
  // Initialiserar Firebase med felhantering
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('🎉 Firebase initialized successfully', name: 'main.dart');
    
    // Konfigurera Firestore settings för bättre prestanda och multi-tab support
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      developer.log('✅ Firestore settings configured successfully (persistence enabled)', name: 'main.dart');
    } catch (e) {
      developer.log('⚠️ Firestore settings configuration failed: $e', name: 'main.dart');
    }
    
    // Nu startar vi den riktiga appen
    runApp(
      const ProviderScope(
        child: AdhdSupportApp(),
      ),
    );
  } catch (e, s) {
    developer.log('❌ Firebase initialization error', name: 'main.dart', error: e, stackTrace: s);
    // Visa error screen istället för att krascha
    runApp(ProviderScope(child: ErrorApp(error: e.toString())));
  }
}

// Loading screen under Firebase-initialisering
class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
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
