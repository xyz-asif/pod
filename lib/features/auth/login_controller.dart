// lib/features/auth/login_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/features/auth/repositories/auth_repository.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
import 'package:pod/features/auth/models/user_model.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  // ✅ The build method defines the 'state' type.
  // It returns FutureOr<UserModel?> so 'state' is AsyncValue<UserModel?>
  @override
  FutureOr<UserModel?> build() => null;

  Future<void> login({
    required String email,
    required String password,
    required String account,
  }) async {
    state = const AsyncValue.loading();

    // ✅ AsyncValue.guard expects a return type that matches the state (UserModel?)
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final prefs = await ref.read(sharedPrefsProvider.future);

      final user = await authRepo.login(
        email: email.trim(),
        password: password,
        account: account.trim(),
      );

      await prefs.setLoggedIn(true);

      return user; // Returning user here updates state.value
    });
  }
}
