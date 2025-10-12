import 'package:shop/models/api_category_model.dart';
import 'package:shop/models/banner_model.dart';
import 'package:shop/services/landing_service.dart';
import 'package:shop/services/shop_service.dart';
import 'package:shop/viewmodels/base_view_model.dart';

/// HomeViewModel manages data and state for HomeScreen
class HomeViewModel extends BaseViewModel {
  final LandingService _landingService;
  final ShopService _shopService;

  // Data
  List<BannerModel> _banners = [];
  List<ApiCategory> _categories = [];
  List<ApiProduct> _products = [];
  String? _selectedCategorySlug;

  HomeViewModel({
    LandingService? landingService,
    ShopService? shopService,
  })  : _landingService = landingService ?? LandingService(),
        _shopService = shopService ?? ShopService();

  // Getters
  List<BannerModel> get banners => _banners;
  List<ApiCategory> get categories => _categories;
  List<ApiProduct> get products => _products;
  String? get selectedCategorySlug => _selectedCategorySlug;

  /// Initialize home screen data
  Future<void> initialize() async {
    setLoading();

    try {
      // Load banners and categories first
      await Future.wait([
        _loadBanners(),
        _loadCategories(),
      ]);

      // Load products from first category if available
      await loadProductsByCategory('C');

      setSuccess();
    } catch (e) {
      setError('載入資料失敗: ${e.toString()}');
    }
  }

  /// Load banners from API
  Future<void> _loadBanners() async {
    try {
      _banners = await _landingService.getBanners();
    } catch (e) {
      // Log error but don't fail the whole initialization
      print('載入 banners 失敗: $e');
      _banners = [];
    }
  }

  /// Load categories from API
  Future<void> _loadCategories() async {
    try {
      _categories = await _landingService.getCategories();
    } catch (e) {
      // Log error but don't fail the whole initialization
      print('載入 categories 失敗: $e');
      _categories = [];
    }
  }

  /// Load products by category slug
  Future<void> loadProductsByCategory(String categorySlug) async {
    try {
      _selectedCategorySlug = categorySlug;
      final result = await _shopService.getProductsByCategory(categorySlug);
      _products = result.products;
      notifyListeners();
    } catch (e) {
      print('載入產品失敗: $e');
      _products = [];
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    _landingService.dispose();
    _shopService.dispose();
    super.dispose();
  }
}
