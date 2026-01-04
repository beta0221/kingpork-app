import 'package:tklab_ec_v2/models/tkcoin_models.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';
import 'package:tklab_ec_v2/services/tkcoin_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// TK幣 ViewModel
///
/// 管理 TK幣相關狀態，包括餘額查詢、交易記錄等
class TKCoinViewModel extends BaseViewModel {
  final TKCoinService _service;

  TKCoinBalanceResponse? _balance;

  /// 當前餘額資料
  TKCoinBalanceResponse? get balance => _balance;

  /// TK幣餘額（數值）
  int get tkCoinBalance => _balance?.balance ?? 0;

  /// 是否有餘額資料
  bool get hasBalance => _balance != null;

  /// 會員 ID
  int? get memberId => _balance?.memberId;

  /// 會員名稱
  String? get memberName => _balance?.memberName;

  TKCoinViewModel({TKCoinService? service}) : _service = service ?? TKCoinService();

  /// 載入 TK幣餘額
  ///
  /// 從 API 載入當前登入會員的 TK幣餘額
  /// 如果未登入會拋出 [UnauthorizedException]
  Future<void> loadBalance() async {
    setLoading();
    try {
      _balance = await _service.getBalance();
      setSuccess();
    } on UnauthorizedException {
      // 未登入，清除資料
      _balance = null;
      setError('請先登入');
    } catch (e) {
      _balance = null;
      setError('載入 TK幣餘額失敗: ${e.toString()}');
    }
  }

  /// 刷新餘額
  ///
  /// 重新從 API 載入餘額資料
  Future<void> refresh() async {
    await loadBalance();
  }

  /// 清除資料
  ///
  /// 登出或刪除帳號時呼叫，清除所有 TK幣相關資料
  void clear() {
    _balance = null;
    setIdle();
  }
}
