import 'package:dio/dio.dart';
import 'package:pod/core/config/app_config.dart';
import 'package:pod/core/network/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Auth API response model
class AuthResponse {
  final String token;
  final String? message;
  final bool success;

  AuthResponse({
    required this.token,
    this.message,
    required this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      message: json['message'] as String?,
      success: json['success'] as bool? ?? false,
    );
  }
}

/// Authentication Repository - handles all auth API calls
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Login with email and password
  /// Throws an exception with the server error message on failure
  Future<AuthResponse> login({
    required String email,
    required String password,
    String account = 'user',
  }) async {
    try {
      final response = await _dio.post(
        AppConfig.login,
        data: {
          "email": email,
          "password": password,
          "account": account,
        },
      );

      // Handle non-200 status codes
      if (response.statusCode != 200) {
        final errorMsg = response.data?['message'] ??
            'Login failed (${response.statusCode})';
        throw Exception(errorMsg);
      }

      // Parse and validate response
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('No token received from server');
      }

      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      // Dio-specific error handling
      final errorMsg =
          e.response?.data?['message'] ?? e.error?.toString() ?? 'Login failed';
      throw Exception(errorMsg);
    }
  }

  /// Register with email and password
  /// TODO: Implement when API endpoint is available
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    throw UnimplementedError('Register not yet implemented');
  }

  /// Forgot password
  /// TODO: Implement when API endpoint is available
  Future<void> forgotPassword({
    required String email,
  }) async {
    throw UnimplementedError('Forgot password not yet implemented');
  }
}

/// Riverpod provider for AuthRepository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
}
