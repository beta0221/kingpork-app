import 'package:tklab_ec_v2/models/tkcoin_models.dart';

/// 優惠券分類
enum CouponCategory {
  upgrade(1), // 會員升級禮
  birthday(2), // 會員生日禮
  threshold(3), // 滿額贈
  campaign(4); // 行銷活動

  final int value;
  const CouponCategory(this.value);

  String get displayText {
    switch (this) {
      case CouponCategory.upgrade:
        return '會員升級禮';
      case CouponCategory.birthday:
        return '會員生日禮';
      case CouponCategory.threshold:
        return '滿額贈';
      case CouponCategory.campaign:
        return '行銷活動';
    }
  }

  static CouponCategory fromValue(int? value) {
    switch (value) {
      case 1:
        return CouponCategory.upgrade;
      case 2:
        return CouponCategory.birthday;
      case 3:
        return CouponCategory.threshold;
      case 4:
        return CouponCategory.campaign;
      default:
        return CouponCategory.campaign;
    }
  }
}

/// 優惠方式
enum CouponType {
  discount(1), // 折價券（百分比折扣）
  cash(2), // 現金券（固定金額）
  gift(4); // 禮物券（贈品）

  final int value;
  const CouponType(this.value);

  String get displayText {
    switch (this) {
      case CouponType.discount:
        return '折價券';
      case CouponType.cash:
        return '現金券';
      case CouponType.gift:
        return '禮物券';
    }
  }

  static CouponType fromValue(int? value) {
    switch (value) {
      case 1:
        return CouponType.discount;
      case 2:
        return CouponType.cash;
      case 4:
        return CouponType.gift;
      default:
        return CouponType.cash;
    }
  }
}

/// 生效條件
enum CouponConditionType {
  none(1), // 無條件
  threshold(2); // 當整筆訂單達到

  final int value;
  const CouponConditionType(this.value);

  String get displayText {
    switch (this) {
      case CouponConditionType.none:
        return '無條件';
      case CouponConditionType.threshold:
        return '達到門檻';
    }
  }

  static CouponConditionType fromValue(int? value) {
    switch (value) {
      case 1:
        return CouponConditionType.none;
      case 2:
        return CouponConditionType.threshold;
      default:
        return CouponConditionType.none;
    }
  }
}

/// 門檻種類
enum CouponConditionMetric {
  minAmount(1), // 最低金額
  minQuantity(2); // 最少件數

  final int value;
  const CouponConditionMetric(this.value);

  String get displayText {
    switch (this) {
      case CouponConditionMetric.minAmount:
        return '最低金額';
      case CouponConditionMetric.minQuantity:
        return '最少件數';
    }
  }

  static CouponConditionMetric? fromValue(int? value) {
    switch (value) {
      case 1:
        return CouponConditionMetric.minAmount;
      case 2:
        return CouponConditionMetric.minQuantity;
      default:
        return null;
    }
  }
}

/// 使用範圍限制
enum CouponLimitScope {
  none(1), // 不限制
  products(2), // 僅限指定商品使用
  stores(4); // 僅限指定賣場使用

  final int value;
  const CouponLimitScope(this.value);

  String get displayText {
    switch (this) {
      case CouponLimitScope.none:
        return '不限制';
      case CouponLimitScope.products:
        return '僅限指定商品';
      case CouponLimitScope.stores:
        return '僅限指定賣場';
    }
  }

  static CouponLimitScope fromValue(int? value) {
    switch (value) {
      case 1:
        return CouponLimitScope.none;
      case 2:
        return CouponLimitScope.products;
      case 4:
        return CouponLimitScope.stores;
      default:
        return CouponLimitScope.none;
    }
  }
}

/// 領取方式
enum CouponDistributionMethod {
  autoGrant(1), // 登入自動送
  selfClaim(2), // 登入自行領取
  scheduled(4); // 排程發送

  final int value;
  const CouponDistributionMethod(this.value);

