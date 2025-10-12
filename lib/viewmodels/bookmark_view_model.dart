import 'package:shop/models/api_category_model.dart';
import 'package:shop/services/shop_service.dart';
import 'package:shop/viewmodels/base_view_model.dart';

/// ViewModel for bookmark screen
class BookmarkViewModel extends BaseViewModel {
  final ShopService _shopService;

  List<ApiProduct> _products = [];
  ApiCategory? _category;

  List<ApiProduct> get products => _products;
  ApiCategory? get category => _category;

  BookmarkViewModel({ShopService? shopService})
      : _shopService = shopService ?? ShopService();

  /// Load products by category slug
  Future<void> loadProductsByCategory(String slug) async {
    setLoading();

    await handleError(
      () async {
        final result = await _shopService.getProductsByCategory(slug);
        _category = result.category;
        _products = result.products;
        setSuccess();
      },
      errorMessage: '載入書籤商品失敗',
    );
  }

  @override
  void dispose() {
    _shopService.dispose();
    super.dispose();
  }
}
