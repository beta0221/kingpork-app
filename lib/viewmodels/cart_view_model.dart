import 'package:tklab_ec_v2/models/cart_models.dart';
import 'package:tklab_ec_v2/services/cart_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';
import 'package:tklab_ec_v2/utils/cart_storage_manager.dart';

/// CartViewModel manages shopping cart data and operations
class CartViewModel extends BaseViewModel {
  final CartService _cartService;
  final CartStorageManager _storageManager = CartStorageManager();

  CartResponse? _cart;

  CartResponse? get cart => _cart;
  int get itemCount => _cart?.itemCount ?? 0;
  double get total => _cart?.total ?? 0.0;
  bool get isEmpty => _cart == null || _cart!.items.isEmpty;
  List<CartItem> get items => _cart?.items ?? [];

  /// 取得已勾選的商品列表
  List<CartItem> get selectedItems =>
      items.where((item) => item.isSelected).toList();

  /// 計算已勾選商品的總金額
  double get selectedTotal => selectedItems.fold(
      0.0, (sum, item) => sum + (item.price * item.quantity));

  /// 檢查是否全選
  bool get isAllSelected => items.isNotEmpty && items.every((item) => item.isSelected);

  /// 檢查是否有任何商品被勾選
  bool get hasSelectedItems => items.any((item) => item.isSelected);

  CartViewModel({CartService? cartService})
      : _cartService = cartService ?? CartService();

