// lib/core/network/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:pod/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pod/core/network/api_endpoints.dart';
import 'package:pod/core/network/interceptors/logging_interceptor.dart';
import 'package:pod/core/utils/helpers/shared_prefs.dart';
part 'dio_provider.g.dart';

@riverpod
Dio dio(DioRef ref) {
  // Keep this provider alive to avoid closing the Dio adapter while
  // it's still in use by ongoing requests (prevents "adapter was closed" errors).
  ref.keepAlive();

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        // GitHub API prefers a user-agent and recommends explicit media type
        'User-Agent': 'pod-app',
        'Accept-Encoding': 'gzip, deflate',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Add your token/session refresh interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await ref.read(sharedPrefsProvider.future);
        final token = await prefs.getToken();
        final sessionId = await prefs.getSessionId();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (sessionId != null) {
          options.headers['sessionid'] = sessionId;
        }

        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // Auto-save new token/session from headers (exactly like your old code)
        final newToken = response.headers.value('token');
        final newSession = response.headers.value('sessionid');

        final prefs = await ref.read(sharedPrefsProvider.future);
        if (newToken != null) {
          await prefs.saveToken(newToken);
        }
        if (newSession != null) {
          await prefs.saveSessionId(newSession);
        }

        return handler.next(response);
      },
    ),
  );

  // Logging interceptor (pretty logs only in debug)
  dio.interceptors.add(LoggingInterceptor());

  // Keep ref to allow invalidation if needed
  ref.onDispose(() => dio.close());

  return dio;
}
