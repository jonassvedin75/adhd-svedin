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
  
  // Initialiserar Firebase med felhantering
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Fortsätt ändå - appen kan fungera offline
  }
  
  runApp(
    const ProviderScope(
      child: AdhdSupportApp(),
    ),
  );
}
