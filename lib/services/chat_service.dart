import 'package:tklab_ec_v2/models/chat_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// 聊天服務
/// 負責發送訊息和管理聊天室
class ChatService {
  final ApiClient _apiClient;

  ChatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// 發送文字訊息
  /// 調用 POST /api/chat/send
  ///
  /// [txt] 用戶發出的訊息
  /// 返回 [SendMessageResponse] 包含發送結果
  Future<SendMessageResponse> sendMessage(String txt) async {
    final response = await _apiClient.post(
      ApiEndpoints.chatSend,
      body: {'txt': txt},
      requiresAuth: true,
    );

    return SendMessageResponse.fromJson(response as Map<String, dynamic>);
  }

  /// 發送訊息（舊版相容方法）
  /// 返回發送的訊息物件
  Future<ChatMessage> sendMessageLegacy({
    required String message,
    String? imageUrl,
  }) async {
    final request = SendMessageRequest(
      message: message,
      imageUrl: imageUrl,
    );

    final response = await _apiClient.post(
      ApiEndpoints.chatSend,
      body: request.toJson(),
      requiresAuth: true,
    );

    return ChatMessage.fromJson(response as Map<String, dynamic>);
  }

  /// 獲取聊天訊息歷史（分頁）
  Future<List<ChatMessage>> getMessages({
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.chatMessages}?page=$page&per_page=$perPage',
      requiresAuth: true,
    );

    final messagesList = response['messages'] as List? ?? [];
    return messagesList
        .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
        .toList();
  }

  /// 發送圖片訊息
  Future<SendMessageResponse> sendImageMessage(String imageUrl) async {
    return await sendMessage('[圖片] $imageUrl');
  }

  /// 獲取聊天室列表
  Future<List<ChatRoom>> getChatRooms() async {
    final response = await _apiClient.get(
      ApiEndpoints.chatRooms,
      requiresAuth: true,
    );

    final roomsList = response['rooms'] as List? ?? [];
    return roomsList
        .map((room) => ChatRoom.fromJson(room as Map<String, dynamic>))
        .toList();
  }

  /// 獲取特定聊天室
  Future<ChatRoom> getChatRoom(int roomId) async {
    final response = await _apiClient.get(
      ApiEndpoints.chatRoom(roomId),
      requiresAuth: true,
    );

    return ChatRoom.fromJson(response as Map<String, dynamic>);
  }

  /// 獲取特定聊天室的訊息
  Future<List<ChatMessage>> getRoomMessages({
    required int roomId,
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.chatRoomMessages(roomId)}?page=$page&per_page=$perPage',
      requiresAuth: true,
    );

    final messagesList = response['messages'] as List? ?? [];
    return messagesList
        .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
        .toList();
  }

  /// 標記訊息為已讀
  Future<void> markAsRead(int messageId) async {
    await _apiClient.post(
      '/chat/message/$messageId/read',
      requiresAuth: true,
    );
  }

  /// 刪除訊息
  Future<bool> deleteMessage(int messageId) async {
    try {
      await _apiClient.delete(
        '/chat/message/$messageId',
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 釋放資源
  void dispose() {
    _apiClient.dispose();
  }
}
