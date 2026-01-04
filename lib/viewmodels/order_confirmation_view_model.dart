import '/viewmodels/base_view_model.dart';
import '/services/tkcoin_service.dart';
import '/services/coupon_service.dart';
import '/services/api/api_exception.dart';
import '/models/coupon_models.dart';
import '/models/checkout_options.dart';

/// ViewModel for order confirmation screen
class OrderConfirmationViewModel extends BaseViewModel {
  final TKCoinService _tkCoinService;
  final CouponService _couponService;

  OrderConfirmationViewModel({
    TKCoinService? tkCoinService,
    CouponService? couponService,
  })  : _tkCoinService = tkCoinService ?? TKCoinService(),
        _couponService = couponService ?? CouponService();
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
  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.homeDelivery;

  // 付款方式
  String _paymentMethod = '貨到付款';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;

  // 發票類型
  String _invoiceType = '雲端發票';
  String _invoiceCarrierType = '載具類型:會員載具';
  InvoiceType _selectedInvoiceType = InvoiceType.cloud;
  String? _invoiceDonationCode; // 捐贈碼
  String? _invoiceCompanyId; // 統一編號
  String? _invoiceCompanyTitle; // 公司抬頭

  // 現金券/折扣碼
  String? _voucherCode;
  double _voucherDiscount = 0.0;
  List<MyCoupon> _availableCoupons = [];
  bool _isCouponsLoading = false;
  String? _couponsError;
  MyCoupon? _selectedCoupon;

  // TK幣
  int _availableTkCoins = 0; // 可用 TK幣（從 API 載入）
  bool _isTkCoinsLoading = false;
  String? _tkCoinsError;
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
  DeliveryMethod get selectedDeliveryMethod => _selectedDeliveryMethod;

  String get paymentMethod => _paymentMethod;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;

  String get invoiceType => _invoiceType;
  String get invoiceCarrierType => _invoiceCarrierType;
  InvoiceType get selectedInvoiceType => _selectedInvoiceType;
  String? get invoiceDonationCode => _invoiceDonationCode;
  String? get invoiceCompanyId => _invoiceCompanyId;
  String? get invoiceCompanyTitle => _invoiceCompanyTitle;

  String? get voucherCode => _voucherCode;
  double get voucherDiscount => _voucherDiscount;
  List<MyCoupon> get availableCoupons => _availableCoupons;
  bool get isCouponsLoading => _isCouponsLoading;
  String? get couponsError => _couponsError;
  MyCoupon? get selectedCoupon => _selectedCoupon;

  int get availableTkCoins => _availableTkCoins;
  bool get isTkCoinsLoading => _isTkCoinsLoading;
  String? get tkCoinsError => _tkCoinsError;
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

