/// Category model for API (與 UI demo 的 CategoryModel 分開)
class ApiCategory {
  final int id;
  final String name;
  final String slug;
  final String imgUrl;
  final String? content;
  final String? createdAt;
  final String? updatedAt;

  ApiCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.imgUrl,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      imgUrl: json['imgUrl'] as String,
      content: json['content'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'imgUrl': imgUrl,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// For backwards compatibility - menuImgUrl is same as imgUrl
  String get menuImgUrl => imgUrl;
}

/// Category with products response
class CategoryWithProducts {
  final ApiCategory category;
  final List<ApiProduct> products;

  CategoryWithProducts({
    required this.category,
    required this.products,
  });

  factory CategoryWithProducts.fromJson(Map<String, dynamic> json) {
    return CategoryWithProducts(
      category: ApiCategory.fromJson(json['cat'] as Map<String, dynamic>),
      products: (json['products'] as List)
          .map((p) => ApiProduct.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Product model for API (與 UI demo 的 ProductModel 分開)
class ApiProduct {
  final int id;
  final int public;
  final String name;
  final String slug;
  final String short;
  final String? erpId;
  final String? discription;
  final int categoryId;
  final String? format;
  final double price;
  final double bonus;
  final int minForDealer;
  final String image;
  final String? content;
  final String createdAt;
  final String updatedAt;

  ApiProduct({
    required this.id,
    required this.public,
    required this.name,
    required this.slug,
    required this.short,
    this.erpId,
    this.discription,
    required this.categoryId,
    this.format,
    required this.price,
    required this.bonus,
    required this.minForDealer,
    required this.image,
    this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      id: json['id'] as int,
      public: json['public'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      short: json['short'] as String,
      erpId: json['erp_id'] as String?,
      discription: json['discription'] as String?,
      categoryId: json['category_id'] as int,
      format: json['format'] as String?,
      price: (json['price'] as num).toDouble(),
      bonus: (json['bonus'] as num).toDouble(),
      minForDealer: json['min_for_dealer'] as int,
      image: json['image'] as String,
      content: json['content'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'public': public,
      'name': name,
      'slug': slug,
      'short': short,
      if (erpId != null) 'erp_id': erpId,
      if (discription != null) 'discription': discription,
      'category_id': categoryId,
      if (format != null) 'format': format,
      'price': price,
      'bonus': bonus,
      'min_for_dealer': minForDealer,
      'image': image,
      if (content != null) 'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if product is on sale (bonus price lower than regular price)
  bool get isOnSale => bonus < price;

  /// Get discount percentage
  int? get discountPercent {
    if (!isOnSale) return null;
    return (((price - bonus) / price) * 100).round();
  }

  /// Get effective price (bonus if on sale, otherwise regular price)
  double get effectivePrice => isOnSale ? bonus : price;

  /// Check if product is public
  bool get isPublic => public == 1;
}
