import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_kodhjalp/firebase_options.dart';
import 'dart:developer' as developer;

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('🎉 Firebase initialized successfully', name: 'main.dart');
    
    // Configure Firestore settings for better performance and multi-tab support
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
     developer.log('✅ Firestore settings configured', name: 'main.dart');

  } catch (e, s) {
    developer.log('❌ Firebase initialization error', name: 'main.dart', error: e, stackTrace: s);
    // You could run an error-specific app here if needed
  }
  
  // Run the main app with the new theme provider
  runApp(const MyApp());
}