  String get displayText {
    switch (this) {
      case CouponDistributionMethod.autoGrant:
        return '登入自動送';
      case CouponDistributionMethod.selfClaim:
        return '登入自行領取';
      case CouponDistributionMethod.scheduled:
        return '排程發送';
    }
  }

  static CouponDistributionMethod fromValue(int? value) {
    switch (value) {
      case 1:
        return CouponDistributionMethod.autoGrant;
      case 2:
        return CouponDistributionMethod.selfClaim;
      case 4:
        return CouponDistributionMethod.scheduled;
      default:
        return CouponDistributionMethod.selfClaim;
    }
  }
}

/// 使用狀態
enum CouponStatus {
  unused(1), // 未使用
  used(2), // 已使用
  expired(4); // 已過期

  final int value;
  const CouponStatus(this.value);

  String get displayText {
    switch (this) {
      case CouponStatus.unused:
        return '未使用';
      case CouponStatus.used:
        return '已使用';
      case CouponStatus.expired:
        return '已過期';
    }
  }

  static CouponStatus fromValue(int? value) {
    switch (value) {
      case 1:
        return CouponStatus.unused;
      case 2:
        return CouponStatus.used;
      case 4:
        return CouponStatus.expired;
      default:
        return CouponStatus.unused;
    }
  }

  static CouponStatus? fromString(String? status) {
    switch (status) {
      case '未使用':
        return CouponStatus.unused;
      case '已使用':
        return CouponStatus.used;
      case '已過期':
        return CouponStatus.expired;
      default:
        return null;
    }
  }
}

/// 優惠券基本資訊
class Coupon {
  final int id;
  final String title;
  final String? code;
  final String? imageUrl;
  final CouponCategory couponCategory;
  final CouponType type;
  final double? value; // 折價券: 0-1, 現金券: 金額, 禮物券: null
  final int? maxDiscountAmount; // 折價券封頂金額
  final CouponConditionType conditionType;
  final CouponConditionMetric? conditionMetric;
  final int? conditionThreshold;
  final CouponLimitScope limitScope;
  final String activityStartsAt;
  final String activityEndsAt;
  final String? redemptionStartsAt;
  final String? redemptionEndsAt;
  final int? redemptionLimitType;
  final int? redemptionLimitCount;
  final bool hasRedeemed;
  final int redemptionCount;

  Coupon({
    required this.id,
    required this.title,
    this.code,
    this.imageUrl,
    required this.couponCategory,
    required this.type,
    this.value,
    this.maxDiscountAmount,
    required this.conditionType,
    this.conditionMetric,
    this.conditionThreshold,
    required this.limitScope,
    required this.activityStartsAt,
    required this.activityEndsAt,
    this.redemptionStartsAt,
    this.redemptionEndsAt,
    this.redemptionLimitType,
    this.redemptionLimitCount,
    this.hasRedeemed = false,
    this.redemptionCount = 0,
  });

  /// 判斷是否已過期
  bool get isExpired {
    try {
      final endDate = DateTime.parse(activityEndsAt);
      return DateTime.now().isAfter(endDate);
    } catch (e) {
      return false;
    }
  }

  /// 判斷是否在活動期間
  bool get isActive {
    try {
      final startDate = DateTime.parse(activityStartsAt);
      final endDate = DateTime.parse(activityEndsAt);
      final now = DateTime.now();
      return now.isAfter(startDate) && now.isBefore(endDate);
    } catch (e) {
      return false;
    }
  }

  /// 判斷是否可領取
  bool get canRedeem {
    if (hasRedeemed && redemptionLimitType != null && redemptionLimitType == 1) {
      // 如果已領取且限制類型為單次，則不可再領取
      return false;
    }

    if (redemptionLimitCount != null && redemptionCount >= redemptionLimitCount!) {
      // 如果已達領取次數上限
      return false;
    }

    if (redemptionStartsAt != null && redemptionEndsAt != null) {
      try {
        final startDate = DateTime.parse(redemptionStartsAt!);
        final endDate = DateTime.parse(redemptionEndsAt!);
        final now = DateTime.now();
        return now.isAfter(startDate) && now.isBefore(endDate);
      } catch (e) {
        return false;
      }
    }

    return isActive;
  }

