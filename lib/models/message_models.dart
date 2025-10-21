/// Message/Notification model
class AppMessage {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? linkUrl;
  final MessageType type;
  final bool isRead;
  final String createdAt;

  AppMessage({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.linkUrl,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      linkUrl: json['link_url'] as String?,
      type: _parseMessageType(json['type'] as String?),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'type': type.toString().split('.').last,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }

  /// Create a copy with optional new values
  AppMessage copyWith({
    int? id,
    String? title,
    String? content,
    String? imageUrl,
    String? linkUrl,
    MessageType? type,
    bool? isRead,
    String? createdAt,
  }) {
    return AppMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static MessageType _parseMessageType(String? typeStr) {
    if (typeStr == null) return MessageType.general;

    switch (typeStr.toLowerCase()) {
      case 'system':
        return MessageType.system;
      case 'order':
        return MessageType.order;
      case 'promotion':
        return MessageType.promotion;
      case 'community':
        return MessageType.community;
      default:
        return MessageType.general;
    }
  }
}

/// Message type enum
enum MessageType {
  general,
  system,
  order,
  promotion,
  community,
}

/// Message list response
class MessagesResponse {
  final List<AppMessage> messages;
  final int total;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  MessagesResponse({
    required this.messages,
    required this.total,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['data'] as List)
          .map((item) => AppMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      unreadCount: json['unread_count'] as int? ?? 0,
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}

/// Unread count response
class UnreadCountResponse {
  final int unreadCount;
  final Map<MessageType, int> unreadByType;

  UnreadCountResponse({
    required this.unreadCount,
    required this.unreadByType,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    final unreadByTypeData = json['unread_by_type'] as Map<String, dynamic>? ?? {};
    final unreadByType = <MessageType, int>{};

    unreadByTypeData.forEach((key, value) {
      final type = AppMessage._parseMessageType(key);
      unreadByType[type] = value as int;
    });

    return UnreadCountResponse(
      unreadCount: json['unread_count'] as int? ?? 0,
      unreadByType: unreadByType,
    );
  }
}