  /// 更新送貨方式（使用枚舉）
  void updateDeliveryMethodEnum(DeliveryMethod method) {
    _selectedDeliveryMethod = method;
    _deliveryMethod = method.displayText; // 同步舊的字串欄位
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  /// 更新付款方式（使用枚舉）
  void updatePaymentMethodEnum(PaymentMethod method) {
    _selectedPaymentMethod = method;
    _paymentMethod = method.displayText; // 同步舊的字串欄位
    notifyListeners();
  }

  void updateInvoiceType(String type, String carrierType) {
    _invoiceType = type;
    _invoiceCarrierType = carrierType;
    notifyListeners();
  }

  /// 更新發票類型（使用枚舉）
  void updateInvoiceTypeEnum(
    InvoiceType type, {
    String? donationCode,
    String? companyId,
    String? companyTitle,
  }) {
    _selectedInvoiceType = type;
    _invoiceType = type.displayText; // 同步舊的字串欄位

    // 根據類型清理或設置額外資訊
    switch (type) {
      case InvoiceType.cloud:
        _invoiceDonationCode = null;
        _invoiceCompanyId = null;
        _invoiceCompanyTitle = null;
        break;
      case InvoiceType.donation:
        _invoiceDonationCode = donationCode;
        _invoiceCompanyId = null;
        _invoiceCompanyTitle = null;
        break;
      case InvoiceType.triplicate:
        _invoiceDonationCode = null;
        _invoiceCompanyId = companyId;
        _invoiceCompanyTitle = companyTitle;
        break;
    }

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

  /// 初始化 (載入 TK幣餘額和現金券列表)
  Future<void> initialize() async {
    setLoading();

    try {
      // 並行調用兩個 API
      await Future.wait([
        _loadTkCoinBalance(),
        _loadAvailableCoupons(),
      ]);

      // 即使 API 失敗，也設置為成功狀態，不阻塞頁面
      setSuccess();
    } catch (e) {
      // 即使載入失敗，也允許繼續操作
      setSuccess();
    }
  }

  /// 載入 TK幣餘額
  Future<void> _loadTkCoinBalance() async {
    try {
      _isTkCoinsLoading = true;
      notifyListeners();

      final response = await _tkCoinService.getBalance();
      _availableTkCoins = response.balance;
      _tkCoinsError = null;
    } on UnauthorizedException {
      _availableTkCoins = 0;
      _tkCoinsError = '請先登入以使用 TK幣';
    } on ApiException catch (e) {
      _availableTkCoins = 0;
      _tkCoinsError = e.message;
    } catch (e) {
      _availableTkCoins = 0;
      _tkCoinsError = '載入 TK幣失敗';
    } finally {
      _isTkCoinsLoading = false;
      notifyListeners();
    }
  }

  /// 載入可用現金券列表
  Future<void> _loadAvailableCoupons() async {
    try {
      _isCouponsLoading = true;
      notifyListeners();

      // 只載入未使用且未過期的現金券
      final response = await _couponService.getMyCoupons(
        status: CouponStatus.unused,
        perPage: 100, // 載入所有可用現金券
      );

      // 過濾掉已過期的現金券
      _availableCoupons = response.data.where((coupon) => !coupon.isExpired).toList();
      _couponsError = null;
    } on UnauthorizedException {
      _availableCoupons = [];
      _couponsError = '請先登入以使用現金券';
    } on ApiException catch (e) {
      _availableCoupons = [];
      _couponsError = e.message;
    } catch (e) {
      _availableCoupons = [];
      _couponsError = '載入現金券失敗';
    } finally {
      _isCouponsLoading = false;
      notifyListeners();
    }
  }

  /// 選擇現金券
  void selectCoupon(MyCoupon? coupon) {
    _selectedCoupon = coupon;

    if (coupon != null) {
      // 根據現金券類型計算折扣
      if (coupon.type == CouponType.cash && coupon.value != null) {
        // 現金券: 固定金額，但不超過訂單金額
        final discount = coupon.value!.toInt();
        final maxDiscount = (_subtotal - tkCoinDiscount).toInt();
        _voucherDiscount = discount > maxDiscount ? maxDiscount.toDouble() : discount.toDouble();
      } else if (coupon.type == CouponType.discount && coupon.value != null) {
        // 折價券: 百分比折扣
        var discount = (_subtotal * (1 - coupon.value!)).toDouble();
        // 檢查封頂金額
        if (coupon.maxDiscountAmount != null && discount > coupon.maxDiscountAmount!) {
          discount = coupon.maxDiscountAmount!.toDouble();
        }
        _voucherDiscount = discount;
      } else {
        _voucherDiscount = 0.0;
      }

      _voucherCode = coupon.title;
    } else {
      _voucherCode = null;
      _voucherDiscount = 0.0;
    }

    notifyListeners();
  }

  /// 透過序號領取現金券
  Future<bool> claimCouponByCode(String code) async {
    if (code.trim().isEmpty) {
      setError('請輸入現金券序號');
      return false;
    }

    setLoading();

    try {
      // 調用領取 API
      final response = await _couponService.claimCouponByCode(code.trim());

      // 領取成功後，重新載入現金券列表
      await _loadAvailableCoupons();

      // 找到剛領取的現金券並自動套用
      final claimedCoupon = _availableCoupons.firstWhere(
        (c) => c.redemptionId == response.redemptionId,
        orElse: () => _availableCoupons.isNotEmpty ? _availableCoupons.first : throw Exception('找不到剛領取的現金券'),
      );

      selectCoupon(claimedCoupon);

      setSuccess();
      return true;
    } on UnauthorizedException {
      setError('請先登入以領取現金券');
      return false;
    } on NotFoundException {
      setError('無效的現金券序號');
      return false;
    } on ForbiddenException {
      setError('您的會員等級不符合此現金券的領取資格');
      return false;
    } on ApiException catch (e) {
      setError(e.message);
      return false;
    } catch (e) {
      setError('領取現金券失敗：${e.toString()}');
      return false;
    }
  }

  /// 刷新 TK幣餘額
  Future<void> refreshTkCoinBalance() async {
    await _loadTkCoinBalance();
  }

  /// 刷新現金券列表
  Future<void> refreshCoupons() async {
    await _loadAvailableCoupons();
  }

  @override
  void dispose() {
    _tkCoinService.dispose();
    _couponService.dispose();
    super.dispose();
  }
}