  /// 顯示優惠券面額（例如 "8折" 或 "$100" 或 "禮物"）
  String get displayValue {
    switch (type) {
      case CouponType.discount:
        if (value != null) {
          final percent = (value! * 10).toInt();
          return '$percent折';
        }
        return '折扣';
      case CouponType.cash:
        if (value != null) {
          return '\$${value!.toInt()}';
        }
        return '現金券';
      case CouponType.gift:
        return '禮物';
    }
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as int,
      title: json['title'] as String,
      code: json['code'] as String?,
      imageUrl: json['image_url'] as String?,
      couponCategory: CouponCategory.fromValue(json['coupon_category'] as int?),
      type: CouponType.fromValue(json['type'] as int?),
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      maxDiscountAmount: json['max_discount_amount'] as int?,
      conditionType: CouponConditionType.fromValue(json['condition_type'] as int?),
      conditionMetric: CouponConditionMetric.fromValue(json['condition_metric'] as int?),
      conditionThreshold: json['condition_threshold'] as int?,
      limitScope: CouponLimitScope.fromValue(json['limit_scope'] as int?),
      activityStartsAt: json['activity_starts_at'] as String,
      activityEndsAt: json['activity_ends_at'] as String,
      redemptionStartsAt: json['redemption_starts_at'] as String?,
      redemptionEndsAt: json['redemption_ends_at'] as String?,
      redemptionLimitType: json['redemption_limit_type'] as int?,
      redemptionLimitCount: json['redemption_limit_count'] as int?,
      hasRedeemed: json['has_redeemed'] as bool? ?? false,
      redemptionCount: json['redemption_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (code != null) 'code': code,
      if (imageUrl != null) 'image_url': imageUrl,
      'coupon_category': couponCategory.value,
      'type': type.value,
      if (value != null) 'value': value,
      if (maxDiscountAmount != null) 'max_discount_amount': maxDiscountAmount,
      'condition_type': conditionType.value,
      if (conditionMetric != null) 'condition_metric': conditionMetric!.value,
      if (conditionThreshold != null) 'condition_threshold': conditionThreshold,
      'limit_scope': limitScope.value,
      'activity_starts_at': activityStartsAt,
      'activity_ends_at': activityEndsAt,
      if (redemptionStartsAt != null) 'redemption_starts_at': redemptionStartsAt,
      if (redemptionEndsAt != null) 'redemption_ends_at': redemptionEndsAt,
      if (redemptionLimitType != null) 'redemption_limit_type': redemptionLimitType,
      if (redemptionLimitCount != null) 'redemption_limit_count': redemptionLimitCount,
      'has_redeemed': hasRedeemed,
      'redemption_count': redemptionCount,
    };
  }
}

/// 已發放優惠券項目
class GrantedCoupon {
  final int couponId;
  final String title;
  final int redemptionId;
  final String redemptionAt;

  GrantedCoupon({
    required this.couponId,
    required this.title,
    required this.redemptionId,
    required this.redemptionAt,
  });

  factory GrantedCoupon.fromJson(Map<String, dynamic> json) {
    return GrantedCoupon(
      couponId: json['coupon_id'] as int,
      title: json['title'] as String,
      redemptionId: json['redemption_id'] as int,
      redemptionAt: json['redemption_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_id': couponId,
      'title': title,
      'redemption_id': redemptionId,
      'redemption_at': redemptionAt,
    };
  }
}

/// 檢查並自動發放優惠券回應
class CheckAutoGrantResponse {
  final List<GrantedCoupon> grantedCoupons;
  final int grantedCount;

