/// TK幣交易類型
enum TKCoinTransactionType {
  grant(1), // 獲得
  usage(2), // 使用
  expire(4), // 過期
  adjust(8); // 手動調整

  final int value;
  const TKCoinTransactionType(this.value);

  String get displayText {
    switch (this) {
      case TKCoinTransactionType.grant:
        return '獲得';
      case TKCoinTransactionType.usage:
        return '使用';
      case TKCoinTransactionType.expire:
        return '過期';
      case TKCoinTransactionType.adjust:
        return '調整';
    }
  }

  static TKCoinTransactionType fromValue(int? value) {
    switch (value) {
      case 1:
        return TKCoinTransactionType.grant;
      case 2:
        return TKCoinTransactionType.usage;
      case 4:
        return TKCoinTransactionType.expire;
      case 8:
        return TKCoinTransactionType.adjust;
      default:
        return TKCoinTransactionType.grant;
    }
  }
}

/// TK幣來源類型
enum TKCoinSource {
  upgrade, // 升級禮
  birthday, // 生日禮
  threshold, // 滿額贈
  campaign, // 行銷活動
  manual, // 手動調整
  usage, // 使用
  expire; // 過期

  String get displayText {
    switch (this) {
      case TKCoinSource.upgrade:
        return '升級禮';
      case TKCoinSource.birthday:
        return '生日禮';
      case TKCoinSource.threshold:
        return '滿額贈';
      case TKCoinSource.campaign:
        return '行銷活動';
      case TKCoinSource.manual:
        return '手動調整';
      case TKCoinSource.usage:
        return '使用';
      case TKCoinSource.expire:
        return '過期';
    }
  }

  static TKCoinSource fromString(String? source) {
    switch (source?.toLowerCase()) {
      case 'upgrade':
        return TKCoinSource.upgrade;
      case 'birthday':
        return TKCoinSource.birthday;
      case 'threshold':
        return TKCoinSource.threshold;
      case 'campaign':
        return TKCoinSource.campaign;
      case 'manual':
        return TKCoinSource.manual;
      case 'usage':
        return TKCoinSource.usage;
      case 'expire':
        return TKCoinSource.expire;
      default:
        return TKCoinSource.campaign;
    }
  }
}

/// TK幣交易過濾類型
enum TKCoinFilterType {
  all, // 全部
  grants, // 已獲得
  usages, // 已使用
  expired; // 已過期

  String get apiValue {
    switch (this) {
      case TKCoinFilterType.grants:
        return 'grants';
      case TKCoinFilterType.usages:
        return 'usages';
      case TKCoinFilterType.expired:
        return 'expired';
      case TKCoinFilterType.all:
        return 'all';
    }
  }

  static TKCoinFilterType fromString(String? filter) {
    switch (filter?.toLowerCase()) {
      case 'grants':
        return TKCoinFilterType.grants;
      case 'usages':
        return TKCoinFilterType.usages;
      case 'expired':
        return TKCoinFilterType.expired;
      default:
        return TKCoinFilterType.all;
    }
  }
}

/// 取得 TK幣餘額回應
class TKCoinBalanceResponse {
  final int memberId;
  final String memberName;
  final int balance;
  final int balanceFromDb;

  TKCoinBalanceResponse({
    required this.memberId,
    required this.memberName,
    required this.balance,
    required this.balanceFromDb,
  });

  factory TKCoinBalanceResponse.fromJson(Map<String, dynamic> json) {
    return TKCoinBalanceResponse(
      memberId: json['member_id'] as int,
      memberName: json['member_name'] as String,
      balance: json['balance'] as int,
      balanceFromDb: json['balance_from_db'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member_name': memberName,
      'balance': balance,
      'balance_from_db': balanceFromDb,
    };
  }
}

/// 使用 TK幣請求
class UseTKCoinRequest {
  final int amount;
  final String description;
  final String? referenceId;
  final String? referenceType;
  final int? orderAmount;

  UseTKCoinRequest({
    required this.amount,
    required this.description,
    this.referenceId,
    this.referenceType,
    this.orderAmount,
  });

