// lib/core/config/app_config.dart
enum Environment { dev, staging, prod }

class AppConfig {
  // Init once in main.dart
  static late Environment _env;
  static void init(Environment env) => _env = env;

  // Base URL
  static String get baseUrl => 'http://128.199.21.237:7410/api/v1';

  // Endpoints — ALL IN ONE PLACE (this is where you add them!)
  static String get login => '/auth/login';
  static String get register => '/auth/register';
  static String get me => '/user/me';
  static String get products => '/products';
  static String productDetail(String id) => '/products/$id';
  static String get orders => '/orders';

  static String get appName => 'Pod';
  static bool get isDebug => _env != Environment.prod;
}