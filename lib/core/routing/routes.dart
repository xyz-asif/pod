// lib/core/routing/routes.dart
class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const products = '/products';
  // Path segment for product detail (used for nested routes)
  static const productDetail = '/products/:productId';
  // Unique route name for product detail (full path becomes /products/:id)
  static const productDetailName = 'product_detail';
  static const orders = '/orders';
  // Path segment for order detail (used for nested routes)
  static const orderDetail = '/orders/:orderId';
  // Unique route name for order detail (full path becomes /orders/:id)
  static const orderDetailName = 'order_detail';
  static const profile = '/profile';
  static const settings = '/settings';

  static String productDetailPath(String id) => '/products/$id';
  static String orderDetailPath(String id) => '/orders/$id';
}
