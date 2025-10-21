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

  CartViewModel({CartService? cartService})
      : _cartService = cartService ?? CartService();

  /// Load cart items from API
  Future<void> loadCart() async {
    setLoading();
    try {
      _cart = await _cartService.getCartItems();
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
