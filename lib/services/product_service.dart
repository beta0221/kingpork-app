import 'package:dio/dio.dart';
import 'package:tklab_ec_v2/models/product_line_model.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// 產品服務
class ProductService {
  final bool useLocalhost;
  final ApiClient? _apiClient;
  final Dio? _dio;

  ProductService({
    ApiClient? apiClient,
    Dio? dio,
    this.useLocalhost = false, // 設為 true 使用 localhost，false 使用 FlavorConfig
  })  : _apiClient = useLocalhost ? null : (apiClient ?? ApiClient()),
        _dio = useLocalhost ? (dio ?? _createLocalDio()) : null;

  /// 創建配置 localhost 的 Dio 實例
  static Dio _createLocalDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8081/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// 取得產品線列表
  ///
  /// 範例:
  /// ```dart
  /// // 使用 FlavorConfig 環境（預設）
  /// final productService = ProductService();
  /// final response = await productService.getProductLineList();
  ///
  /// // 使用 localhost
  /// final localService = ProductService(useLocalhost: true);
  /// final response = await localService.getProductLineList();
  ///
  /// if (response.isSuccess) {
  ///   for (var line in response.productLineList) {
  ///     print('${line.name}: ${line.url}');
  ///   }
  /// } else {
  ///   print('錯誤: ${response.message}');
  /// }
  /// ```
  Future<ProductLineListResponse> getProductLineList() async {
    if (useLocalhost) {
      // Localhost 模式
      try {
        final response = await _dio!.get('/product/line-list');
        return ProductLineListResponse.fromJson(response.data);
      } on DioException catch (e) {
        throw Exception('API 請求失敗: ${e.message}');
      }
    } else {
      // FlavorConfig 模式（正式環境）
      final response = await _apiClient!.get(ApiEndpoints.productLineList);
      return ProductLineListResponse.fromJson(response);
    }
  }

  /// 取得產品分類列表
  ///
  /// [name] 產品線名稱
  ///
  /// 範例:
  /// ```dart
  /// // 使用 FlavorConfig 環境（預設）
  /// final productService = ProductService();
  /// final response = await productService.getProductCatList('electronics');
  ///
  /// // 使用 localhost
  /// final localService = ProductService(useLocalhost: true);
  /// final response = await localService.getProductCatList('electronics');
  ///
  /// if (response.isSuccess) {
  ///   for (var category in response.productCategoryList) {
  ///     print('${category.name}: ${category.url}');
  ///   }
  /// } else {
  ///   print('錯誤: ${response.message}');
  /// }
  /// ```
  Future<ProductCategoryListResponse> getProductCatList(String name) async {
    if (useLocalhost) {
      // Localhost 模式
      try {
        final response = await _dio!.get('/product/category-list/$name');
        return ProductCategoryListResponse.fromJson(response.data);
      } on DioException catch (e) {
        throw Exception('API 請求失敗: ${e.message}');
      }
    } else {
      // FlavorConfig 模式（正式環境）
      final response = await _apiClient!.get(ApiEndpoints.productCategoryList(name));
      return ProductCategoryListResponse.fromJson(response);
    }
  }

  /// 釋放資源
  void dispose() {
    _apiClient?.dispose();
    _dio?.close();
  }
}
