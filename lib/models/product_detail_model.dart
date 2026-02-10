/// 產品詳情 model
class ProductDetail {
  final int id;
  final String brand;
  final String title;
  final String description;
  final double price;
  final double dealPrice;
  final bool isAvailable;
  final double rating;
  final int numOfReviews;
  final List<String> images;
  final List<Sku> skuList;

  ProductDetail({
    required this.id,
    required this.brand,
    required this.title,
    required this.description,
    required this.price,
    this.dealPrice = 0.0,
    required this.isAvailable,
    required this.rating,
    required this.numOfReviews,
    required this.images,
    required this.skuList
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] as int,
      brand: json['brand'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _parsePrice(json['price']),
      dealPrice: _parsePrice(json['dealPrice']),
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: _parseDouble(json['rating']),
      numOfReviews: json['numOfReviews'] as int? ?? 0,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      skuList: (json['skuList'] as List?)
              ?.map((item) => Sku.fromJson(item as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  /// 從 API 回應的 data item 建立 ProductDetail
  factory ProductDetail.fromApiData(Map<String, dynamic> json, List<Sku> skuList) {
    return ProductDetail(
      id: json['Pid'] as int,
      brand: '',
      title: json['PTitle'] as String? ?? '',
      description: json['PDescription'] as String? ?? '',
      price: _parsePrice(json['PPrice']),
      dealPrice: _parsePrice(json['PDealPrice']),
      isAvailable: (json['PStock'] as int? ?? 0) > 0,
      rating: 0.0,
      numOfReviews: 0,
      images: (json['PFront_photo'] as List?)?.map((e) => e.toString()).toList() ?? [],
      skuList: skuList,
    );
  }

  /// 解析價格，支援多種格式（String/int/double/null）
  static double _parsePrice(dynamic value) {
    if (value == null || value == '') return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');
      try {
        return double.parse(cleaned);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  /// 解析 double，支援多種格式
  static double _parseDouble(dynamic value) {
    if (value == null || value == '') return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'title': title,
      'description': description,
      'price': price,
      'dealPrice': dealPrice,
      'isAvailable': isAvailable,
      'rating': rating,
      'numOfReviews': numOfReviews,
      'images': images,
      'skuList': skuList
    };
  }

  /// 是否有圖片
  bool get hasImages => images.isNotEmpty;

  /// 主圖片
  String get primaryImage => images.isNotEmpty ? images[0] : '';
}

/// 相關產品 model
class RelatedProduct {
  final int id;
  final String title;
  final String brandName;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final String image;

  RelatedProduct({
    required this.id,
    required this.title,
    required this.brandName,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    required this.image,
  });

  factory RelatedProduct.fromJson(Map<String, dynamic> json) {
    return RelatedProduct(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      brandName: json['brandName'] as String? ?? '',
      price: _parsePrice(json['price']),
      priceAfterDiscount: json['priceAfterDiscount'] != null ? _parsePrice(json['priceAfterDiscount']) : null,
      discountPercent: json['discountPercent'] as int?,
      image: json['image'] as String? ?? '',
    );
  }

  /// 解析價格，支援多種格式（String/int/double/null）
  static double _parsePrice(dynamic value) {
    if (value == null || value == '') return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');
      try {
        return double.parse(cleaned);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brandName': brandName,
      'price': price,
      'priceAfterDiscount': priceAfterDiscount,
      'discountPercent': discountPercent,
      'image': image,
    };
  }

  /// 是否有折扣
  bool get hasDiscount => priceAfterDiscount != null && priceAfterDiscount! < price;

  /// 有效價格（有折扣時返回折扣價，否則返回原價）
  double get effectivePrice => hasDiscount ? priceAfterDiscount! : price;
}

class Sku {
  final String id;
  final String name;
  final double price;
  final double dealPrice;
  final int stock;
  final String partNo;

  Sku({
    required this.id,
    required this.name,
    this.price = 0.0,
    this.dealPrice = 0.0,
    this.stock = 0,
    this.partNo = '',
  });

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  /// 從 API 回應的 data item 建立 Sku
  factory Sku.fromApiData(Map<String, dynamic> json) {
    return Sku(
      id: (json['PSpecID']).toString(),
      name: json['PSpecName'] as String? ?? '',
      price: ProductDetail._parsePrice(json['PPrice']),
      dealPrice: ProductDetail._parsePrice(json['PDealPrice']),
      stock: json['PStock'] as int? ?? 0,
      partNo: json['PPart'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'dealPrice': dealPrice,
      'stock': stock,
      'partNo': partNo,
    };
  }
}

/// 產品詳情回應
class ProductDetailResponse {
  final int status;
  final String message;
  final ProductDetail productDetail;
  final List<RelatedProduct> relatedProducts;

  ProductDetailResponse({
    required this.status,
    required this.message,
    required this.productDetail,
    required this.relatedProducts,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List;
    final firstItem = dataList.first as Map<String, dynamic>;

    // 從所有 items 建立 skuList
    final skuList = dataList
        .map((item) => Sku.fromApiData(item as Map<String, dynamic>))
        .toList();

    return ProductDetailResponse(
      status: json['s'] as int,
      message: json['msg'] as String? ?? '',
      productDetail: ProductDetail.fromApiData(firstItem, skuList),
      relatedProducts: [], // API 無提供相關產品
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': status,
      'msg': message,
      'data': {
        'productDetail': productDetail.toJson(),
        'relatedProducts': relatedProducts.map((item) => item.toJson()).toList(),
      },
    };
  }

  /// 檢查 API 回應是否成功
  bool get isSuccess => status == 1;

  /// 是否有相關產品
  bool get hasRelatedProducts => relatedProducts.isNotEmpty;
}
