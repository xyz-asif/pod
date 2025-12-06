// lib/core/network/interceptors/logging_interceptor.dart
import 'package:dio/dio.dart';
import 'package:pod/core/utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.i('REQUEST → ${options.method} ${options.uri}');
    Logger.i('Headers: ${options.headers}');
    if (options.data != null) Logger.i('Body: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.s('RESPONSE ← ${response.statusCode} ${response.realUri}');
    Logger.s('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.e(
        'ERROR ❌ ${err.response?.statusCode ?? err.type.name} ${err.requestOptions.uri}');
    Logger.e('Error Type: ${err.type}');
    Logger.e('Error Message: ${err.message}');
    Logger.e('Underlying error: ${err.error}');
    if (err.stackTrace != null) Logger.e('StackTrace: ${err.stackTrace}');
    if (err.response?.data != null)
      Logger.e('Error Data: ${err.response?.data}');
    super.onError(err, handler);
  }
}
