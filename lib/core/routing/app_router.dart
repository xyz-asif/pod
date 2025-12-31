// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/features/auth/login_screen.dart';
import 'package:pod/features/splash/splash_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/di/locator.dart';
import 'package:pod/core/routing/routes.dart';
import 'package:pod/core/theme/app_colors.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: Routes.splash,

    // ✅ FIXED: Auth redirect logic
    redirect: (context, state) async {
      final currentPath = state.matchedLocation;

      // ✅ CRITICAL: Always allow splash to show first
      if (currentPath == Routes.splash) {
        return null; // Let splash screen handle its own navigation
      }

      // Check auth state for other routes
      final prefs = await ref.read(sharedPrefsProvider.future);
      final isLoggedIn = await prefs.isLoggedIn();
      final isAuthRoute =
          currentPath == Routes.login || currentPath == Routes.register;

      // Redirect logic for protected routes
      if (!isLoggedIn && !isAuthRoute) {
        return Routes.login; // Not logged in → go to login
      }

      if (isLoggedIn && isAuthRoute) {
        return Routes.home; // Already logged in → go to home
      }

      return null; // No redirect needed
    },

    routes: [
      // ════════════════════════════════════════════════════════════════════
      // SPLASH SCREEN
      // ════════════════════════════════════════════════════════════════════
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ════════════════════════════════════════════════════════════════════
      // AUTH ROUTES
      // ════════════════════════════════════════════════════════════════════
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: Routes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ════════════════════════════════════════════════════════════════════
      // MAIN APP ROUTES
      // ════════════════════════════════════════════════════════════════════
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ════════════════════════════════════════════════════════════════════
      // PRODUCT ROUTES
      // ════════════════════════════════════════════════════════════════════
      GoRoute(
        path: Routes.products,
        name: 'products',
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

      // ════════════════════════════════════════════════════════════════════
      // ORDER ROUTES
      // ════════════════════════════════════════════════════════════════════
      GoRoute(
        path: Routes.orders,
        name: 'orders',
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

      // ════════════════════════════════════════════════════════════════════
      // PROFILE & SETTINGS
      // ════════════════════════════════════════════════════════════════════
      GoRoute(
        path: Routes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    // ERROR HANDLING
    // ════════════════════════════════════════════════════════════════════
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}

// ══════════════════════════════════════════════════════════════════════════
// ERROR SCREEN
// ══════════════════════════════════════════════════════════════════════════

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(height: 32),

              // Error Title
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error Message
              Text(
                error?.toString() ?? 'Page not found',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Go Home Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(Routes.home),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Go Back Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(Routes.home);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// PLACEHOLDER SCREENS (Replace with actual implementations)
// ══════════════════════════════════════════════════════════════════════════

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(
        child: Text('Register Screen - Coming Soon'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.products),
              child: const Text('Go to Products'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.orders),
              child: const Text('Go to Orders'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.profile),
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.shopping_bag),
              ),
              title: Text('Product ${index + 1}'),
              subtitle: Text('Tap to view details'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.go(Routes.productDetailPath('${index + 1}')),
            ),
          );
        },
      ),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 100, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Product $productId Details',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('This is a placeholder screen'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.receipt_long),
              ),
              title: Text('Order #${1000 + index}'),
              subtitle: Text('Tap to view details'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () =>
                  context.go(Routes.orderDetailPath('${1000 + index}')),
            ),
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #$orderId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 100, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Order #$orderId Details',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('This is a placeholder screen'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'john.doe@example.com',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(Routes.settings),
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              // TODO: Implement logout
              context.go(Routes.login);
            },
          ),
        ],
      ),
    );
  }
}
