import 'package:shared_preferences/shared_preferences.dart';

/// Manages authentication tokens using SharedPreferences
class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Save token data from login/signup response
  Future<void> saveTokenData({
    required String accessToken,
    String tokenType = 'Bearer',
    int? expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_tokenTypeKey, tokenType);
    if (expiresIn != null) {
      await prefs.setInt(_expiresInKey, expiresIn);
    }
  }

  /// Get token type
  Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  /// Get expires in
  Future<int?> getExpiresIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_expiresInKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_expiresInKey);
  }
}
