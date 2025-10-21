import 'package:tklab_ec_v2/models/message_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

/// Message/Notification service
class MessageService {
  final ApiClient _apiClient;

  MessageService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get messages/notifications with pagination
  ///
  /// Example:
  /// ```dart
  /// final response = await messageService.getMessages(page: 1);
  /// ```
  Future<MessagesResponse> getMessages({
    int page = 1,
    int perPage = 20,
    MessageType? type,
    bool? unreadOnly,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (type != null) {
      queryParams['type'] = type.toString().split('.').last;
    }

    if (unreadOnly == true) {
      queryParams['unread_only'] = '1';
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final response = await _apiClient.get(
      '${ApiEndpoints.messages}?$queryString',
      requiresAuth: true,
    );

    return MessagesResponse.fromJson(response);
  }

  /// Get unread message count
  ///
  /// Example:
  /// ```dart
  /// final unreadCount = await messageService.getUnreadCount();
  /// print('未讀訊息: ${unreadCount.unreadCount}');
  /// ```
  Future<UnreadCountResponse> getUnreadCount() async {
    final response = await _apiClient.get(
      ApiEndpoints.messageUnreadCount,
      requiresAuth: true,
    );

    return UnreadCountResponse.fromJson(response);
  }

  /// Mark a message as read
  Future<void> markAsRead(int messageId) async {
    await _apiClient.post(
      ApiEndpoints.messageRead(messageId),
      requiresAuth: true,
    );
  }

  /// Mark multiple messages as read
  Future<void> markMultipleAsRead(List<int> messageIds) async {
    await _apiClient.post(
      '${ApiEndpoints.messages}/mark-read',
      body: {'message_ids': messageIds},
      requiresAuth: true,
    );
  }

  /// Mark all messages as read
  Future<void> markAllAsRead({MessageType? type}) async {
    final body = <String, dynamic>{};
    if (type != null) {
      body['type'] = type.toString().split('.').last;
    }

    await _apiClient.post(
      '${ApiEndpoints.messages}/mark-all-read',
      body: body,
      requiresAuth: true,
    );
  }

  /// Delete a message
  Future<bool> deleteMessage(int messageId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.messageDelete(messageId),
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete multiple messages
  Future<bool> deleteMultipleMessages(List<int> messageIds) async {
    try {
      await _apiClient.post(
        '${ApiEndpoints.messages}/delete-multiple',
        body: {'message_ids': messageIds},
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get a single message detail
  Future<AppMessage> getMessage(int messageId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.messages}/$messageId',
      requiresAuth: true,
    );

    return AppMessage.fromJson(response);
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
