/// Cart item model
class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final String image;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'image': image,
    };
  }
}

/// Cart response model
class CartResponse {
  final List<CartItem> items;
  final double total;

  CartResponse({
    required this.items,
    required this.total,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
    );
  }

  /// Get total item count
  int get itemCount => items.length;

  /// Get total quantity
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);
}

/// Add to cart request model
class AddToCartRequest {
  final int productId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}

/// Add to cart response model
class AddToCartResponse {
  final String message;
  final CartItemData kartItem;

  AddToCartResponse({
    required this.message,
    required this.kartItem,
  });

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      message: json['message'] as String,
      kartItem:
          CartItemData.fromJson(json['kart_item'] as Map<String, dynamic>),
    );
  }
}

/// Cart item data (simplified version)
class CartItemData {
  final int id;
  final int productId;
  final int quantity;
  final double price;

  CartItemData({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    return CartItemData(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}
