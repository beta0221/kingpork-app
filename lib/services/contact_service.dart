import 'package:shop/models/contact_model.dart';
import 'package:shop/services/api/api_client.dart';
import 'package:shop/services/api/api_endpoints.dart';

/// Contact service
class ContactService {
  final ApiClient _apiClient;

  ContactService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Send contact form
  ///
  /// Example:
  /// ```dart
  /// final result = await contactService.sendContactForm(
  ///   name: '王小明',
  ///   email: 'contact@example.com',
  ///   phone: '0912345678',
  ///   message: '我想詢問商品資訊',
  /// );
  /// print(result.message); // "已收到您的訊息，我們會盡快回覆"
  /// ```
  Future<ContactResponse> sendContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    final request = ContactRequest(
      name: name,
      email: email,
      phone: phone,
      message: message,
    );

    final response = await _apiClient.post(
      ApiEndpoints.contact,
      body: request.toJson(),
    );

    return ContactResponse.fromJson(response);
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
