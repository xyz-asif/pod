// lib/core/config/app_config.dart

enum Environment { dev, staging, prod }

class AppConfig {
  // Init once in main.dart
  static late Environment _env;

  static void init(Environment env) => _env = env;

  // Environment-specific base URLs
  static String get baseUrl {
    return switch (_env) {
      Environment.dev => 'http://128.199.21.237:7410/api/v1',
      Environment.staging => 'https://staging-api.yourapp.com/api/v1',
      Environment.prod => 'https://api.yourapp.com/api/v1',
    };
  }

  // Auth Endpoints
  static String get login => '/auth/login';
  static String get register => '/auth/register';
  static String get logout => '/auth/logout';
  static String get refreshToken => '/auth/refresh';

  // User Endpoints
  static String get me => '/user/me';
  static String get updateProfile => '/user/profile';
  static String get deleteAccount => '/user/account';

  // Product Endpoints
  static String get products => '/products';
  static String productDetail(String id) => '/products/$id';
  static String get createProduct => '/products';
  static String updateProduct(String id) => '/products/$id';
  static String deleteProduct(String id) => '/products/$id';

  // Order Endpoints
  static String get orders => '/orders';
  static String orderDetail(String id) => '/orders/$id';
  static String get createOrder => '/orders';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  // App Metadata
  static String get appName => 'Pod';
  static String get appVersion => '1.0.0';

  // Feature Flags
  static bool get isDebug => _env != Environment.prod;
  static bool get enableLogging => _env != Environment.prod;
  static bool get enableAnalytics => _env == Environment.prod;

  // Timeouts
  static const connectTimeout = Duration(seconds: 60);
  static const receiveTimeout = Duration(seconds: 60);
  static const sendTimeout = Duration(seconds: 60);

  // Pagination
  static const defaultPageSize = 20;
  static const maxPageSize = 100;

  // Cache
  static const defaultCacheDuration = Duration(minutes: 5);
  static const imageCacheDuration = Duration(hours: 24);

  // Current environment (useful for debugging)
  static String get environmentName => _env.name;
}
