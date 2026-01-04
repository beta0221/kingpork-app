import 'package:tklab_ec_v2/models/coupon_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';

/// 優惠券服務
///
/// 提供優惠券系統的所有功能，包括：
/// - 自動發放優惠券
/// - 領取優惠券（透過 ID 或序號）
/// - 查詢可領取的優惠券列表
/// - 查詢我的優惠券
/// - 使用優惠券
///
/// 所有方法都需要會員登入（Session 認證），除了 checkAutoGrant 在未登入時會返回空結果而不拋出異常
class CouponService {
  final ApiClient _apiClient;

  CouponService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// 檢查並自動發放優惠券
  ///
  /// App 啟動時呼叫，系統會自動檢查並發放符合條件的「登入自動送」優惠券。
  /// 未登入時返回空列表，不拋出異常。
  ///
  /// 拋出異常:
  /// - [ApiException]: API 錯誤（會員資料不存在等）
  ///
  /// 注意事項:
  /// - 建議加入 debounce 機制，避免短時間內重複呼叫
  /// - 系統會自動檢查避免重複發放
  ///
  /// 範例:
  /// ```dart
  /// final service = CouponService();
  /// try {
  ///   final result = await service.checkAutoGrant();
  ///   if (result.grantedCount > 0) {
  ///     print('已自動發放 ${result.grantedCount} 張優惠券');
  ///   }
  /// } catch (e) {
  ///   // 錯誤處理（不影響 App 啟動）
  /// }
  /// ```
  Future<CheckAutoGrantResponse> checkAutoGrant() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.couponCheckAutoGrant,
        requiresAuth: true,
      );

      return CheckAutoGrantResponse.fromJson(response);
    } on UnauthorizedException {
      // 未登入時返回空結果，不拋出異常
      return CheckAutoGrantResponse.empty();
    }
  }

  /// 領取優惠券（透過優惠券 ID）
  ///
  /// 會員自行領取優惠券（distribution_method=2 的優惠券）。
  ///
  /// 參數:
  /// - [couponId]: 優惠券 ID
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [ApiException]: 領取失敗（已達領取次數限制、不符合資格或優惠券已失效）
  ///
  /// 檢查項目:
  /// - 優惠券狀態（必須啟用）
  /// - 活動時間範圍
  /// - 領取時間範圍
  /// - 會員等級限制
  /// - 領取次數限制
  ///
  /// 範例:
  /// ```dart
  /// try {
  ///   final result = await service.claimCoupon(1);
  ///   print('領取成功，redemption_id: ${result.redemptionId}');
  /// } on ApiException catch (e) {
  ///   print('領取失敗: ${e.message}');
  /// }
  /// ```
  Future<ClaimCouponResponse> claimCoupon(int couponId) async {
    final response = await _apiClient.get(
      ApiEndpoints.couponClaim(couponId),
      requiresAuth: true,
    );

    return ClaimCouponResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 透過序號領取優惠券
  ///
  /// 會員透過優惠券序號領取優惠券。此 API 主要用於「行銷活動」類型的優惠券，
  /// 支援分享連結領取功能。系統會先從 coupons.code 查詢，如果找不到則從
  /// coupon_codes 表查詢（批次發碼模式）。
  ///
  /// 參數:
  /// - [code]: 優惠券序號
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [ForbiddenException]: 會員等級不符合此優惠券的領取資格
  /// - [NotFoundException]: 無效的優惠券序號或會員資料不存在
  /// - [ApiException]: 領取失敗（已失效、未開始、已結束、已達領取次數等）
  ///
  /// 檢查項目:
  /// - 序號不能為空
  /// - 優惠券狀態（必須啟用）
  /// - 活動時間範圍
  /// - 領取時間範圍
  /// - 會員等級限制
  /// - 領取次數限制
  /// - 批次發碼模式下，檢查序號是否已被使用
  ///
  /// 使用場景:
  /// - 行銷活動優惠券分享連結領取
  /// - 批次發放的優惠券序號領取
  /// - 單一序號優惠券領取
  ///
  /// 注意事項:
  /// - 此 API 支援兩種模式：
  ///   1. 單一序號模式：優惠券的 code 欄位直接作為序號
  ///   2. 批次發碼模式：從 coupon_codes 表查詢，每個序號只能被使用一次
  /// - 如果是批次發碼模式，領取成功後會自動更新 coupon_codes 表的狀態為 used 並關聯到會員 ID
  ///
  /// 範例:
  /// ```dart
  /// try {
  ///   final result = await service.claimCouponByCode('WELCOME20');
  ///   print('領取成功，序號: ${result.couponCode}');
  /// } on NotFoundException {
  ///   print('無效的優惠券序號');
  /// } on ForbiddenException {
  ///   print('您的會員等級不符合此優惠券的領取資格');
  /// }
  /// ```
  Future<ClaimCouponResponse> claimCouponByCode(String code) async {
    final response = await _apiClient.get(
      ApiEndpoints.couponClaimByCode(code),
      requiresAuth: true,
    );

    return ClaimCouponResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 取得登入自行領取的優惠券列表
  ///
  /// 取得可自行領取的優惠券列表（distribution_method=2）。
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [ApiException]: API 錯誤
  ///
  /// 回應包含:
  /// - 優惠券完整資訊
  /// - has_redeemed: 是否已領取
  /// - redemption_count: 已領取次數
  ///
  /// 範例:
  /// ```dart
  /// final coupons = await service.getCouponList();
  /// for (var coupon in coupons) {
  ///   print('${coupon.title} - ${coupon.hasRedeemed ? "已領取" : "可領取"}');
  /// }
  /// ```
  Future<List<Coupon>> getCouponList() async {
    final response = await _apiClient.get(
      ApiEndpoints.couponList,
      requiresAuth: true,
    );

    return (response['data'] as List).map((item) => Coupon.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// 取得登入自動送的優惠券列表
  ///
  /// 取得登入自動送的優惠券列表（distribution_method=1）。
  /// 這些優惠券會在 App/網頁啟動時自動發放。
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [ApiException]: API 錯誤
  ///
  /// 回應包含:
  /// - 優惠券完整資訊
  /// - has_redeemed: 是否已領取
  /// - redemption_count: 已領取次數
  ///
  /// 範例:
  /// ```dart
  /// final autoCoupons = await service.getAutoGrantList();
  /// print('自動送優惠券數量: ${autoCoupons.length}');
  /// ```
  Future<List<Coupon>> getAutoGrantList() async {
    final response = await _apiClient.get(
      ApiEndpoints.couponAutoGrantList,
      requiresAuth: true,
    );

    return (response['data'] as List).map((item) => Coupon.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// 取得我的優惠券（已領取）
  ///
  /// 取得會員已領取的優惠券列表，支援分頁和狀態篩選。
  ///
  /// 參數:
  /// - [page]: 頁碼，預設 1
  /// - [perPage]: 每頁筆數，預設 20，最大 100
  /// - [status]: 狀態篩選（1=未使用, 2=已使用, 4=已過期）
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [ApiException]: API 錯誤
  ///
  /// 回應包含:
  /// - 優惠券列表，每個項目包含:
  ///   - redemption_id: 領取記錄 ID
  ///   - status: 使用狀態（未使用/已使用/已過期）
  ///   - used_at: 使用時間（未使用時為 null）
  ///   - order_id: 訂單編號（未使用時為 null）
  ///   - discount_amount: 折抵金額（未使用時為 null）
  /// - 分頁資訊
  ///
  /// 範例:
  /// ```dart
  /// // 取得第 1 頁的未使用優惠券
  /// final page1 = await service.getMyCoupons(
  ///   page: 1,
  ///   perPage: 20,
  ///   status: CouponStatus.unused,
  /// );
  ///
  /// print('未使用優惠券: ${page1.data.length} 張');
  /// print('總頁數: ${page1.pagination.totalPages}');
  ///
  /// if (page1.pagination.hasNextPage) {
  ///   final page2 = await service.getMyCoupons(
  ///     page: 2,
  ///     perPage: 20,
  ///     status: CouponStatus.unused,
  ///   );
  /// }
  /// ```
  Future<MyCouponsResponse> getMyCoupons({
    int page = 1,
    int perPage = 20,
    CouponStatus? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (status != null) {
      queryParams['status'] = status.value.toString();
    }

    final endpoint = _buildEndpointWithQuery(
      ApiEndpoints.couponMyCoupons,
      queryParams,
    );

    final response = await _apiClient.get(
      endpoint,
      requiresAuth: true,
    );

    return MyCouponsResponse.fromJson(response);
  }

  /// 使用優惠券
  ///
  /// 結帳時使用優惠券，系統會檢查使用條件並計算折抵金額。
  ///
  /// 參數:
  /// - [request]: 使用優惠券請求，包含:
  ///   - redemption_id: 領取記錄 ID（從「我的優惠券」取得）
  ///   - order_id: 訂單編號
  ///   - order_amount: 訂單總金額
  ///   - order_items: 訂單商品列表（選填，用於檢查使用範圍限制）
  ///
  /// 拋出異常:
  /// - [UnauthorizedException]: 未登入
  /// - [NotFoundException]: 優惠券領取記錄不存在
  /// - [ValidationException]: 驗證失敗（缺少必填欄位）
  /// - [ApiException]: 使用失敗（已使用、已過期、不符合使用條件）
  ///
  /// 檢查項目:
  /// - 優惠券狀態（必須未使用）
  /// - 優惠券是否過期
  /// - 生效條件（最低訂單金額/件數）
  /// - 使用範圍限制（指定商品/賣場）
  ///
  /// 折抵金額計算:
  /// - 折價券（type=1）: 訂單金額 × value，如有封頂則不超過 max_discount_amount
  /// - 現金券（type=2）: 固定金額 value，但不超過訂單金額
  /// - 禮物券（type=4）: 不折抵金額（discount_amount=0）
  ///
  /// 範例:
  /// ```dart
  /// final request = UseCouponRequest(
  ///   redemptionId: 123,
  ///   orderId: 'ORD20250101001',
  ///   orderAmount: 1000,
  ///   orderItems: [
  ///     OrderItem(productId: 1, storeId: 2, amount: 500),
  ///     OrderItem(productId: 3, storeId: 2, amount: 500),
  ///   ],
  /// );
  ///
  /// try {
  ///   final result = await service.useCoupon(request);
  ///   print('折抵金額: ${result.discountAmount}');
  /// } on ApiException catch (e) {
  ///   print('使用失敗: ${e.message}');
  /// }
  /// ```
  Future<UseCouponResponse> useCoupon(UseCouponRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.couponUse,
      body: request.toJson(),
      requiresAuth: true,
    );

    return UseCouponResponse.fromJson(response['data'] as Map<String, dynamic>);
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
