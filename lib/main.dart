import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_kodhjalp/firebase_options.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;

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
    if (kIsWeb) {
      await FirebaseFirestore.instance
          .enablePersistence(const PersistenceSettings(synchronizeTabs: true));
      developer.log('✅ Firestore persistence enabled for web with multi-tab sync', name: 'main.dart');
    } else {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
       developer.log('✅ Firestore persistence enabled for mobile', name: 'main.dart');
    }
  } catch (e) {
    developer.log('🔥 Error initializing Firebase: $e', name: 'main.dart', error: e);
  }

  runApp(const App());
}
