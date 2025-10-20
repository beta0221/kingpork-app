import 'package:tklab_ec_v2/models/order_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// Order (Bill) service
class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Checkout and create order (requires authentication)
  ///
  /// Example:
  /// ```dart
  /// final result = await orderService.checkout(
  ///   recipient: '王小明',
  ///   phone: '0912345678',
  ///   city: '台北市',
  ///   district: '中正區',
  ///   address: '重慶南路一段122號',
  ///   paymentMethod: 'credit_card',
  ///   useBonus: 50,
  ///   note: '請在下午送達',
  /// );
  /// print('Order ID: ${result.billId}');
  /// print('Total: \$${result.finalTotal}');
  /// ```
  Future<CheckoutResponse> checkout({
    required String recipient,
    required String phone,
    required String city,
    required String district,
    required String address,
    required String paymentMethod,
    int? useBonus,
    String? note,
  }) async {
    final request = CheckoutRequest(
      recipient: recipient,
      phone: phone,
      city: city,
      district: district,
      address: address,
      paymentMethod: paymentMethod,
      useBonus: useBonus,
      note: note,
    );

    final response = await _apiClient.post(
      ApiEndpoints.billCheckout,
      body: request.toJson(),
      requiresAuth: true,
    );

    return CheckoutResponse.fromJson(response);
  }

  /// Get order list (requires authentication)
  ///
  /// Example:
  /// ```dart
  /// final orders = await orderService.getOrderList();
  /// for (var order in orders) {
  ///   print('${order.billNo} - ${order.statusText} - \$${order.total}');
  /// }
  /// ```
  Future<List<Order>> getOrderList() async {
    final response = await _apiClient.get(
      ApiEndpoints.billList,
      requiresAuth: true,
    );

    return (response as List)
        .map((order) => Order.fromJson(order as Map<String, dynamic>))
        .toList();
  }

  /// Get order detail (requires authentication)
  ///
  /// Example:
  /// ```dart
  /// final detail = await orderService.getOrderDetail(100);
  /// print('Order: ${detail.billNo}');
  /// print('Recipient: ${detail.recipient}');
  /// print('Address: ${detail.address}');
  /// print('Items:');
  /// for (var item in detail.items) {
  ///   print('  ${item.productName} x ${item.quantity}');
  /// }
  /// ```
  Future<OrderDetail> getOrderDetail(int billId) async {
    final response = await _apiClient.get(
      ApiEndpoints.billDetail(billId),
      requiresAuth: true,
    );

    return OrderDetail.fromJson(response);
  }

  /// Get payment token (requires authentication)
  ///
  /// Example:
  /// ```dart
  /// final tokenResponse = await orderService.getPaymentToken(100);
  /// print('Token: ${tokenResponse.token}');
  /// print('Payment URL: ${tokenResponse.paymentUrl}');
  /// ```
  Future<PaymentTokenResponse> getPaymentToken(int billId) async {
    final response = await _apiClient.get(
      ApiEndpoints.billToken(billId),
      requiresAuth: true,
    );

    return PaymentTokenResponse.fromJson(response);
  }

  /// Execute payment (requires authentication)
  ///
  /// Example:
  /// ```dart
  /// final paymentResult = await orderService.pay(
  ///   billId: 100,
  ///   paymentMethod: 'credit_card',
  /// );
  /// if (paymentResult.success) {
  ///   // Redirect to payment URL
  ///   launchUrl(Uri.parse(paymentResult.paymentUrl));
  /// }
  /// ```
  Future<PaymentResponse> pay({
    required int billId,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.billPay(billId),
      body: {'payment_method': paymentMethod},
      requiresAuth: true,
    );

    return PaymentResponse.fromJson(response);
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
