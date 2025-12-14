// lib/core/routing/navigation_extensions.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/core/routing/routes.dart';


/// Extension methods for easy navigation
extension NavigationExtensions on BuildContext {
  // Basic navigation
  void goToHome() => go(Routes.home);
  void goToLogin() => go(Routes.login);
  void goToRegister() => go(Routes.register);
  void goToProfile() => go(Routes.profile);
  void goToSettings() => go(Routes.settings);
  void goToProducts() => go(Routes.products);
  void goToOrders() => go(Routes.orders);

  // Navigation with parameters
  void goToProductDetail(String id) => go(Routes.productDetailPath(id));
  void goToOrderDetail(String id) => go(Routes.orderDetailPath(id));

  // Push navigation (keeps previous screen in stack)
  void pushToProductDetail(String id) => push(Routes.productDetailPath(id));
  void pushToOrderDetail(String id) => push(Routes.orderDetailPath(id));

  // Pop navigation
  void goBack() => pop();
  void goBackWithResult<T>(T result) => pop(result);

  // Replace navigation (removes current screen)
  void replaceWithHome() => replace(Routes.home);
  void replaceWithLogin() => replace(Routes.login);
}

// ═══════════════════════════════════════════════════════════════════════════
// lib/core/routing/navigation_service.dart
// Navigation from anywhere without context (using Riverpod)
// ═══════════════════════════════════════════════════════════════════════════

class NavigationService {
  final Ref ref;

  NavigationService(this.ref);

  BuildContext? get context => ref.read(navigatorKeyProvider).currentContext;

  // Navigate methods
  void goToHome() => context?.go(Routes.home);
  void goToLogin() => context?.go(Routes.login);
  void goToProfile() => context?.go(Routes.profile);
  void goToProducts() => context?.go(Routes.products);

  void goToProductDetail(String id) =>
      context?.go(Routes.productDetailPath(id));
  void goToOrderDetail(String id) => context?.go(Routes.orderDetailPath(id));

  // Pop
  void goBack() => context?.pop();
  void goBackWithResult<T>(T result) => context?.pop(result);

  // Show dialogs
  Future<T?> showDialogCustom<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    if (context == null) {
      throw Exception('Navigation context is null');
    }
    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  // Show bottom sheet
  Future<T?> showBottomSheetCustom<T>({
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
  }) {
    if (context == null) {
      throw Exception('Navigation context is null');
    }
    return showModalBottomSheet<T>(
      context: context!,
      isDismissible: isDismissible,
      builder: builder,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// USAGE EXAMPLES
// ═══════════════════════════════════════════════════════════════════════════

/// Example 1: Navigation from Widget (with context)
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Simple navigation
        context.goToHome();

        // Navigation with parameter
        context.goToProductDetail('123');

        // Push (keeps previous screen)
        context.pushToProductDetail('123');

        // Go back
        context.goBack();
      },
      child: Text('Navigate'),
    );
  }
}

// Removed sample AuthNotifier - user prefers repository/provider without state classes.

// Removed ProductNotifier example.

/// Example 4: Waiting for navigation result
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Navigate and wait for result
        final result = await context.push<String>('/edit-product');

        if (result != null) {
          print('Product updated: $result');
        }
      },
      child: Text('Edit Product'),
    );
  }
}
