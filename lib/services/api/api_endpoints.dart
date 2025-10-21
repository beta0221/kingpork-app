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

  // Community Endpoints
  static const String communityPosts = '/community/posts';
  static const String communityPost = '/community/post';
  static String communityPostDetail(int postId) => '/community/post/$postId';
  static String communityPostLike(int postId) => '/community/post/$postId/like';
  static String communityPostComments(int postId) => '/community/post/$postId/comments';
  static String communityPostDelete(int postId) => '/community/post/$postId';

  // Chat Endpoints
  static const String chatMessages = '/chat/messages';
  static const String chatSend = '/chat/send';
  static const String chatRooms = '/chat/rooms';
  static String chatRoom(int roomId) => '/chat/room/$roomId';
  static String chatRoomMessages(int roomId) => '/chat/room/$roomId/messages';

  // Message/Notification Endpoints
  static const String messages = '/messages';
  static const String messageUnreadCount = '/messages/unread-count';
  static String messageRead(int messageId) => '/messages/$messageId/read';
  static String messageDelete(int messageId) => '/messages/$messageId';

  // Helper method to build full URL
  static String buildUrl(String endpoint) => '$apiBaseUrl$endpoint';
}
