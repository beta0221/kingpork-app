/// Order (Bill) model
class Order {
  final int id;
  final String billNo;
  final String status;
  final double total;
  final String createdAt;
  final int itemsCount;

  Order({
    required this.id,
    required this.billNo,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.itemsCount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      billNo: json['bill_no'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: json['created_at'] as String,
      itemsCount: json['items_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_no': billNo,
      'status': status,
      'total': total,
      'created_at': createdAt,
      'items_count': itemsCount,
    };
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case 'paid':
        return '已付款';
      case 'pending':
        return '待付款';
      case 'cancelled':
        return '已取消';
      case 'shipped':
        return '已出貨';
      case 'completed':
        return '已完成';
      default:
        return status;
    }
  }
}

/// Order item model
class OrderItem {
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

/// Order detail model
class OrderDetail {
  final int id;
  final String billNo;
  final String status;
  final double total;
  final String recipient;
  final String phone;
  final String address;
  final List<OrderItem> items;
  final String createdAt;

  OrderDetail({
    required this.id,
    required this.billNo,
    required this.status,
    required this.total,
    required this.recipient,
    required this.phone,
    required this.address,
    required this.items,
    required this.createdAt,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as int,
      billNo: json['bill_no'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      recipient: json['recipient'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
    );
  }
}

/// Checkout request model
class CheckoutRequest {
  final String recipient;
  final String phone;
  final String city;
  final String district;
  final String address;
  final String paymentMethod;
  final int? useBonus;
  final String? note;

  CheckoutRequest({
    required this.recipient,
    required this.phone,
    required this.city,
    required this.district,
    required this.address,
    required this.paymentMethod,
    this.useBonus,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipient': recipient,
      'phone': phone,
      'city': city,
      'district': district,
      'address': address,
      'payment_method': paymentMethod,
      if (useBonus != null) 'use_bonus': useBonus,
      if (note != null) 'note': note,
    };
  }
}

/// Checkout response model
class CheckoutResponse {
  final int billId;
  final double total;
  final int bonusUsed;
  final double finalTotal;
  final String paymentUrl;

  CheckoutResponse({
    required this.billId,
    required this.total,
    required this.bonusUsed,
    required this.finalTotal,
    required this.paymentUrl,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      billId: json['bill_id'] as int,
      total: (json['total'] as num).toDouble(),
      bonusUsed: json['bonus_used'] as int,
      finalTotal: (json['final_total'] as num).toDouble(),
      paymentUrl: json['payment_url'] as String,
    );
  }
}

/// Payment token response model
class PaymentTokenResponse {
  final String token;
  final String paymentUrl;

  PaymentTokenResponse({
    required this.token,
    required this.paymentUrl,
  });

  factory PaymentTokenResponse.fromJson(Map<String, dynamic> json) {
    return PaymentTokenResponse(
      token: json['token'] as String,
      paymentUrl: json['payment_url'] as String,
    );
  }
}

/// Payment response model
class PaymentResponse {
  final bool success;
  final String paymentUrl;
  final int billId;

  PaymentResponse({
    required this.success,
    required this.paymentUrl,
    required this.billId,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] as bool,
      paymentUrl: json['payment_url'] as String,
      billId: json['bill_id'] as int,
    );
  }
}
