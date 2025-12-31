// lib/features/auth/repositories/auth_repository.dart
import 'package:pod/core/config/app_config.dart';
import 'package:pod/core/network/api_service_provider.dart';
import 'package:pod/features/auth/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  Future<UserModel> login({
    required String email,
    required String password,
    String account = 'user',
  }) async {
    return _api.post(
      AppConfig.login,
      data: {
        "email": email,
        "password": password,
        "account": account,
      },
      // Centralized parsing: ApiService calls this on the raw 'data' map
      fromJsonT: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.read(apiServiceProvider.notifier));
}
