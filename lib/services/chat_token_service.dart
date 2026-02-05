import 'package:tklab_ec_v2/models/chat_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// 聊天 Token 服務
/// 負責管理聊天專用 token 的獲取、快取和自動刷新
class ChatTokenService {
  final ApiClient _apiClient;
  ChatToken? _cachedToken;

  ChatTokenService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// 獲取當前 token（如果有效）
  ChatToken? get currentToken => _cachedToken?.isValid == true ? _cachedToken : null;

  /// 確保有有效的 token
  /// 如果沒有有效 token，會自動獲取新的
  Future<ChatToken> ensureValidToken() async {
    if (_cachedToken != null && _cachedToken!.isValid) {
      return _cachedToken!;
    }
    return await askToken();
  }

  /// 向伺服器請求新的聊天 token
  /// 調用 POST /api/chat/askToken
  Future<ChatToken> askToken() async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chatAskToken,
        requiresAuth: true,
      );

      final askTokenResponse = AskTokenResponse.fromJson(response as Map<String, dynamic>);

      if (!askTokenResponse.isSuccess) {
        throw Exception(askTokenResponse.m ?? '獲取聊天 Token 失敗');
      }

      _cachedToken = ChatToken(accessToken: askTokenResponse.accessToken!);
      return _cachedToken!;
    } catch (e) {
      _cachedToken = null;
      rethrow;
    }
  }

  /// 清除快取的 token
  void clearToken() {
    _cachedToken = null;
  }

  /// 強制刷新 token
  Future<ChatToken> refreshToken() async {
    clearToken();
    return await askToken();
  }

  /// 釋放資源
  void dispose() {
    clearToken();
    _apiClient.dispose();
  }
}
