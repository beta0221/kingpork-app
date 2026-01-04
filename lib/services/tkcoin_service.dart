import 'package:tklab_ec_v2/models/tkcoin_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';

/// TK幣服務
///
/// 提供 TK幣系統的所有功能，包括：
/// - 查詢餘額
/// - 使用 TK幣
/// - 查詢即將過期的 TK幣
/// - 領取 TK幣
/// - 查詢交易記錄
///
/// 所有方法都需要會員登入（Session 認證）
class TKCoinService {
  final ApiClient _apiClient;

  TKCoinService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// 取得當前 TK幣餘額
  ///
  /// 取得當前登入會員的 TK 幣餘額。系統會從交易記錄計算實際有效餘額（排除已過期的 TK 幣）。
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [ApiException]: API 錯誤
  ///
  /// 範例:
  /// ```dart
  /// try {
  ///   final balance = await tkcoinService.getBalance();
  ///   print('餘額: ${balance.balance}');
  /// } catch (e) {
  ///   print('錯誤: $e');
  /// }
  /// ```
  Future<TKCoinBalanceResponse> getBalance() async {
    final response = await _apiClient.get(
      ApiEndpoints.tkCoinBalance,
      requiresAuth: true,
    );

    return TKCoinBalanceResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 使用 TK幣
  ///
  /// 在結帳時使用 TK 幣。系統會檢查餘額是否足夠，並支援訂單金額的 20% 限制檢查。
  ///
  /// 參數:
  /// - [amount]: 使用金額（必須為正整數）
  /// - [description]: 使用說明（最多 255 字元）
  /// - [referenceId]: 關聯 ID，例如訂單編號
  /// - [referenceType]: 關聯類型，例如 'order'
  /// - [orderAmount]: 訂單金額，用於檢查 20% 限制
  ///
  /// 拋出異常:
  /// - [ApiException]: 餘額不足、超過限制等
  /// - [ValidationException]: 驗證失敗
  /// - [UnauthorizedException]: 未登入
  ///
  /// 使用限制:
  /// - 使用金額不能超過當前餘額
  /// - 如果提供 [orderAmount]，使用金額不能超過訂單金額的 20%
  /// - 使用金額必須為正整數
  ///
  /// 範例:
  /// ```dart
  /// try {
  ///   final response = await tkcoinService.useTKCoin(
  ///     amount: 100,
  ///     description: '訂單 #12345 使用 TK 幣',
  ///     referenceId: '12345',
  ///     referenceType: 'order',
  ///     orderAmount: 1000,
  ///   );
  ///   print('使用成功，剩餘: ${response.balance}');
  /// } on ApiException catch (e) {
  ///   if (e.statusCode == 400) {
  ///     print('業務錯誤: ${e.message}');
  ///   }
  /// }
  /// ```
  Future<UseTKCoinResponse> useTKCoin({
    required int amount,
    required String description,
    String? referenceId,
    String? referenceType,
    int? orderAmount,
  }) async {
    final request = UseTKCoinRequest(
      amount: amount,
      description: description,
      referenceId: referenceId,
      referenceType: referenceType,
      orderAmount: orderAmount,
    );

    // 客戶端驗證：20% 限制檢查
    final limitError = request.getOrderAmountLimitError();
    if (limitError != null) {
      throw ApiException(limitError, statusCode: 400);
    }

    final response = await _apiClient.post(
      ApiEndpoints.tkCoinUse,
      body: request.toJson(),
      requiresAuth: true,
    );

    return UseTKCoinResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 取得即將過期的 TK幣列表
  ///
  /// 取得即將在指定天數內過期的 TK 幣列表，幫助會員及時使用。
  ///
  /// 參數:
  /// - [days]: 查詢天數，預設 30 天
  /// - [limit]: 最多返回筆數，預設 50 筆
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [ApiException]: API 錯誤
  ///
  /// 範例:
  /// ```dart
  /// final expiring = await tkcoinService.getExpiringList(
  ///   days: 7,
  ///   limit: 10,
  /// );
  /// print('即將過期金額: ${expiring.totalAmount}');
  /// ```
  Future<ExpiringTKCoinsResponse> getExpiringList({
    int? days,
    int? limit,
  }) async {
    final queryParams = <String, String>{};

    if (days != null) {
      queryParams['days'] = days.toString();
    }

    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }

    final endpoint = _buildEndpointWithQuery(
      ApiEndpoints.tkCoinExpiring,
      queryParams,
    );

    final response = await _apiClient.get(
      endpoint,
      requiresAuth: true,
    );

    return ExpiringTKCoinsResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 領取 TK幣（行銷活動）
  ///
  /// 透過領取 Token 領取行銷活動的 TK 幣。
  ///
  /// 參數:
  /// - [token]: 領取 Token（從後台取得）
  ///
  /// 拋出異常:
  /// - [NotFoundException]: 無效的領取連結
  /// - [ApiException]: 活動已結束、不符合資格等
  /// - [UnauthorizedException]: 未登入
  ///
  /// 檢查項目:
  /// - 活動狀態（必須啟用）
  /// - 活動時間範圍
  /// - 會員等級限制
  /// - 領取次數限制
  ///
  /// 範例:
  /// ```dart
  /// try {
  ///   final result = await tkcoinService.claimTKCoin('token123');
  ///   print('領取成功: ${result.points} 點');
  /// } on NotFoundException {
  ///   print('無效的領取連結');
  /// }
  /// ```
  Future<ClaimTKCoinResponse> claimTKCoin(String token) async {
    final response = await _apiClient.get(
      ApiEndpoints.tkCoinClaim(token),
      requiresAuth: true,
    );

    return ClaimTKCoinResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 取得交易記錄（統一 API）
  ///
  /// 取得當前登入會員的 TK 幣交易記錄，支援多種過濾條件和分頁。
  ///
  /// 參數:
  /// - [filter]: 過濾類型 (all/grants/usages/expired)，預設 all
  /// - [limit]: 每頁筆數，預設 100，最大建議 500
  /// - [page]: 頁碼，預設 1
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [ApiException]: API 錯誤
  ///
  /// 過濾類型說明:
  /// - [TKCoinFilterType.grants]: 已獲得
  /// - [TKCoinFilterType.usages]: 已使用
  /// - [TKCoinFilterType.expired]: 已過期
  /// - [TKCoinFilterType.all]: 全部記錄
  ///
  /// 範例:
  /// ```dart
  /// final page1 = await tkcoinService.getTransactionList(
  ///   filter: TKCoinFilterType.grants,
  ///   limit: 50,
  ///   page: 1,
  /// );
  /// print('總頁數: ${page1.pagination.totalPages}');
  /// ```
  Future<TKCoinTransactionListResponse> getTransactionList({
    TKCoinFilterType filter = TKCoinFilterType.all,
    int limit = 100,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'filter': filter.apiValue,
      'limit': limit.toString(),
      'page': page.toString(),
    };

    final endpoint = _buildEndpointWithQuery(
      ApiEndpoints.tkCoinGetList,
      queryParams,
    );

    final response = await _apiClient.get(
      endpoint,
      requiresAuth: true,
    );

    return TKCoinTransactionListResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 取得指定會員的交易記錄（統一 API）
  ///
  /// 取得指定會員的 TK 幣交易記錄。會員只能查詢自己的記錄。
  ///
  /// 參數:
  /// - [memberId]: 會員 ID
  /// - [filter]: 過濾類型，預設 all
  /// - [limit]: 每頁筆數，預設 100
  /// - [page]: 頁碼，預設 1
  ///
  /// 拋出異常:
  /// - [ForbiddenException]: 無權限查詢此會員的記錄
  /// - [UnauthorizedException]: 未登入
  /// - [ApiException]: API 錯誤
  ///
  /// 註: 會員只能查詢自己的記錄，如果 memberId 與當前登入會員 ID 不符會返回 403 錯誤
  ///
  /// 範例:
  /// ```dart
  /// final transactions = await tkcoinService.getMemberTransactionList(
  ///   memberId: 10000,
  ///   filter: TKCoinFilterType.usages,
  /// );
  /// ```
  Future<TKCoinTransactionListResponse> getMemberTransactionList(
    int memberId, {
    TKCoinFilterType filter = TKCoinFilterType.all,
    int limit = 100,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'filter': filter.apiValue,
      'limit': limit.toString(),
      'page': page.toString(),
    };

    final endpoint = _buildEndpointWithQuery(
      ApiEndpoints.tkCoinMemberGetList(memberId),
      queryParams,
    );

    final response = await _apiClient.get(
      endpoint,
      requiresAuth: true,
    );

    return TKCoinTransactionListResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 取得會員的 TK幣取得記錄（舊 API，向後兼容）
  ///
  /// 取得指定會員的 TK 幣取得記錄。此為舊 API，建議使用統一 API
  /// [getTransactionList] 或 [getMemberTransactionList] 搭配 filter=grants。
  ///
  /// 參數:
  /// - [memberId]: 會員 ID
  ///
  /// 拋出異常:
  /// - [ForbiddenException]: 無權限查詢此會員的記錄
  /// - [UnauthorizedException]: 未登入
  ///
  /// 範例:
  /// ```dart
  /// final grants = await tkcoinService.getMemberGrants(10000);
  /// print('總獲得金額: ${grants.totalAmount}');
  /// ```
  @Deprecated('建議使用 getTransactionList 或 getMemberTransactionList 搭配 filter=grants')
  Future<TKCoinRecordsResponse> getMemberGrants(int memberId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tkCoinMemberGrants(memberId),
      requiresAuth: true,
    );

    return TKCoinRecordsResponse.fromJson(
      response['data'] as Map<String, dynamic>,
      'grants',
    );
  }

  /// 取得會員的 TK幣使用記錄（舊 API，向後兼容）
  ///
  /// 取得指定會員的 TK 幣使用記錄。此為舊 API，建議使用統一 API
  /// [getTransactionList] 或 [getMemberTransactionList] 搭配 filter=usages。
  ///
  /// 參數:
  /// - [memberId]: 會員 ID
  ///
  /// 拋出異常:
  /// - [ForbiddenException]: 無權限查詢此會員的記錄
  /// - [UnauthorizedException]: 未登入
  ///
  /// 範例:
  /// ```dart
  /// final usages = await tkcoinService.getMemberUsages(10000);
  /// print('總使用金額: ${usages.totalAmount}');
  /// ```
  @Deprecated('建議使用 getTransactionList 或 getMemberTransactionList 搭配 filter=usages')
  Future<TKCoinRecordsResponse> getMemberUsages(int memberId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tkCoinMemberUsages(memberId),
      requiresAuth: true,
    );

    return TKCoinRecordsResponse.fromJson(
      response['data'] as Map<String, dynamic>,
      'usages',
    );
  }

  /// 建立帶有查詢參數的端點
  ///
  /// 內部方法，用於構建帶有查詢參數的端點字符串
  String _buildEndpointWithQuery(
    String endpoint,
    Map<String, String> params,
  ) {
    if (params.isEmpty) {
      return endpoint;
    }

    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');

    return '$endpoint?$queryString';
  }

  /// 清理資源
  void dispose() {
    _apiClient.dispose();
  }
}
