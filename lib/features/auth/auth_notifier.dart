// lib/features/auth/providers/auth_notifier.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pod/core/utils/snackbar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/network/dio_provider.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';

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

  final emailController = TextEditingController(text: 'xyz-asif');
  final passwordController = TextEditingController(text: 'anyPassword123');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login() async {
    _isLoading = true;
    state = const AsyncLoading();

    try {
      final username = emailController.text.trim();
      final response = await ref.read(dioProvider).get(
            'https://api.github.com/users/$username',
            options: Options(
              headers: {
                'accept': 'application/json',
              },
              responseType: ResponseType.json,
              validateStatus: (status) => status != null && status < 500,
            ),
          );

      // print('SUCCESS: ${response.statusCode}');
      // print('Response body: ${response.data}');

      if (response.statusCode == 200 && response.data['login'] != null) {
        // Simulate login success by saving username as token
        await ref.read(sharedPrefsProvider.future).then((prefs) async {
          await prefs.saveToken(response.data['login']);
          await prefs.setLoggedIn(true);
        });
        state = const AsyncData(true);
        // AppSnackBar.globalSuccess(ref, 'GitHub user found!');
      } else {
        throw Exception('GitHub user not found');
      }
    } on DioException catch (e) {
      String msg;
      // More precise handling depending on Dio exception type
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          msg = 'Request timed out';
          break;
        case DioExceptionType.connectionError:
          msg = 'Connection error: ${e.error ?? 'Check your network'}';
          break;
        case DioExceptionType.badResponse:
          msg = e.response?.data?['message'] ??
              'Server error: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          msg = 'Request cancelled';
          break;
        case DioExceptionType.unknown:
        default:
          // If there's no response, surface the underlying error if available
          msg = e.error?.toString() ?? 'Unknown network error';
      }
      print(
          'DioException: type=${e.type} error=${e.error} response=${e.response}');
      state = AsyncError(msg, StackTrace.current);
      // AppSnackBar.globalError(ref, msg);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
      // AppSnackBar.globalError(ref, 'Unexpected error');
    } finally {
      _isLoading = false;
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
