import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:ai_kodhjalp/app/app_shell.dart';
import 'package:ai_kodhjalp/app/features/auth/login_screen.dart';
import 'package:ai_kodhjalp/app/features/auth/register_screen.dart';
import 'package:ai_kodhjalp/app/features/dashboard/dashboard_screen.dart';
import 'package:ai_kodhjalp/app/features/todo/todo_screen.dart';
import 'package:ai_kodhjalp/app/features/pomodoro/pomodoro_screen.dart';
import 'package:ai_kodhjalp/app/features/mood_tracker/mood_tracker_screen.dart';
import 'package:ai_kodhjalp/app/features/rewards/rewards_screen.dart';
import 'package:ai_kodhjalp/app/features/ai_coach/ai_coach_screen.dart';
import 'package:ai_kodhjalp/app/features/behavior_chain/behavior_chain_screen.dart';
import 'package:ai_kodhjalp/app/features/planning/planning_screen.dart';
import 'package:ai_kodhjalp/app/features/problem_solving/problem_solving_screen.dart';
import 'package:ai_kodhjalp/app/features/worry_tool/worry_tool_screen.dart';


final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/todo',
          builder: (context, state) => const TodoScreen(),
        ),
         GoRoute(
          path: '/planning',
          builder: (context, state) => const PlanningScreen(),
        ),
        GoRoute(
          path: '/pomodoro',
          builder: (context, state) => const PomodoroScreen(),
        ),
        // The "Kaos" route points to the WorryToolScreen
        GoRoute(
          path: '/kaos',
          builder: (context, state) => const WorryToolScreen(),
        ),
        GoRoute(
          path: '/mood',
          builder: (context, state) => const MoodTrackerScreen(),
        ),
        GoRoute(
          path: '/chain',
          builder: (context, state) => const BehaviorChainScreen(),
        ),
         GoRoute(
          path: '/solving',
          builder: (context, state) => const ProblemSolvingScreen(),
        ),
        // The old worry route is kept for now to avoid breaking anything, but /kaos is the new one
         GoRoute(
          path: '/worry',
          builder: (context, state) => const WorryToolScreen(),
        ),
        GoRoute(
          path: '/rewards',
          builder: (context, state) => const RewardsScreen(),
        ),
        GoRoute(
          path: '/coach',
          builder: (context, state) => const AiCoachScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!loggedIn) {
      return loggingIn ? null : '/login';
    }
    if (loggingIn) {
      // After login, always start at the first item in the bottom nav, which is To-Do
      return '/todo'; 
    }
    return null;
  },
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
