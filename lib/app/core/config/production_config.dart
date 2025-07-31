import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Produktionsanpassad error handling och logging
class ProductionConfig {
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  
  /// Konfigurera app för produktion
  static void configure() {
    if (isProduction) {
      // Inaktivera debug-banners
      _configureErrorHandling();
      _configureLogging();
    }
  }
  
  static void _configureErrorHandling() {
    // Global error handling för Flutter-fel
    FlutterError.onError = (FlutterErrorDetails details) {
      if (isProduction) {
        // I produktion: logga fel utan att visa dem
        _logError('Flutter Error', details.exception, details.stack);
      } else {
        // I utveckling: visa normala fel
        FlutterError.presentError(details);
      }
    };
    
    // Global error handling för Dart-fel
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Dart Error', error, stack);
      return true;
    };
  }
  
  static void _configureLogging() {
    // Konfigurera logging för produktion
    if (isProduction) {
      // I produktion: begränsa logging till konsolen
      // Vi kan inte reassigna print i Flutter web, så vi loggar till debugPrint istället
    }
  }
  
  static void _logError(String type, Object error, StackTrace? stack) {
    if (isDevelopment) {
      debugPrint('[$type] $error');
      if (stack != null) {
        debugPrint('Stack trace: $stack');
      }
    }
    
    // TODO: I framtiden kan vi integrera med Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }
  
  /// Logga användaraktiviteter (för analytics)
  static void logUserActivity(String activity, Map<String, dynamic>? parameters) {
    if (isDevelopment) {
      debugPrint('User Activity: $activity${parameters != null ? ' - $parameters' : ''}');
    }
    
    // TODO: Integrera med Firebase Analytics
    // FirebaseAnalytics.instance.logEvent(name: activity, parameters: parameters);
  }
  
  /// Konfigurera Performance Monitoring
  static void configurePerformance() {
    // TODO: Konfigurera Firebase Performance Monitoring
    // Om vi vill spåra prestanda i produktion
  }
}
