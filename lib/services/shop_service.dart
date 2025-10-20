import 'package:tklab_ec_v2/models/api_category_model.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// Shop service
class ShopService {
  final ApiClient _apiClient;

  ShopService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get category paths
  ///
  /// Example:
  /// ```dart
  /// final paths = await shopService.getCategoryPaths();
  /// for (var category in paths) {
  ///   print('${category.name} (${category.slug})');
  ///   if (category.parentId != null) {
  ///     print('  Parent ID: ${category.parentId}');
  ///   }
  /// }
  /// ```
  Future<List<ApiCategory>> getCategoryPaths() async {
    final response = await _apiClient.get(ApiEndpoints.shopPaths);

    return (response as List)
        .map((category) =>
            ApiCategory.fromJson(category as Map<String, dynamic>))
        .toList();
  }

  /// Get products by category slug
  ///
  /// Example:
  /// ```dart
  /// final result = await shopService.getProductsByCategory('pork');
  /// print('Category: ${result.category.name}');
  /// print('Products: ${result.products.length}');
  /// for (var product in result.products) {
  ///   print('${product.name}: \$${product.effectivePrice}');
  /// }
  /// ```
  Future<CategoryWithProducts> getProductsByCategory(String slug) async {
    final response =
        await _apiClient.get(ApiEndpoints.shopCategory(slug));

    return CategoryWithProducts.fromJson(response);
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
