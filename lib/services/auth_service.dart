import 'package:tklab_ec_v2/models/address_model.dart';
import 'package:tklab_ec_v2/models/auth_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';
import 'package:tklab_ec_v2/utils/token_manager.dart';

/// Authentication service
class AuthService {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  AuthService({
    ApiClient? apiClient,
    TokenManager? tokenManager,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenManager = tokenManager ?? TokenManager();

  /// Login with email and password
  ///
  /// Example:
  /// ```dart
  /// final response = await authService.login('user@example.com', 'password123');
  /// print('Welcome ${response.user.name}');
  /// ```
  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response);

    // Save token
    await _tokenManager.saveTokenData(
      accessToken: loginResponse.accessToken,
      tokenType: loginResponse.tokenType,
      expiresIn: loginResponse.expiresIn,
    );

    return loginResponse;
  }

  /// Register a new user
  ///
  /// Example:
  /// ```dart
  /// final response = await authService.register(
  ///   name: '王小明',
  ///   email: 'user@example.com',
  ///   password: 'password123',
  ///   passwordConfirmation: 'password123',
  /// );
  /// ```
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final request = RegisterRequest(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    final response = await _apiClient.post(
      ApiEndpoints.signup,
      body: request.toJson(),
    );

    final registerResponse = RegisterResponse.fromJson(response);

    // Save token
    await _tokenManager.saveTokenData(
      accessToken: registerResponse.accessToken,
      tokenType: registerResponse.tokenType,
    );

    return registerResponse;
  }

  /// Get current user information (requires authentication)
  ///
  /// Example:
  /// ```dart
  /// final user = await authService.getUser();
  /// print('Bonus: ${user.bonus}');
  /// ```
  Future<User> getUser() async {
    final response = await _apiClient.get(
      ApiEndpoints.user,
      requiresAuth: true,
    );

    return User.fromJson(response);
  }

  /// Logout (requires authentication)
  ///
  /// Example:
  /// ```dart
  /// await authService.logout();
  /// Navigator.pushReplacementNamed(context, '/login');
  /// ```
  Future<void> logout() async {
    await _apiClient.post(
      ApiEndpoints.logout,
      requiresAuth: true,
    );

    // Clear local tokens
    await _tokenManager.clearTokens();
  }

  /// Get user addresses (requires authentication)
  ///
  /// Example:
  /// ```dart
  /// final addresses = await authService.getAddresses();
  /// final defaultAddress = addresses.firstWhere((a) => a.isDefault);
  /// ```
  Future<List<Address>> getAddresses() async {
    final response = await _apiClient.get(
      ApiEndpoints.addresses,
      requiresAuth: true,
    );

    return (response as List)
        .map((address) => Address.fromJson(address as Map<String, dynamic>))
        .toList();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _tokenManager.isLoggedIn();
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
