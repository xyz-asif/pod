// lib/features/auth/views/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/features/github/github_provider.dart';
import 'package:pod/features/auth/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController(text: 'xyz-asif');
  String? _currentUsername;

  void _search() {
    final username = _controller.text.trim();
    if (username.isEmpty) return;
    setState(() {
      _currentUsername = username;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    AsyncValue? userValue;
    if (_currentUsername != null && _currentUsername!.isNotEmpty) {
      userValue = ref.watch(githubUserProvider(_currentUsername!));
    }

    // Show errors from GitHub fetch as snackbars
    if (userValue != null && userValue.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('Error: ${userValue!.error}'),
            backgroundColor: Colors.red,
          ));
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('GitHub User Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'GitHub Username'),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _search, child: const Text('Search')),
            const SizedBox(height: 20),
            if (userValue == null)
              const Center(child: Text('Enter a username and tap Search'))
            else
              userValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => const SizedBox.shrink(),
                data: (user) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(user.avatarUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name ?? user.login,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(user.bio ?? ''),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                children: [
                                  Text('Repos: ${user.publicRepos}'),
                                  Text('Followers: ${user.followers}'),
                                  Text('Following: ${user.following}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  // open profile in browser if needed
                                },
                                child: Text(user.htmlUrl,
                                    style: const TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
