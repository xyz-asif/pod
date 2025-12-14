// lib/core/network/interceptors/logging_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pod/core/utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      Logger.i('┌─────────────────────────────────────────────');
      Logger.i('│ REQUEST');
      Logger.i('├─────────────────────────────────────────────');
      Logger.i('│ ${options.method} ${options.uri}');

      if (options.headers.isNotEmpty) {
        Logger.i('│ Headers:');
        options.headers.forEach((key, value) {
          final lowerKey = key.toLowerCase();
          if (lowerKey == 'authorization') {
            Logger.i('│   $key: ${_maskToken(value.toString())}');
          } else {
            Logger.i('│   $key: $value');
          }
        });
      }

      if (options.queryParameters.isNotEmpty) {
        Logger.i('│ Query Params: ${options.queryParameters}');
      }

      if (options.data != null) Logger.i('│ Body: ${options.data}');
      Logger.i('└─────────────────────────────────────────────');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      Logger.s('┌─────────────────────────────────────────────');
      Logger.s('│ RESPONSE');
      Logger.s('├─────────────────────────────────────────────');
      Logger.s(
          '│ ${response.requestOptions.method} ${response.requestOptions.uri}');
      Logger.s(
          '│ Status: ${response.statusCode} ${response.statusMessage ?? ''}');

      if (response.headers.map.isNotEmpty) {
        Logger.s('│ Headers:');
        response.headers.map.forEach((key, value) {
          Logger.s('│   $key: $value');
        });
      }

      Logger.s('│ Data: ${response.data}');
      Logger.s('└─────────────────────────────────────────────');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      Logger.e('┌─────────────────────────────────────────────');
      Logger.e('│ ERROR');
      Logger.e('├─────────────────────────────────────────────');
      Logger.e('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
      Logger.e('│ Type: ${err.type}');
      Logger.e('│ Status: ${err.response?.statusCode ?? err.type.name}');
      Logger.e('│ Message: ${err.message}');
      if (err.error != null) Logger.e('│ Underlying error: ${err.error}');
      Logger.e('│ StackTrace: ${err.stackTrace}');
      if (err.response?.data != null) Logger.e('│ Data: ${err.response?.data}');
      Logger.e('└─────────────────────────────────────────────');
    }
    super.onError(err, handler);
  }

  String _maskToken(String token) {
    if (token.length <= 8) return '***';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }
}
