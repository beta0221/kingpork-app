import 'package:tklab_ec_v2/models/product_line_model.dart';
import 'package:tklab_ec_v2/services/product_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// 產品分類 ViewModel
/// 管理 ProductCategoryScreen 的資料和狀態
class ProductCategoryViewModel extends BaseViewModel {
  final ProductService _productService;

  // 資料
  String _bannerUrl = '';
  List<ProductCategory> _categories = [];
  String _currentCategoryName = '';

  // Getters
  String get bannerUrl => _bannerUrl;
  List<ProductCategory> get categories => _categories;
  String get currentCategoryName => _currentCategoryName;
  bool get hasData => _categories.isNotEmpty;
  bool get hasBanner => _bannerUrl.isNotEmpty;

  ProductCategoryViewModel({ProductService? productService})
      : _productService = productService ?? ProductService(useLocalhost: true);

  /// 初始化產品分類資料
  ///
  /// [categoryName] 產品線名稱（例如：'electronics'）
  Future<void> initialize(String categoryName) async {
    _currentCategoryName = categoryName;
    setLoading();

    try {
      final response = await _productService.getProductCatList(categoryName);

      if (response.isSuccess) {
        _bannerUrl = response.bannerUrl;
        _categories = response.categoryList;
        setSuccess();
      } else {
        setError(response.message.isNotEmpty ? response.message : '無法載入分類列表');
      }
    } catch (e) {
      setError('載入分類失敗: ${e.toString()}');
    }
  }

  /// 重新載入（供下拉刷新或錯誤重試使用）
  Future<void> refresh() async {
    if (_currentCategoryName.isNotEmpty) {
      await initialize(_currentCategoryName);
    }
  }

  /// 選擇分類（預留給未來使用）
  void selectCategory(ProductCategory category) {
    // 未來可在此處理分類選擇邏輯
    // 例如：導航到產品列表頁面
    notifyListeners();
  }

  @override
  void dispose() {
    _productService.dispose();
    super.dispose();
  }
}
