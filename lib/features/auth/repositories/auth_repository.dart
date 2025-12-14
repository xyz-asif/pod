import 'package:dio/dio.dart';
import 'package:pod/core/config/app_config.dart';
import 'package:pod/core/network/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Generic login response model used by the API
class LoginResponse {
  final bool success;
  final int statusCode;
  final String? message;
  final dynamic data;
  final String? timestamp;
  final String? path;

  LoginResponse({
    required this.success,
    required this.statusCode,
    this.message,
    this.data,
    this.timestamp,
    this.path,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String?,
      data: json['data'],
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
    );
  }
}

/// Authentication Repository - handles all auth API calls
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Login with email and password
  /// Returns LoginResponse. Throws an exception for network / Dio errors
  Future<LoginResponse> login({
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
      final data = response.data as Map<String, dynamic>;
      final result = LoginResponse.fromJson(data);
      return result;
    } on DioException catch (e) {
      // Dio-specific error handling
      final errorMsg =
          e.response?.data?['message'] ?? e.error?.toString() ?? 'Login failed';
      throw Exception(errorMsg);
    }
  }

  /// Register with email and password
  /// TODO: Implement when API endpoint is available
  Future<LoginResponse> register({
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
