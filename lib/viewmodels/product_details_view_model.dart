import 'package:tklab_ec_v2/models/product_detail_model.dart';
import 'package:tklab_ec_v2/services/product_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// 產品詳情 ViewModel
/// 管理 ProductDetailsScreen 的資料和狀態
class ProductDetailsViewModel extends BaseViewModel {
  final ProductService _productService;

  // 產品資料
  ProductDetail? _productDetail;
  List<RelatedProduct> _relatedProducts = [];
  int _currentId = 0;

  // Getters - 產品詳情相關
  ProductDetail? get productDetail => _productDetail;
  List<RelatedProduct> get relatedProducts => _relatedProducts;
  int get currentId => _currentId;

  // 便利查詢方法
  bool get hasProductDetail => _productDetail != null;
  bool get hasRelatedProducts => _relatedProducts.isNotEmpty;
  bool get hasImages => _productDetail?.hasImages ?? false;

  ProductDetailsViewModel({ProductService? productService})
      : _productService = productService ?? ProductService(useLocalhost: true);

  /// 初始化產品詳情資料
  ///
  /// [id] 產品 ID
  ///
  /// 流程：
  /// 1. 設置載入狀態
  /// 2. 調用 API 獲取產品詳情和相關產品
  /// 3. 解析並設置資料
  /// 4. 設置成功狀態
  Future<void> initialize(int id) async {
    _currentId = id;
    setLoading();

    try {
      // 調用 API 獲取產品詳情
      final response = await _productService.getProductDetail(id);

      if (response.isSuccess) {
        _productDetail = response.productDetail;
        _relatedProducts = response.relatedProducts;
        setSuccess();
      } else {
        setError(response.message.isNotEmpty ? response.message : '無法載入產品詳情');
      }
    } catch (e) {
      setError('很抱歉，此商品已下架。');
    }
  }

  /// 重新載入（供下拉刷新或錯誤重試使用）
  ///
  /// 重新載入當前 ID 的產品詳情
  Future<void> refresh() async {
    if (_currentId != 0) {
      await initialize(_currentId);
    }
  }

  /// 清除資料
  ///
  /// 在離開頁面時可以調用此方法清除資料
  void clear() {
    _productDetail = null;
    _relatedProducts = [];
    _currentId = 0;
    setIdle();
  }

  @override
  void dispose() {
    _productService.dispose();
    super.dispose();
  }
}
