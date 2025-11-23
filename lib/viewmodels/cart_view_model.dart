import 'package:tklab_ec_v2/models/cart_models.dart';
import 'package:tklab_ec_v2/services/cart_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// CartViewModel manages shopping cart data and operations
class CartViewModel extends BaseViewModel {
  final CartService _cartService;

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

  /// Load cart items (使用範例資料)
  Future<void> loadCart() async {
    setLoading();
    try {
      // 使用範例資料，不呼叫 API
      await Future.delayed(const Duration(milliseconds: 300));
      _cart = CartResponse(
        items: _demoCartItems,
        total: _demoCartItems.fold(
            0.0, (sum, item) => sum + (item.price * item.quantity)),
      );
      setSuccess();
    } catch (e) {
      setError('載入購物車失敗: ${e.toString()}');
    }
  }

  /// 範例購物車資料
  static final List<CartItem> _demoCartItems = [
    CartItem(
      id: 1,
      productId: 101,
      productName: '極致保濕精華液 30ml',
      price: 1280,
      quantity: 1,
      subtotal: 1280,
      image: 'https://img.tklab.com.tw/uploads/product/202509/5382_ffcc5cb7c3724d567d31bd452ecbe83e27af592b_s.webp',
    ),
    CartItem(
      id: 2,
      productId: 102,
      productName: '玻尿酸補水面膜 (5入)',
      price: 599,
      quantity: 2,
      subtotal: 1198,
      image: 'https://img.tklab.com.tw/uploads/product/202509/5384_f8bfca50ed8ad963618f88a27736c1a7afa9d9fb_m.webp',
    ),
    CartItem(
      id: 3,
      productId: 103,
      productName: '維他命C亮白精華 15ml',
      price: 890,
      quantity: 1,
      subtotal: 890,
      image: 'https://img.tklab.com.tw/uploads/product/202509/5388_790617a1b212f0095ee92e644fda1c7494c3c2cc_m.webp',
    ),
  ];

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

  /// Clear all items from cart
  Future<void> clearCart() async {
    if (_cart == null || _cart!.items.isEmpty) return;

    try {
      // Remove all items one by one
      for (final item in _cart!.items) {
        await _cartService.removeFromCart(item.id);
      }
      await loadCart();
    } catch (e) {
      setError('清空購物車失敗: ${e.toString()}');
    }
  }

  /// Refresh cart data
  Future<void> refresh() async {
    await loadCart();
  }

  /// 切換單一商品的勾選狀態
  void toggleItemSelection(int cartItemId) {
    if (_cart == null) return;

    final updatedItems = _cart!.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(isSelected: !item.isSelected);
      }
      return item;
    }).toList();

    _cart = _cart!.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// 全選或取消全選
  void toggleSelectAll() {
    if (_cart == null || _cart!.items.isEmpty) return;

    final newSelectState = !isAllSelected;
    final updatedItems = _cart!.items
        .map((item) => item.copyWith(isSelected: newSelectState))
        .toList();

    _cart = _cart!.copyWith(items: updatedItems);
    notifyListeners();
  }

  /// 更新商品數量（本地更新，用於即時 UI 反饋）
  void updateItemQuantity(int cartItemId, int quantity) {
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
  }

  /// 刪除商品（本地刪除，用於即時 UI 反饋）
  void deleteItem(int cartItemId) {
    if (_cart == null) return;

    final updatedItems =
        _cart!.items.where((item) => item.id != cartItemId).toList();

    _cart = _cart!.copyWith(items: updatedItems);
    _calculateTotal();
    notifyListeners();
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
