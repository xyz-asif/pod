// lib/core/utils/snackbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pod/core/di/locator.dart';

class AppSnackBar {
  // From widgets (with context)
  static void warning(BuildContext context, String message) =>
      _show(context, message, Colors.orange);
  static void error(BuildContext context, String message) =>
      _show(context, message, Colors.red);
  static void success(BuildContext context, String message) =>
      _show(context, message, Colors.green);

  // From anywhere (notifiers, providers, background) — NO CONTEXT NEEDED
  static void globalWarning(WidgetRef ref, String message) =>
      _showGlobal(ref, message, Colors.orange);
  static void globalError(WidgetRef ref, String message) =>
      _showGlobal(ref, message, Colors.red);
  static void globalSuccess(WidgetRef ref, String message) =>
      _showGlobal(ref, message, Colors.green);

  static void _show(BuildContext context, String message, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void _showGlobal(WidgetRef ref, String message, Color color) {
    // Get the navigator key to access the context
    final navigatorKey = ref.read(navigatorKeyProvider);
    final context = navigatorKey.currentContext;

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }
}
