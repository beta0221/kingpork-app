import 'package:tklab_ec_v2/models/chat_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// Chat service for managing messages and chat rooms
class ChatService {
  final ApiClient _apiClient;

  ChatService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get chat message history with pagination
  ///
  /// Example:
  /// ```dart
  /// final messages = await chatService.getMessages(page: 1);
  /// ```
  Future<List<ChatMessage>> getMessages({
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.chatMessages}?page=$page&per_page=$perPage',
      requiresAuth: true,
    );

    final messagesList = response['messages'] as List;
    return messagesList
        .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
        .toList();
  }

  /// Send a text message
  ///
  /// Example:
  /// ```dart
  /// final message = await chatService.sendMessage(
  ///   message: '你好！',
  /// );
  /// ```
  Future<ChatMessage> sendMessage({
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

    return ChatMessage.fromJson(response);
  }

  /// Send an image message
  Future<ChatMessage> sendImageMessage(String imageUrl) async {
    return await sendMessage(
      message: '[圖片]',
      imageUrl: imageUrl,
    );
  }

  /// Get list of chat rooms
  Future<List<ChatRoom>> getChatRooms() async {
    final response = await _apiClient.get(
      ApiEndpoints.chatRooms,
      requiresAuth: true,
    );

    final roomsList = response['rooms'] as List;
    return roomsList
        .map((room) => ChatRoom.fromJson(room as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific chat room
  Future<ChatRoom> getChatRoom(int roomId) async {
    final response = await _apiClient.get(
      ApiEndpoints.chatRoom(roomId),
      requiresAuth: true,
    );

    return ChatRoom.fromJson(response);
  }

  /// Get messages for a specific chat room
  Future<List<ChatMessage>> getRoomMessages({
    required int roomId,
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.chatRoomMessages(roomId)}?page=$page&per_page=$perPage',
      requiresAuth: true,
    );

    final messagesList = response['messages'] as List;
    return messagesList
        .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
        .toList();
  }

  /// Mark message as read
  Future<void> markAsRead(int messageId) async {
    await _apiClient.post(
      '/chat/message/$messageId/read',
      requiresAuth: true,
    );
  }

  /// Delete a message
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

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