  /// 驗證使用金額是否超過訂單金額的 20%
  bool validateOrderAmountLimit() {
    if (orderAmount == null) return true;
    return amount <= (orderAmount! * 0.2).toInt();
  }

  /// 獲取違反限制的錯誤訊息
  String? getOrderAmountLimitError() {
    if (!validateOrderAmountLimit()) {
      final maxAmount = (orderAmount! * 0.2).toInt();
      return '使用金額($amount)不能超過訂單金額($orderAmount)的 20%(最多 $maxAmount)';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      if (referenceId != null) 'reference_id': referenceId,
      if (referenceType != null) 'reference_type': referenceType,
      if (orderAmount != null) 'order_amount': orderAmount,
    };
  }
}

/// 使用 TK幣回應
class UseTKCoinResponse {
  final int amount;
  final int balance;
  final int transactionId;

  UseTKCoinResponse({
    required this.amount,
    required this.balance,
    required this.transactionId,
  });

  factory UseTKCoinResponse.fromJson(Map<String, dynamic> json) {
    return UseTKCoinResponse(
      amount: json['amount'] as int,
      balance: json['balance'] as int,
      transactionId: json['transaction_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'balance': balance,
      'transaction_id': transactionId,
    };
  }
}

/// 即將過期的 TK幣項目
class ExpiringTKCoinItem {
  final int id;
  final int amount;
  final String description;
  final String expiresAt;
  final int daysUntilExpire;
  final String source;
  final String sourceText;
  final String createdAt;

  ExpiringTKCoinItem({
    required this.id,
    required this.amount,
    required this.description,
    required this.expiresAt,
    required this.daysUntilExpire,
    required this.source,
    required this.sourceText,
    required this.createdAt,
  });

  factory ExpiringTKCoinItem.fromJson(Map<String, dynamic> json) {
    return ExpiringTKCoinItem(
      id: json['id'] as int,
      amount: json['amount'] as int,
      description: json['description'] as String,
      expiresAt: json['expires_at'] as String,
      daysUntilExpire: json['days_until_expire'] as int,
      source: json['source'] as String,
      sourceText: json['source_text'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'expires_at': expiresAt,
      'days_until_expire': daysUntilExpire,
      'source': source,
      'source_text': sourceText,
      'created_at': createdAt,
    };
  }
}

/// 即將過期的 TK幣回應
class ExpiringTKCoinsResponse {
  final int memberId;
  final int daysBeforeExpire;
  final List<ExpiringTKCoinItem> expiringList;
  final int totalCount;
  final int totalAmount;
  final int expiredCount;
  final int expiredAmount;

  ExpiringTKCoinsResponse({
    required this.memberId,
    required this.daysBeforeExpire,
    required this.expiringList,
    required this.totalCount,
    required this.totalAmount,
    required this.expiredCount,
    required this.expiredAmount,
  });