  CheckAutoGrantResponse({
    required this.grantedCoupons,
    required this.grantedCount,
  });

  /// 創建空回應（未登入時使用）
  factory CheckAutoGrantResponse.empty() {
    return CheckAutoGrantResponse(
      grantedCoupons: [],
      grantedCount: 0,
    );
  }

  factory CheckAutoGrantResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return CheckAutoGrantResponse(
      grantedCoupons: (data['granted_coupons'] as List?)
              ?.map((item) => GrantedCoupon.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      grantedCount: data['granted_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': 1,
      'data': {
        'granted_coupons': grantedCoupons.map((e) => e.toJson()).toList(),
        'granted_count': grantedCount,
      },
    };
  }
}

/// 領取優惠券回應
class ClaimCouponResponse {
  final int redemptionId;
  final int couponId;
  final String? couponCode; // 序號領取時有值
  final String redemptionAt;

  ClaimCouponResponse({
    required this.redemptionId,
    required this.couponId,
    this.couponCode,
    required this.redemptionAt,
  });

  factory ClaimCouponResponse.fromJson(Map<String, dynamic> json) {
    return ClaimCouponResponse(
      redemptionId: json['redemption_id'] as int,
      couponId: json['coupon_id'] as int,
      couponCode: json['coupon_code'] as String?,
      redemptionAt: json['redemption_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'redemption_id': redemptionId,
      'coupon_id': couponId,
      if (couponCode != null) 'coupon_code': couponCode,
      'redemption_at': redemptionAt,
    };
  }
}

/// 我的優惠券項目
class MyCoupon {
  final int redemptionId;
  final int couponId;
  final String? couponCode;
  final String title;
  final String? imageUrl;
  final CouponCategory couponCategory;
  final CouponType type;
  final double? value;
  final int? maxDiscountAmount;
  final CouponConditionType conditionType;
  final CouponConditionMetric? conditionMetric;
  final int? conditionThreshold;
  final CouponLimitScope limitScope;
  final String redemptionAt;
  final CouponStatus status;
  final String? usedAt;
  final String? orderId;
  final int? discountAmount;
  final String activityStartsAt;
  final String activityEndsAt;

  MyCoupon({
    required this.redemptionId,
    required this.couponId,
    this.couponCode,
    required this.title,
    this.imageUrl,
    required this.couponCategory,
    required this.type,
    this.value,
    this.maxDiscountAmount,
    required this.conditionType,
    this.conditionMetric,
    this.conditionThreshold,
    required this.limitScope,
    required this.redemptionAt,
    required this.status,
    this.usedAt,
    this.orderId,
    this.discountAmount,
    required this.activityStartsAt,
    required this.activityEndsAt,
  });

  /// 判斷是否已過期
  bool get isExpired {
    try {
      final endDate = DateTime.parse(activityEndsAt);
      return DateTime.now().isAfter(endDate);
    } catch (e) {
      return false;
    }
  }

  /// 判斷是否可使用
  bool get canUse {
    return status == CouponStatus.unused && !isExpired;
  }

  /// 顯示優惠券面額（例如 "8折" 或 "$100" 或 "禮物"）
  String get displayValue {
    switch (type) {
      case CouponType.discount:
        if (value != null) {
          final percent = (value! * 10).toInt();
          return '$percent折';
        }
        return '折扣';
      case CouponType.cash:
        if (value != null) {
          return '\$${value!.toInt()}';
        }
        return '現金券';
      case CouponType.gift:
        return '禮物';
    }
  }

