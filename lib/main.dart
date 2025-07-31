import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ai_kodhjalp/firebase_options.dart';
import 'package:ai_kodhjalp/app/core/config/production_config.dart';
import 'package:ai_kodhjalp/app/core/ios/ios_security.dart';
import 'dart:io';

void main() async {
  // Säkerställer att all Flutter-bindning är initierad
  WidgetsFlutterBinding.ensureInitialized();
  
  // Konfigurera app för produktion
  ProductionConfig.configure();
  
  // Konfigurera iOS-specifik säkerhet
  if (Platform.isIOS) {
    iOSSecurityConfig.configure();
  }
  
  // Initialiserar Firebase med den autogenererade konfigurationen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AdhdSupportApp());
}
