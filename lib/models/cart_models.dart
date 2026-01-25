/// Cart item model
class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;           // 特價（實際售價）
  final double? originalPrice;  // 原價（可選，用於顯示折扣）
  final int quantity;
  final double subtotal;
  final String image;
  final bool isSelected;
  final String? skuId;      // SKU ID
  final String? skuName;    // SKU 名稱（例如：「紅色 L號」）

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    this.originalPrice,
    required this.quantity,
    required this.subtotal,
    required this.image,
    this.isSelected = true,
    this.skuId,
    this.skuName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      image: json['image'] as String,
      isSelected: json['is_selected'] as bool? ?? true,
      skuId: json['sku_id'] as String?,
      skuName: json['sku_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'original_price': originalPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'image': image,
      'is_selected': isSelected,
      'sku_id': skuId,
      'sku_name': skuName,
    };
  }

  /// Create a copy with optional new values
  CartItem copyWith({
    int? id,
    int? productId,
    String? productName,
    double? price,
    double? originalPrice,
    int? quantity,
    double? subtotal,
    String? image,
    bool? isSelected,
    String? skuId,
    String? skuName,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      image: image ?? this.image,
      isSelected: isSelected ?? this.isSelected,
      skuId: skuId ?? this.skuId,
      skuName: skuName ?? this.skuName,
    );
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

  /// Create a copy with optional new values
  CartResponse copyWith({
    List<CartItem>? items,
    double? total,
  }) {
    return CartResponse(
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
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