  factory MyCoupon.fromJson(Map<String, dynamic> json) {
    return MyCoupon(
      redemptionId: json['redemption_id'] as int,
      couponId: json['coupon_id'] as int,
      couponCode: json['coupon_code'] as String?,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String?,
      couponCategory: CouponCategory.fromValue(json['coupon_category'] as int?),
      type: CouponType.fromValue(json['type'] as int?),
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      maxDiscountAmount: json['max_discount_amount'] as int?,
      conditionType: CouponConditionType.fromValue(json['condition_type'] as int?),
      conditionMetric: CouponConditionMetric.fromValue(json['condition_metric'] as int?),
      conditionThreshold: json['condition_threshold'] as int?,
      limitScope: CouponLimitScope.fromValue(json['limit_scope'] as int?),
      redemptionAt: json['redemption_at'] as String,
      status: json['status_value'] != null
          ? CouponStatus.fromValue(json['status_value'] as int?)
          : (CouponStatus.fromString(json['status'] as String?) ?? CouponStatus.unused),
      usedAt: json['used_at'] as String?,
      orderId: json['order_id'] as String?,
      discountAmount: json['discount_amount'] as int?,
      activityStartsAt: json['activity_starts_at'] as String,
      activityEndsAt: json['activity_ends_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'redemption_id': redemptionId,
      'coupon_id': couponId,
      if (couponCode != null) 'coupon_code': couponCode,
      'title': title,
      if (imageUrl != null) 'image_url': imageUrl,
      'coupon_category': couponCategory.value,
      'type': type.value,
      if (value != null) 'value': value,
      if (maxDiscountAmount != null) 'max_discount_amount': maxDiscountAmount,
      'condition_type': conditionType.value,
      if (conditionMetric != null) 'condition_metric': conditionMetric!.value,
      if (conditionThreshold != null) 'condition_threshold': conditionThreshold,
      'limit_scope': limitScope.value,
      'redemption_at': redemptionAt,
      'status': status.displayText,
      'status_value': status.value,
      if (usedAt != null) 'used_at': usedAt,
      if (orderId != null) 'order_id': orderId,
      if (discountAmount != null) 'discount_amount': discountAmount,
      'activity_starts_at': activityStartsAt,
      'activity_ends_at': activityEndsAt,
    };
  }
}

/// 我的優惠券列表回應
class MyCouponsResponse {
  final List<MyCoupon> data;
  final PaginationInfo pagination;

  MyCouponsResponse({
    required this.data,
    required this.pagination,
  });

  factory MyCouponsResponse.fromJson(Map<String, dynamic> json) {
    return MyCouponsResponse(
      data: (json['data'] as List).map((item) => MyCoupon.fromJson(item as Map<String, dynamic>)).toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      's': 1,
      'data': data.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

/// 訂單商品項目
class OrderItem {
  final int productId;
  final int storeId;
  final int amount;

  OrderItem({
    required this.productId,
    required this.storeId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'store_id': storeId,
      'amount': amount,
    };
  }
}

/// 使用優惠券請求
class UseCouponRequest {
  final int redemptionId;
  final String orderId;
  final int orderAmount;
  final List<OrderItem>? orderItems;

  UseCouponRequest({
    required this.redemptionId,
    required this.orderId,
    required this.orderAmount,
    this.orderItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'redemption_id': redemptionId,
      'order_id': orderId,
      'order_amount': orderAmount,
      if (orderItems != null) 'order_items': orderItems!.map((e) => e.toJson()).toList(),
    };
  }
}

/// 使用優惠券回應
class UseCouponResponse {
  final int redemptionId;
  final int discountAmount;
  final String orderId;
  final String usedAt;

  UseCouponResponse({
    required this.redemptionId,
    required this.discountAmount,
    required this.orderId,
    required this.usedAt,
  });

  factory UseCouponResponse.fromJson(Map<String, dynamic> json) {
    return UseCouponResponse(
      redemptionId: json['redemption_id'] as int,
      discountAmount: json['discount_amount'] as int,
      orderId: json['order_id'] as String,
      usedAt: json['used_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'redemption_id': redemptionId,
      'discount_amount': discountAmount,
      'order_id': orderId,
      'used_at': usedAt,
    };
  }
}
