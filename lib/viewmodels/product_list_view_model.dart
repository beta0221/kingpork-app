import 'package:tklab_ec_v2/models/product_line_model.dart';
import 'package:tklab_ec_v2/services/product_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

class ProductListViewModel extends BaseViewModel {
  final ProductService _productService;

  // 產品線列表資料
  List<ProductLine> _productLines = [];

  // Getters
  List<ProductLine> get productLines => _productLines;
  bool get hasData => _productLines.isNotEmpty;

  ProductListViewModel({ProductService? productService})
      : _productService = productService ?? ProductService(useLocalhost: false);

  /// 初始化產品線列表
  Future<void> initialize() async {
    setLoading();
    try {
      final response = await _productService.getProductLineList();

      if (response.isSuccess && response.productLineList.isNotEmpty) {
        _productLines = response.productLineList;
        setSuccess();
      } else {
        setError(response.message.isNotEmpty ? response.message : '無法載入產品線列表');
      }
    } catch (e) {
      setError('載入產品線失敗: ${e.toString()}');
    }
  }

  /// 重新載入（供下拉刷新或錯誤重試使用）
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    _productService.dispose();
    super.dispose();
  }
}
