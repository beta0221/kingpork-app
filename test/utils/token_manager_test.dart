import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tklab_ec_v2/utils/token_manager.dart';

void main() {
  group('TokenManager Tests', () {
    late TokenManager tokenManager;

    setUp(() async {
      // 初始化 SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
      tokenManager = TokenManager();
    });

    test('saveAccessToken and getAccessToken', () async {
      const testToken = 'test_access_token_12345';
      await tokenManager.saveAccessToken(testToken);

      final retrievedToken = await tokenManager.getAccessToken();
      expect(retrievedToken, testToken);
    });

    test('saveTokenData saves all token information', () async {
      await tokenManager.saveTokenData(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      final accessToken = await tokenManager.getAccessToken();
      final refreshToken = await tokenManager.getRefreshToken();
      final tokenType = await tokenManager.getTokenType();
      final expiresIn = await tokenManager.getExpiresIn();

      expect(accessToken, 'access_token_123');
      expect(refreshToken, 'refresh_token_456');
      expect(tokenType, 'Bearer');
      expect(expiresIn, 3600);
    });

    test('isLoggedIn returns false when no token exists', () async {
      final loggedIn = await tokenManager.isLoggedIn();
      expect(loggedIn, false);
    });

    test('isLoggedIn returns true when valid token exists', () async {
      await tokenManager.saveTokenData(
        accessToken: 'valid_token',
        expiresIn: 7200, // 2 hours
      );

      final loggedIn = await tokenManager.isLoggedIn();
      expect(loggedIn, true);
    });

    test('isTokenExpired returns false for non-expired token', () async {
      await tokenManager.saveTokenData(
        accessToken: 'valid_token',
        expiresIn: 7200, // 2 hours - should not be expired
      );

      final expired = await tokenManager.isTokenExpired();
      expect(expired, false);
    });

    test('isTokenExpired returns false when no expiry info', () async {
      await tokenManager.saveAccessToken('token_without_expiry');

      final expired = await tokenManager.isTokenExpired();
      expect(expired, false); // 假設仍有效
    });

    test('clearTokens removes all token data', () async {
      await tokenManager.saveTokenData(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        tokenType: 'Bearer',
        expiresIn: 3600,
      );

      await tokenManager.clearTokens();

      final accessToken = await tokenManager.getAccessToken();
      final refreshToken = await tokenManager.getRefreshToken();
      final tokenType = await tokenManager.getTokenType();
      final expiresIn = await tokenManager.getExpiresIn();

      expect(accessToken, null);
      expect(refreshToken, null);
      expect(tokenType, null);
      expect(expiresIn, null);
    });

    test('getTokenSavedAt stores timestamp when saving token', () async {
      final beforeSave = DateTime.now().millisecondsSinceEpoch;
      await tokenManager.saveAccessToken('test_token');
      final savedAt = await tokenManager.getTokenSavedAt();

      expect(savedAt, isNotNull);
      expect(savedAt! >= beforeSave, true);
    });
  });
}
