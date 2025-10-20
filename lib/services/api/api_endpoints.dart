import 'package:tklab_ec_v2/config/flavor_config.dart';

/// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - 自動根據 Flavor 環境決定
  static String get baseUrl => FlavorConfig.instance.baseUrl;
  static const String apiPrefix = '/api/next';

  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String user = '/auth/user';
  static const String addresses = '/auth/addresses';

  // Landing Page Endpoints
  static const String categories = '/landing/categories';
  static const String banners = '/landing/banners';

  // Contact Endpoints
  static const String contact = '/contact';

  // Shop Endpoints
  static const String shopPaths = '/shop/paths';
  static String shopCategory(String slug) => '/shop/$slug';

  // Cart (Kart) Endpoints
  static const String kartItems = '/kart/items';
  static const String kartAdd = '/kart/add';
  static String kartRemove(int id) => '/kart/remove/$id';

  // Order (Bill) Endpoints
  static const String billCheckout = '/bill/checkout';
  static const String billList = '/bill/list';
  static String billDetail(int billId) => '/bill/detail/$billId';
  static String billToken(int billId) => '/bill/token/$billId';
  static String billPay(int billId) => '/bill/pay/$billId';

  // Helper method to build full URL
  static String buildUrl(String endpoint) => '$apiBaseUrl$endpoint';
}
