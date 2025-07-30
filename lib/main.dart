import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ai_kodhjalp/firebase_options.dart';

void main() async {
  // Säkerställer att all Flutter-bindning är initierad
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiserar Firebase med den autogenererade konfigurationen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdhdSupportApp());
}
