// lib/core/network/api_service_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pod/core/connectivity/connectivity_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/di/locator.dart'; // ← ADDED
import 'package:pod/core/error/failures.dart';
import 'package:pod/core/network/dio_provider.dart'; // ← ADDED

import 'package:pod/core/utils/snackbar.dart';

part 'api_service_provider.g.dart';

@riverpod
class ApiService extends _$ApiService {
  static const _maxRetries = 3;
  static const _retryDelay = Duration(seconds: 2);

  @override
  void build() {}

  // Fixed: now correctly reads dioProvider
  late final Dio _dio = ref.read(dioProvider);

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _call(() => _dio.get<T>(path,
          queryParameters: queryParameters, options: options));

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _call(() => _dio.post<T>(path,
          data: data, queryParameters: queryParameters, options: options));

  Future<T> _call<T>(Future<Response<T>> Function() request) async {
    Failure? lastFailure;

    for (int i = 0; i < _maxRetries; i++) {
      // CORRECT WAY — no more error
      final isConnected = await ref
          .read(connectivityStatusProvider.selectAsync((data) => data));

      if (!(isConnected as bool)) {
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
        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.data as T;
        }
        throw _mapStatusCode(response.statusCode!, response.data);
      } on DioException catch (e) {
        lastFailure = _mapDioError(e);
        if (_shouldRetry(e) && i < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
          continue;
        }
        rethrow;
      } catch (e) {
        throw lastFailure = UnknownFailure(e.toString());
      }
    }

    throw lastFailure!;
  }

  bool _shouldRetry(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      (e.response?.statusCode ?? 0) >= 500;

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

  Failure _mapStatusCode(int statusCode, dynamic data) {
    final message = data is Map ? data['message'] ?? data['error'] : null;
    return switch (statusCode) {
      400 => ServerFailure(message ?? 'Bad request', statusCode: 400),
      401 => UnauthorizedFailure(),
      403 => ServerFailure('Forbidden', statusCode: 403),
      404 => NotFoundFailure(),
      422 => ValidationFailure(message ?? 'Validation failed'),
      _ => ServerFailure(message ?? 'Server error', statusCode: statusCode),
    };
  }
}
