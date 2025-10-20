import 'package:tklab_ec_v2/models/cart_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// Cart (Kart) service
class CartService {
  final ApiClient _apiClient;

  CartService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get cart items
  ///
  /// Example:
  /// ```dart
  /// final cart = await cartService.getCartItems();
  /// print('Total: \$${cart.total}');
  /// print('Items: ${cart.itemCount}');
  /// for (var item in cart.items) {
  ///   print('${item.productName} x ${item.quantity} = \$${item.subtotal}');
  /// }
  /// ```
  Future<CartResponse> getCartItems() async {
    final response = await _apiClient.get(ApiEndpoints.kartItems);
    return CartResponse.fromJson(response);
  }

  /// Add product to cart
  ///
  /// Example:
  /// ```dart
  /// final result = await cartService.addToCart(
  ///   productId: 10,
  ///   quantity: 2,
  /// );
  /// print(result.message); // "已加入購物車"
  /// ```
  Future<AddToCartResponse> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final request = AddToCartRequest(
      productId: productId,
      quantity: quantity,
    );

    final response = await _apiClient.post(
      ApiEndpoints.kartAdd,
      body: request.toJson(),
    );

    return AddToCartResponse.fromJson(response);
  }

  /// Remove item from cart
  ///
  /// Example:
  /// ```dart
  /// await cartService.removeFromCart(1);
  /// print('Item removed from cart');
  /// ```
  Future<Map<String, dynamic>> removeFromCart(int cartItemId) async {
    final response = await _apiClient.post(
      ApiEndpoints.kartRemove(cartItemId),
    );

    return response as Map<String, dynamic>;
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
