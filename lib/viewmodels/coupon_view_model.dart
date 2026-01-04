import 'package:tklab_ec_v2/models/coupon_models.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';
import 'package:tklab_ec_v2/services/coupon_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// 優惠券 ViewModel
///
/// 管理優惠券數量狀態，用於在 RewardsCard 中顯示未使用優惠券數量
class CouponViewModel extends BaseViewModel {
  final CouponService _service;

  int _unusedCouponCount = 0;

  /// 未使用優惠券數量
  int get unusedCouponCount => _unusedCouponCount;

  /// 是否有未使用的優惠券（用於通知徽章）
  bool get hasUnusedCoupon => _unusedCouponCount > 0;

  CouponViewModel({CouponService? service}) : _service = service ?? CouponService();

  /// 載入未使用的優惠券數量
  ///
  /// 只查詢 pagination 資訊，不載入完整優惠券列表以提高效能
  Future<void> loadUnusedCouponCount() async {
    setLoading();
    try {
      // 只需要 pagination.totalRecords，設置 perPage=1 避免載入大量資料
      final response = await _service.getMyCoupons(
        page: 1,
        perPage: 1,
        status: CouponStatus.unused, // 只查詢未使用的優惠券
      );

      _unusedCouponCount = response.pagination.totalRecords;
      setSuccess();
    } on UnauthorizedException {
      // 未登入，清除資料
      _unusedCouponCount = 0;
      setError('請先登入');
    } catch (e) {
      _unusedCouponCount = 0;
      setError('載入優惠券數量失敗: ${e.toString()}');
    }
  }

  /// 刷新優惠券數量
  Future<void> refresh() async {
    await loadUnusedCouponCount();
  }

  /// 清除資料
  ///
  /// 登出或刪除帳號時呼叫，清除所有優惠券相關資料
  void clear() {
    _unusedCouponCount = 0;
    setIdle();
  }
}
