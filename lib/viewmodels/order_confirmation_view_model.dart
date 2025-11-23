import '/viewmodels/base_view_model.dart';

/// ViewModel for order confirmation screen
class OrderConfirmationViewModel extends BaseViewModel {
  // 表單欄位
  String _recipientName = 'test';
  String _recipientPhone = '0913137997';
  String _recipientEmail = 'g@gmail.com';
  String _orderNote = '';

  // 是否使用會員資料
  bool _useMemberInfo = false;

  // 配送資訊
  String _deliveryMethod = '宅配';
  String _deliveryAddress = '(100) 台北市中正區';
  String _deliveryDetail = '好';

  // 付款方式
  String _paymentMethod = '貨到付款';

  // 發票類型
  String _invoiceType = '雲端發票';
  String _invoiceCarrierType = '載具類型:會員載具';

  // 現金券/折扣碼
  String? _voucherCode;
  double _voucherDiscount = 0.0;

  // TK幣
  final int _availableTkCoins = 500; // 可用 TK幣
  int _usedTkCoins = 0; // 使用的 TK幣
  bool _useTkCoins = false; // 是否使用 TK幣折抵

  // 訂單金額
  final double _subtotal = 1380.0;
  final int _itemCount = 1;

  // Getters
  String get recipientName => _recipientName;
  String get recipientPhone => _recipientPhone;
  String get recipientEmail => _recipientEmail;
  String get orderNote => _orderNote;
  bool get useMemberInfo => _useMemberInfo;

  String get deliveryMethod => _deliveryMethod;
  String get deliveryAddress => _deliveryAddress;
  String get deliveryDetail => _deliveryDetail;

  String get paymentMethod => _paymentMethod;

  String get invoiceType => _invoiceType;
  String get invoiceCarrierType => _invoiceCarrierType;

  String? get voucherCode => _voucherCode;
  double get voucherDiscount => _voucherDiscount;

  int get availableTkCoins => _availableTkCoins;
  int get usedTkCoins => _usedTkCoins;
  bool get useTkCoins => _useTkCoins;
  double get tkCoinDiscount => _usedTkCoins.toDouble(); // 1 TK幣 = 1 元

  double get subtotal => _subtotal;
  int get itemCount => _itemCount;

  /// 計算總金額
  double get totalAmount => _subtotal - _voucherDiscount - tkCoinDiscount;

  /// 格式化的總金額
  String get formattedTotal => 'NT\$${totalAmount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )}';

  // Setters
  void updateRecipientName(String value) {
    _recipientName = value;
    notifyListeners();
  }

  void updateRecipientPhone(String value) {
    _recipientPhone = value;
    notifyListeners();
  }

  void updateRecipientEmail(String value) {
    _recipientEmail = value;
    notifyListeners();
  }

  void updateOrderNote(String value) {
    _orderNote = value;
    notifyListeners();
  }

  void toggleUseMemberInfo(bool value) {
    _useMemberInfo = value;
    if (value) {
      // 當選擇「同會員資料」時，填入預設會員資料
      _recipientName = 'test';
      _recipientPhone = '0913137997';
      _recipientEmail = 'g@gmail.com';
    }
    notifyListeners();
  }

  void updateDeliveryMethod(String method, String address, String detail) {
    _deliveryMethod = method;
    _deliveryAddress = address;
    _deliveryDetail = detail;
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void updateInvoiceType(String type, String carrierType) {
    _invoiceType = type;
    _invoiceCarrierType = carrierType;
    notifyListeners();
  }

  void applyVoucher(String code, double discount) {
    _voucherCode = code;
    _voucherDiscount = discount;
    notifyListeners();
  }

  void removeVoucher() {
    _voucherCode = null;
    _voucherDiscount = 0.0;
    notifyListeners();
  }

  /// 切換是否使用 TK幣折抵
  void toggleUseTkCoins(bool value) {
    _useTkCoins = value;
    if (value) {
      // 計算可折抵的 TK幣數量（不超過可用數量，也不超過訂單金額）
      final maxDiscount = (_subtotal - _voucherDiscount).toInt();
      _usedTkCoins = _availableTkCoins > maxDiscount ? maxDiscount : _availableTkCoins;
    } else {
      _usedTkCoins = 0;
    }
    notifyListeners();
  }

  /// 更新使用的 TK幣數量
  void updateUsedTkCoins(int coins) {
    if (coins < 0) coins = 0;
    if (coins > _availableTkCoins) coins = _availableTkCoins;

    final maxDiscount = (_subtotal - _voucherDiscount).toInt();
    if (coins > maxDiscount) coins = maxDiscount;

    _usedTkCoins = coins;
    _useTkCoins = coins > 0;
    notifyListeners();
  }

  /// 提交訂單 (目前僅 UI，使用 demo 資料)
  Future<bool> submitOrder() async {
    setLoading();

    try {
      // 模擬 API 呼叫延遲
      await Future.delayed(const Duration(seconds: 2));

      // 驗證必填欄位
      if (_recipientName.isEmpty) {
        setError('請填寫收件人姓名');
        return false;
      }

      if (_recipientPhone.isEmpty) {
        setError('請填寫收件人手機');
        return false;
      }

      if (_recipientEmail.isEmpty) {
        setError('請填寫收件人 Email');
        return false;
      }

      // 模擬成功
      setSuccess();
      return true;
    } catch (e) {
      setError('訂單提交失敗：${e.toString()}');
      return false;
    }
  }

  /// 初始化 (載入預設資料或從購物車載入)
  Future<void> initialize() async {
    setLoading();

    try {
      // 模擬載入資料
      await Future.delayed(const Duration(milliseconds: 500));

      // 這裡可以從購物車或 API 載入實際資料
      // 目前使用 demo 資料

      setSuccess();
    } catch (e) {
      setError('載入資料失敗：${e.toString()}');
    }
  }
}