  factory ExpiringTKCoinsResponse.fromJson(Map<String, dynamic> json) {
    return ExpiringTKCoinsResponse(
      memberId: json['member_id'] as int,
      daysBeforeExpire: json['days_before_expire'] as int,
      expiringList: (json['expiring_list'] as List)
          .map((item) => ExpiringTKCoinItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      totalAmount: json['total_amount'] as int,
      expiredCount: json['expired_count'] as int,
      expiredAmount: json['expired_amount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'days_before_expire': daysBeforeExpire,
      'expiring_list': expiringList.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'total_amount': totalAmount,
      'expired_count': expiredCount,
      'expired_amount': expiredAmount,
    };
  }
}

/// 領取 TK幣回應
class ClaimTKCoinResponse {
  final int points;
  final int balance;
  final int transactionId;

  ClaimTKCoinResponse({
    required this.points,
    required this.balance,
    required this.transactionId,
  });

  factory ClaimTKCoinResponse.fromJson(Map<String, dynamic> json) {
    return ClaimTKCoinResponse(
      points: json['points'] as int,
      balance: json['balance'] as int,
      transactionId: json['transaction_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'balance': balance,
      'transaction_id': transactionId,
    };
  }
}

/// TK幣交易記錄項目
class TKCoinTransaction {
  final int id;
  final int type;
  final String typeText;
  final int amount;
  final int balanceAfter;
  final String source;
  final String sourceText;
  final String description;
  final String? effectiveAt;
  final String? expiresAt;
  final int isExpired;
  final String createdAt;

  TKCoinTransaction({
    required this.id,
    required this.type,
    required this.typeText,
    required this.amount,
    required this.balanceAfter,
    required this.source,
    required this.sourceText,
    required this.description,
    this.effectiveAt,
    this.expiresAt,
    required this.isExpired,
    required this.createdAt,
  });

  /// 取得交易類型
  TKCoinTransactionType get transactionType => TKCoinTransactionType.fromValue(type);

  /// 取得交易來源
  TKCoinSource get sourceType => TKCoinSource.fromString(source);

  /// 判斷是否為獲得
  bool get isGrant => type == 1 || (type == 8 && amount > 0);

  /// 判斷是否為使用
  bool get isUsage => type == 2 || (type == 8 && amount < 0);

  /// 判斷是否已過期
  bool get isExpiredType => type == 4 || isExpired == 1;

  factory TKCoinTransaction.fromJson(Map<String, dynamic> json) {
    return TKCoinTransaction(
      id: json['id'] as int,
      type: json['type'] as int,
      typeText: json['type_text'] as String,
      amount: json['amount'] as int,
      balanceAfter: json['balance_after'] as int,
      source: json['source'] as String,
      sourceText: json['source_text'] as String,
      description: json['description'] as String,
      effectiveAt: json['effective_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      isExpired: json['is_expired'] as int? ?? 0,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'type_text': typeText,
      'amount': amount,
      'balance_after': balanceAfter,
      'source': source,
      'source_text': sourceText,
      'description': description,
      'effective_at': effectiveAt,
      'expires_at': expiresAt,
      'is_expired': isExpired,
      'created_at': createdAt,
    };
  }
}

/// 分頁資訊
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final int perPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.perPage,
  });

  /// 是否有下一頁
  bool get hasNextPage => currentPage < totalPages;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalRecords: json['total_records'] as int,
      perPage: json['per_page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_records': totalRecords,
      'per_page': perPage,
    };
  }
}

/// TK幣交易記錄回應（統一 API）
class TKCoinTransactionListResponse {
  final int memberId;
  final String memberName;
  final int currentBalance;
  final List<TKCoinTransaction> transactions;
  final PaginationInfo pagination;

  TKCoinTransactionListResponse({
    required this.memberId,
    required this.memberName,
    required this.currentBalance,
    required this.transactions,
    required this.pagination,
  });

  factory TKCoinTransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TKCoinTransactionListResponse(
      memberId: json['member_id'] as int,
      memberName: json['member_name'] as String,
      currentBalance: json['current_balance'] as int,
      transactions: (json['transactions'] as List)
          .map((item) => TKCoinTransaction.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member_name': memberName,
      'current_balance': currentBalance,
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

/// 舊 API：TK幣記錄回應（grants 或 usages）
class TKCoinRecordsResponse {
  final int memberId;
  final String memberName;
  final int currentBalance;
  final List<TKCoinTransaction> records;
  final int totalCount;
  final int totalAmount;

  TKCoinRecordsResponse({
    required this.memberId,
    required this.memberName,
    required this.currentBalance,
    required this.records,
    required this.totalCount,
    required this.totalAmount,
  });

  factory TKCoinRecordsResponse.fromJson(Map<String, dynamic> json, String recordType) {
    final recordsKey = recordType == 'grants' ? 'grants' : 'usages';
    return TKCoinRecordsResponse(
      memberId: json['member_id'] as int,
      memberName: json['member_name'] as String,
      currentBalance: json['current_balance'] as int,
      records: (json[recordsKey] as List)
          .map((item) => TKCoinTransaction.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      totalAmount: json['total_amount'] as int,
    );
  }

  Map<String, dynamic> toJson(String recordType) {
    final recordsKey = recordType == 'grants' ? 'grants' : 'usages';
    return {
      'member_id': memberId,
      'member_name': memberName,
      'current_balance': currentBalance,
      recordsKey: records.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'total_amount': totalAmount,
    };
  }
}
