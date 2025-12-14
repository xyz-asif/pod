// lib/core/network/api_service_provider.dart
import 'package:dio/dio.dart';
// flutter/material import removed (unused)
import 'package:pod/core/connectivity/connectivity_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/di/locator.dart';
import 'package:pod/core/error/failures.dart';
import 'package:pod/core/network/dio_provider.dart';
import 'package:pod/core/utils/snackbar.dart';

part 'api_service_provider.g.dart';

@riverpod
class ApiService extends _$ApiService {
  static const _maxRetries = 3;
  static const _retryDelay = Duration(seconds: 2);

  @override
  void build() {}

  late final Dio _dio = ref.read(dioProvider);

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _call(() => _dio.get<T>(
            path,
            queryParameters: queryParameters,
            options: options,
          ));

  /// POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _call(() => _dio.post<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          ));

  /// PUT request (full replacement)
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _call(() => _dio.put<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          ));

  /// PATCH request (partial update)
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _call(() => _dio.patch<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          ));

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _call(() => _dio.delete<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          ));

  /// Core request handler with retry logic
  Future<T> _call<T>(Future<Response<T>> Function() request) async {
    Failure? lastFailure;

    for (int i = 0; i < _maxRetries; i++) {
      // Check connectivity
      // Use the notifier to get current connectivity status (returns Future<bool>)
      final isConnected =
          await ref.read(connectivityStatusProvider.notifier).isConnected;

      if (!isConnected) {
        lastFailure = const NetworkFailure();
        final context = ref.read(navigatorKeyProvider).currentContext;
        if (context != null && context.mounted) {
          AppSnackBar.warning(context, 'No internet connection');
        }
        if (i < _maxRetries - 1) await Future.delayed(_retryDelay);
        continue;
      }

      try {
        final response = await request();

        // Success responses
        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          return response.data as T;
        }

        // Map error responses
        throw _mapStatusCode(response.statusCode!, response.data);
      } on DioException catch (e) {
        lastFailure = _mapDioError(e);

        // Retry on specific errors
        if (_shouldRetry(e) && i < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
          continue;
        }

        // Throw a mapped Failure instead of rethrowing DioException
        throw lastFailure;
      } catch (e) {
        throw lastFailure = UnknownFailure(e.toString());
      }
    }

    throw lastFailure!;
  }

  /// Determine if request should be retried
  bool _shouldRetry(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      (e.response?.statusCode ?? 0) >= 500;

  /// Map Dio errors to Failures
  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        const ServerFailure('Request timeout', statusCode: 408),
      DioExceptionType.badResponse =>
        _mapStatusCode(e.response!.statusCode!, e.response!.data),
      _ => NetworkFailure(e.message),
    };
  }

  /// Map HTTP status codes to Failures
  Failure _mapStatusCode(int statusCode, dynamic data) {
    final message = data is Map ? data['message'] ?? data['error'] : null;
    return switch (statusCode) {
      400 => ServerFailure(message ?? 'Bad request', statusCode: 400),
      401 => const UnauthorizedFailure(),
      403 => const ServerFailure('Forbidden', statusCode: 403),
      404 => const NotFoundFailure(),
      422 => ValidationFailure(message ?? 'Validation failed'),
      _ => ServerFailure(message ?? 'Server error', statusCode: statusCode),
    };
  }
}
