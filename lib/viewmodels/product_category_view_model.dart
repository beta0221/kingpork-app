import 'package:tklab_ec_v2/models/product_line_model.dart';
import 'package:tklab_ec_v2/services/product_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// 產品分類 ViewModel
/// 管理 ProductCategoryScreen 的資料和狀態
class ProductCategoryViewModel extends BaseViewModel {
  final ProductService _productService;

  // 分類資料
  String _bannerUrl = '';
  List<ProductCategory> _categories = [];
  String _currentCategoryName = '';

  // 產品資料
  List<Product> _products = [];
  int? _currentCategoryId;
  bool _isLoadingProducts = false;

  // Getters - 分類相關
  String get bannerUrl => _bannerUrl;
  List<ProductCategory> get categories => _categories;
  String get currentCategoryName => _currentCategoryName;
  bool get hasData => _categories.isNotEmpty;
  bool get hasBanner => _bannerUrl.isNotEmpty;

  // Getters - 產品相關
  List<Product> get products => _products;
  int? get currentCategoryId => _currentCategoryId;
  bool get hasProducts => _products.isNotEmpty;
  bool get isLoadingProducts => _isLoadingProducts;

  ProductCategoryViewModel({ProductService? productService})
      : _productService = productService ?? ProductService(useLocalhost: false);

  /// 初始化產品分類資料
  ///
  /// [categoryName] 產品線名稱（例如：'electronics'）
  ///
  /// 流程：
  /// 1. 載入分類列表
  /// 2. 如果成功且有分類，自動載入第一個分類的產品
  Future<void> initialize(String categoryName) async {
    _currentCategoryName = categoryName;
    setLoading();

    try {
      // 步驟 1: 載入分類列表
      final response = await _productService.getProductCatList(categoryName);

      if (response.isSuccess) {
        _bannerUrl = response.bannerUrl;
        _categories = response.categoryList;

        // 步驟 2: 如果有分類，自動載入第一個分類的產品
        if (_categories.isNotEmpty) {
          final firstCategoryId = _categories[0].catId;
          await _loadProductsInternal(firstCategoryId);
        } else {
          // 沒有分類，但分類 API 成功
          setSuccess();
        }
      } else {
        setError(response.message.isNotEmpty ? response.message : '無法載入分類列表');
      }
    } catch (e) {
      setError('載入分類失敗: ${e.toString()}');
    }
  }

  /// 載入指定分類的產品（內部方法）
  ///
  /// 此方法不改變整體 ViewState，因為分類已經載入成功
  /// 只更新產品列表和 _isLoadingProducts 標記
  Future<void> _loadProductsInternal(int catId) async {
    _currentCategoryId = catId;
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final response = await _productService.getProductList(catId);

      if (response.isSuccess) {
        _products = response.productList;
        setSuccess(); // 整體狀態設為成功
      } else {
        // 產品載入失敗，但不影響分類顯示
        _products = [];
        setSuccess(); // 仍然顯示分類
      }
    } catch (e) {
      _products = [];
      setSuccess(); // 仍然顯示分類
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// 公開方法：切換分類並載入產品
  ///
  /// 用於點擊分類圖示時切換產品列表
  Future<void> loadProducts(int catId) async {
    if (_currentCategoryId == catId && _products.isNotEmpty) {
      // 已經載入過此分類，不重複請求
      return;
    }

    await _loadProductsInternal(catId);
  }

  /// 重新載入（供下拉刷新或錯誤重試使用）
  ///
  /// 同時刷新分類和產品
  Future<void> refresh() async {
    if (_currentCategoryName.isNotEmpty) {
      await initialize(_currentCategoryName);
    }
  }

  /// 選擇分類
  ///
  /// 當用戶點擊快速分類圖示時調用
  Future<void> selectCategory(ProductCategory category) async {
    await loadProducts(category.catId);
  }

  @override
  void dispose() {
    _productService.dispose();
    super.dispose();
  }
}
