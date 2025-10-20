import 'package:shared_preferences/shared_preferences.dart';

/// Manages authentication tokens using SharedPreferences
class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _tokenSavedAtKey = 'token_saved_at';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setInt(_tokenSavedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Save token data from login/signup response
  Future<void> saveTokenData({
    required String accessToken,
    String? refreshToken,
    String tokenType = 'Bearer',
    int? expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_tokenTypeKey, tokenType);
    await prefs.setInt(_tokenSavedAtKey, now);

    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }

    if (expiresIn != null) {
      await prefs.setInt(_expiresInKey, expiresIn);
    }
  }

  /// Get token type
  Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  /// Get expires in (seconds)
  Future<int?> getExpiresIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_expiresInKey);
  }

  /// Get token saved timestamp
  Future<int?> getTokenSavedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tokenSavedAtKey);
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    final expiresIn = await getExpiresIn();
    final savedAt = await getTokenSavedAt();

    if (expiresIn == null || savedAt == null) {
      // 如果沒有過期資訊，假設 token 仍有效
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = savedAt + (expiresIn * 1000); // 轉換為毫秒

    // 提前 5 分鐘判定為過期，以便有時間刷新
    const bufferTime = 5 * 60 * 1000; // 5 分鐘的毫秒數
    return now >= (expiresAt - bufferTime);
  }

  /// Check if user is logged in and token is valid
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // 檢查 token 是否過期
    final expired = await isTokenExpired();
    return !expired;
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_expiresInKey);
    await prefs.remove(_tokenSavedAtKey);
  }
}
