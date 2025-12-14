// lib/features/auth/login_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/features/auth/repositories/auth_repository.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
import 'package:pod/core/routing/navigation_extensions.dart';
import 'package:pod/core/utils/snackbar.dart';
import 'package:pod/core/di/locator.dart';

part 'login_controller.g.dart';

/// Login Controller - handles login business logic
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {
    // Initial state - not loading
  }

  /// Login with email, password, and account
  Future<void> login({
    required String email,
    required String password,
    required String account,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final prefs = await ref.read(sharedPrefsProvider.future);

      final resp = await authRepo.login(
        email: email.trim(),
        password: password,
        account: account.trim(),
      );

      if (!resp.success || resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception(resp.message ?? 'Login failed');
      }

      // Success: save login state
      await prefs.setLoggedIn(true);

      // Navigate to home and show success message
      final context = ref.read(navigatorKeyProvider).currentContext;
      if (context != null && context.mounted) {
        AppSnackBar.success(context, 'Login successful!');
        context.goToHome();
      }
    });
  }

  /// Logout user
  Future<void> logout() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final prefs = await ref.read(sharedPrefsProvider.future);
      await prefs.clearAll();

      final context = ref.read(navigatorKeyProvider).currentContext;
      if (context != null && context.mounted) {
        context.goToLogin();
      }
    });
  }
}
