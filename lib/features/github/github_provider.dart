import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pod/core/network/dio_provider.dart';
import 'models/github_user.dart';

final githubUserProvider =
    FutureProvider.family<GitHubUser, String>((ref, username) async {
  final dio = ref.read(dioProvider);

  final response = await dio.get('https://api.github.com/users/$username');

  if (response.statusCode != 200) {
    final message = response.data?['message'] ?? 'GitHub user not found';
    throw Exception(message);
  }

  final data = response.data as Map<String, dynamic>;
  return GitHubUser.fromJson(data);
});
