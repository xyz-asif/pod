// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/features/auth/login_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/di/locator.dart';

part 'app_router.g.dart';

// Placeholder screens (you'll replace later)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home')));
}


// The router itself
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider); // ← Correct

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    routes: [
      /* your routes */
      // 1. Login Route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 2. Home/Main Route
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
