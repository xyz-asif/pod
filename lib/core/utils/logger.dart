// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';

class Logger {
  static void i(String message) {
    if (kDebugMode) print('ℹ️  $message');
  }

  static void s(String message) {
    if (kDebugMode) print('✅ $message');
  }

  static void e(String message) {
    if (kDebugMode) print('❌ $message');
  }

  static void w(String message) {
    if (kDebugMode) print('⚠️  $message');
  }
}