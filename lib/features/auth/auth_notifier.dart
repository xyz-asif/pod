// lib/features/auth/providers/auth_notifier.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
import 'package:pod/features/auth/repositories/auth_repository.dart';

part 'auth_notifier.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<bool> build() async {
    // Auto check if already logged in
    final prefs = await ref.watch(sharedPrefsProvider.future);
    final token = await prefs.getToken();
    return token != null && token.isNotEmpty;
  }

  final emailController = TextEditingController(text: 'user@example.com');
  final passwordController = TextEditingController(text: 'anyPassword123');

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    state = const AsyncLoading();

    final authRepo = ref.read(authRepositoryProvider);
    final result = await AsyncValue.guard(
        () => authRepo.login(email: email, password: password));

    if (result case AsyncData(:final value)) {
      // Save token and mark as logged in
      final prefs = await ref.read(sharedPrefsProvider.future);
      await prefs.saveToken(value.token);
      await prefs.setLoggedIn(true);
      state = const AsyncData(true);
    } else {
      // Error is automatically captured by AsyncValue.guard
      state = result.whenData((_) => false);
    }
  }

  Future<void> logout() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.clearAll();
    state = const AsyncData(false);
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
