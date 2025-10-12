import 'package:shop/models/api_category_model.dart';
import 'package:shop/models/banner_model.dart';
import 'package:shop/services/api/api_client.dart';
import 'package:shop/services/api/api_endpoints.dart';

/// Landing page service
class LandingService {
  final ApiClient _apiClient;

  LandingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get categories for landing page
  ///
  /// Example:
  /// ```dart
  /// final categories = await landingService.getCategories();
  /// for (var category in categories) {
  ///   print('${category.name}: ${category.slug}');
  /// }
  /// ```
  Future<List<ApiCategory>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);

    return (response as List)
        .map((category) =>
            ApiCategory.fromJson(category as Map<String, dynamic>))
        .toList();
  }

  /// Get banners for landing page
  ///
  /// Example:
  /// ```dart
  /// final banners = await landingService.getBanners();
  /// for (var banner in banners) {
  ///   print('${banner.title}: ${banner.image}');
  /// }
  /// ```
  Future<List<BannerModel>> getBanners() async {
    final response = await _apiClient.get(ApiEndpoints.banners);

    return (response as List)
        .map((banner) => BannerModel.fromJson(banner as Map<String, dynamic>))
        .toList();
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
