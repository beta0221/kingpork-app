/// 產品線項目 model
class ProductLine {
  final String name;
  final String url;

  ProductLine({
    required this.name,
    required this.url,
  });

  factory ProductLine.fromJson(Map<String, dynamic> json) {
    return ProductLine(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  String devUrl() {
    return 'http://localhost:8083$url';
  }
}

/// 產品線列表回應
class ProductLineListResponse {
  final int status;
  final String message;
  final List<ProductLine> productLineList;

  ProductLineListResponse({
    required this.status,
    required this.message,
    required this.productLineList,
  });

  factory ProductLineListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProductLineListResponse(
      status: json['s'] as int,
      message: json['msg'] as String,
      productLineList: (data['productLineList'] as List)
          .map((item) => ProductLine.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': status,
      'msg': message,
      'data': {
        'productLineList': productLineList.map((item) => item.toJson()).toList(),
      },
    };
  }

  /// 檢查 API 回應是否成功
  bool get isSuccess => status == 1;
}

/// 產品分類項目 model
class ProductCategory {
  final int catId;
  final String name;
  final String imgUrl;

  ProductCategory({
    required this.catId,
    required this.name,
    required this.imgUrl,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      catId: json['catId'] as int,
      name: json['name'] as String,
      imgUrl: json['imgUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catId': catId,
      'name': name,
      'imgUrl': imgUrl,
    };
  }
}

/// 產品分類列表回應
class ProductCategoryListResponse {
  final int status;
  final String message;
  final String bannerUrl;
  final List<ProductCategory> categoryList;

  ProductCategoryListResponse({
    required this.status,
    required this.message,
    required this.bannerUrl,
    required this.categoryList,
  });

  factory ProductCategoryListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProductCategoryListResponse(
      status: json['s'] as int,
      message: json['msg'] as String,
      bannerUrl: data['bannerUrl'] as String? ?? '',
      categoryList: (data['categoryList'] as List)
          .map((item) => ProductCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': status,
      'msg': message,
      'data': {
        'bannerUrl': bannerUrl,
        'categoryList': categoryList.map((item) => item.toJson()).toList(),
      },
    };
  }

  /// 檢查 API 回應是否成功
  bool get isSuccess => status == 1;
}

/// 產品項目 model
class Product {
  final int id;
  final String name;
  final double price;
  final double spacialOffer;
  final String imgUrl;
  final String tag;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.spacialOffer,
    required this.imgUrl,
    required this.tag,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: _parsePrice(json['price']),
      spacialOffer: _parsePrice(json['spacialOffer']),
      imgUrl: json['imgUrl'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
    );
  }

  /// 解析價格，支援多種格式（String/int/double/null）
  static double _parsePrice(dynamic value) {
    if (value == null || value == '') return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // 移除可能的千分位逗號和空白
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
      'name': name,
      'price': price.toString(),
      'spacialOffer': spacialOffer.toString(),
      'imgUrl': imgUrl,
      'tag': tag,
    };
  }

  /// 是否有特價
  bool get hasSpecialOffer => spacialOffer > 0 && spacialOffer < price;

  /// 是否有標籤
  bool get hasTag => tag.isNotEmpty;

  /// 是否為 TOP 產品
  bool get isTopProduct => tag.toUpperCase().contains('TOP');

  /// 從 tag 中提取排名數字（如 "TOP10" → 10, "TOP 5" → 5）
  int? get ranking {
    if (!isTopProduct) return null;

    // 支援多種格式: "TOP10", "TOP 10", "top10", "Top10"
    final regex = RegExp(r'TOP\s*(\d+)', caseSensitive: false);
    final match = regex.firstMatch(tag);

    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}

/// 產品列表回應
class ProductListResponse {
  final int status;
  final String message;
  final List<Product> productList;

  ProductListResponse({
    required this.status,
    required this.message,
    required this.productList,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProductListResponse(
      status: json['s'] as int,
      message: json['msg'] as String,
      productList: (data['productList'] as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': status,
      'msg': message,
      'data': {
        'productList': productList.map((item) => item.toJson()).toList(),
      },
    };
  }

  /// 檢查 API 回應是否成功
  bool get isSuccess => status == 1;
}
