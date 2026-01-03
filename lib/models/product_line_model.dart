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