  /// 從 localStorage 載入購物車資料
  Future<void> loadCart() async {
    setLoading();
    try {
      // 從 localStorage 讀取購物車資料
      final items = await _storageManager.loadCart();

      // 計算總金額
      final total = items.fold(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      _cart = CartResponse(items: items, total: total);
      setSuccess();
    } catch (e) {
      setError('載入購物車失敗: ${e.toString()}');
    }
  }

  /// Add product to cart
  Future<void> addToCart(int productId, int quantity) async {
    try {
      await _cartService.addToCart(
        productId: productId,
        quantity: quantity,
      );
      // Reload cart to get updated data
      await loadCart();
    } catch (e) {
      setError('加入購物車失敗: ${e.toString()}');
    }
  }

  /// 添加商品到購物車（支援 SKU）
  ///
  /// [productId] 產品 ID
  /// [productName] 產品名稱
  /// [price] 單價
  /// [quantity] 數量
  /// [image] 產品圖片 URL
  /// [skuId] SKU ID（可選）
  /// [skuName] SKU 名稱（可選）
  ///
  /// 如果購物車中已存在相同 productId + skuId 的商品，則累加數量
  /// 否則創建新的購物車項目
  Future<void> addToCartWithSku({
    required int productId,
    required String productName,
    required double price,
    required int quantity,
    required String image,
    String? skuId,
    String? skuName,
  }) async {
    try {
      _cart ??= CartResponse(items: [], total: 0.0);

      // 檢查是否已存在相同產品+SKU
      final existingIndex = _cart!.items.indexWhere(
        (item) =>
            item.productId == productId &&
            item.skuId == skuId, // SKU ID 相同（包括都是 null 的情況）
      );

      List<CartItem> updatedItems;

      if (existingIndex != -1) {
        // 已存在：累加數量
        final existingItem = _cart!.items[existingIndex];
        final newQuantity = existingItem.quantity + quantity;

        updatedItems = List.from(_cart!.items);
        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: newQuantity,
          subtotal: price * newQuantity,
        );
      } else {
        // 不存在：創建新項目
        final newItem = CartItem(
          id: DateTime.now().millisecondsSinceEpoch, // 使用時間戳作為唯一 ID
          productId: productId,
          productName: productName,
          price: price,
          quantity: quantity,
          subtotal: price * quantity,
          image: image,
          isSelected: true,
          skuId: skuId,
          skuName: skuName,
        );

        updatedItems = [..._cart!.items, newItem];
      }

      // 更新購物車
      _cart = _cart!.copyWith(items: updatedItems);
      _calculateTotal();

      // 保存到 localStorage
      await _storageManager.saveCart(_cart!.items);

      notifyListeners();
    } catch (e) {
      setError('加入購物車失敗: ${e.toString()}');
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    try {
      // Find and update the item locally first for immediate feedback
      if (_cart != null) {
        final index = _cart!.items.indexWhere((item) => item.id == cartItemId);
        if (index != -1) {
          _cart!.items[index] = _cart!.items[index].copyWith(quantity: quantity);
          _calculateTotal();
          notifyListeners();
        }
      }

      // Then sync with backend
      await _cartService.addToCart(
        productId: cartItemId,
        quantity: quantity,
      );
      await loadCart();
    } catch (e) {
      // Revert on error
      await loadCart();
      setError('更新數量失敗: ${e.toString()}');
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
      await loadCart();
    } catch (e) {
      setError('移除商品失敗: ${e.toString()}');
    }
  }

  /// 清空購物車
  Future<void> clearCart() async {
    if (_cart == null || _cart!.items.isEmpty) return;

    try {
      // 清空 localStorage
      await _storageManager.clearCart();

      // 清空內存中的資料
      _cart = CartResponse(items: [], total: 0.0);
      notifyListeners();
    } catch (e) {
      setError('清空購物車失敗: ${e.toString()}');
    }
  }

  /// Refresh cart data
  Future<void> refresh() async {
    await loadCart();
  }

  /// 切換單一商品的勾選狀態
  void toggleItemSelection(int cartItemId) async {
    if (_cart == null) return;

    final updatedItems = _cart!.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(isSelected: !item.isSelected);
      }
      return item;
    }).toList();

    _cart = _cart!.copyWith(items: updatedItems);
    notifyListeners();

    // 保存到 localStorage
    try {
      await _storageManager.saveCart(_cart!.items);
    } catch (e) {
      // ignore: avoid_print
      print('保存購物車失敗: ${e.toString()}');
    }
  }

  /// 全選或取消全選
  void toggleSelectAll() async {
    if (_cart == null || _cart!.items.isEmpty) return;

    final newSelectState = !isAllSelected;
    final updatedItems = _cart!.items
        .map((item) => item.copyWith(isSelected: newSelectState))
        .toList();

    _cart = _cart!.copyWith(items: updatedItems);
    notifyListeners();

    // 保存到 localStorage
    try {
      await _storageManager.saveCart(_cart!.items);
    } catch (e) {
      // ignore: avoid_print
      print('保存購物車失敗: ${e.toString()}');
    }
  }

  /// 更新商品數量（本地更新，用於即時 UI 反饋）
  void updateItemQuantity(int cartItemId, int quantity) async {
    if (_cart == null || quantity < 1) return;

    final updatedItems = _cart!.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(
          quantity: quantity,
          subtotal: item.price * quantity,
        );
      }
      return item;
    }).toList();

    _cart = _cart!.copyWith(items: updatedItems);
    _calculateTotal();
    notifyListeners();

    // 保存到 localStorage
    try {
      await _storageManager.saveCart(_cart!.items);
    } catch (e) {
      // ignore: avoid_print
      print('保存購物車失敗: ${e.toString()}');
    }
  }

  /// 刪除商品（本地刪除，用於即時 UI 反饋）
  void deleteItem(int cartItemId) async {
    if (_cart == null) return;

    final updatedItems =
        _cart!.items.where((item) => item.id != cartItemId).toList();

    _cart = _cart!.copyWith(items: updatedItems);
    _calculateTotal();
    notifyListeners();

    // 保存到 localStorage
    try {
      await _storageManager.saveCart(_cart!.items);
    } catch (e) {
      // ignore: avoid_print
      print('保存購物車失敗: ${e.toString()}');
    }
  }

  /// Calculate total price
  void _calculateTotal() {
    if (_cart == null) return;

    double newTotal = 0.0;
    for (final item in _cart!.items) {
      newTotal += item.price * item.quantity;
    }

    _cart = _cart!.copyWith(total: newTotal);
  }

  @override
  void dispose() {
    _cartService.dispose();
    super.dispose();
  }
}
