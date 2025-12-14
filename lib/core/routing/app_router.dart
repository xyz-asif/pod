// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/features/splash/splash_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/di/locator.dart';
import 'package:pod/core/routing/routes.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
import 'package:pod/features/auth/login_screen.dart';

// Import your screens here
// import 'package:pod/features/auth/presentation/screens/login_screen.dart';
// import 'package:pod/features/home/presentation/screens/home_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: Routes.splash,

    // Auth redirect logic
    redirect: (context, state) async {
      final prefs = await ref.read(sharedPrefsProvider.future);
      final isLoggedIn = await prefs.isLoggedIn();
      final isGoingToLogin = state.matchedLocation == Routes.login;
      final isGoingToRegister = state.matchedLocation == Routes.register;
      final isGoingToSplash = state.matchedLocation == Routes.splash;

      // If not logged in and not going to auth screens, redirect to login
      // (Allow the redirect even if the user is currently on the splash screen)
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return Routes.login;
      }

      // If logged in and going to login, redirect to home
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return Routes.home;
      }

      return null; // No redirect needed
    },

    routes: [
      // Splash Screen
      GoRoute(
        path: Routes.splash,
        name: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: Routes.login,
        name: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: Routes.register,
        name: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: Routes.home,
        name: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Product Routes
      GoRoute(
        path: Routes.products,
        name: Routes.products,
        builder: (context, state) => const ProductsScreen(),
        routes: [
          GoRoute(
            path: ':productId',
            name: Routes.productDetailName,
            builder: (context, state) {
              final id = state.pathParameters['productId']!;
              return ProductDetailScreen(productId: id);
            },
          ),
        ],
      ),

      // Order Routes
      GoRoute(
        path: Routes.orders,
        name: Routes.orders,
        builder: (context, state) => const OrdersScreen(),
        routes: [
          GoRoute(
            path: ':orderId',
            name: Routes.orderDetailName,
            builder: (context, state) {
              final id = state.pathParameters['orderId']!;
              return OrderDetailScreen(orderId: id);
            },
          ),
        ],
      ),

      // Profile Routes
      GoRoute(
        path: Routes.profile,
        name: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Settings
      GoRoute(
        path: Routes.settings,
        name: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}

// Routes are defined in lib/core/routing/routes.dart

// ═══════════════════════════════════════════════════════════════════════════
// PLACEHOLDER SCREENS (Replace these with your actual screens)
// ═══════════════════════════════════════════════════════════════════════════


// LoginScreen is provided by the auth feature in `lib/features/auth/login_screen.dart`

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(child: Text('Register Screen')),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Screen')),
    );
  }
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(child: Text('Products Screen')),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product $productId')),
      body: Center(child: Text('Product Detail: $productId')),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: const Center(child: Text('Orders Screen')),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order $orderId')),
      body: Center(child: Text('Order Detail: $orderId')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error?.toString() ?? 'Page not found',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
