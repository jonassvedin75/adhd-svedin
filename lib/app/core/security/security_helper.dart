import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Säkerhetshjälpklasser för appen
class SecurityHelper {
  /// Validera att användaren är autentiserad
  static bool get isUserAuthenticated {
    return FirebaseAuth.instance.currentUser != null;
  }
  
  /// Hämta säker användar-ID
  static String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }
  
  /// Validera att data tillhör den inloggade användaren
  static bool validateUserOwnership(String? dataUserId) {
    final currentUser = currentUserId;
    if (currentUser == null || dataUserId == null) {
      return false;
    }
    return currentUser == dataUserId;
  }
  
  /// Rensa känslig data från minnet
  static void clearSensitiveData() {
    // Rensa eventuella cachade användardata
    // Detta kan utökas baserat på vad appen cachar
  }
  
  /// Validera email-format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validera lösenordsstyrka
  static bool isStrongPassword(String password) {
    // Minst 8 tecken, innehåller stora och små bokstäver, siffror
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }
  
  /// Sanitera text-input för att förhindra injection
  static String sanitizeInput(String input) {
    // Grundläggande sanering - kan utökas vid behov
    return input
        .replaceAll(RegExp(r'<script.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<.*?>', caseSensitive: false), '')
        .trim();
  }
  
  /// Logga säkerhetshändelser
  static void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    if (kDebugMode) {
      print('SECURITY EVENT: $event ${details != null ? '- $details' : ''}');
    }
    
    // I produktion skulle vi kunna skicka detta till en säkerhetslogg
    // eller Firebase Analytics med säkerhetstaggar
  }
}
