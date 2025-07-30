import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Importera för StreamSubscription
import 'package:myapp/app/features/auth/login_screen.dart';
import 'package:myapp/app/features/auth/register_screen.dart';
import 'package:myapp/app/features/dashboard/dashboard_screen.dart';

final router = GoRouter(
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!loggedIn) {
      return loggingIn ? null : '/login';
    }

    if (loggingIn) {
      return '/dashboard';
    }

    return null;
  },
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    // Korrekt typ: StreamSubscription
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  // Korrekt typ: StreamSubscription
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
