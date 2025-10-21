/// Chat message model
class ChatMessage {
  final int id;
  final String message;
  final String? imageUrl;
  final bool isFromUser;
  final String createdAt;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.message,
    this.imageUrl,
    required this.isFromUser,
    required this.createdAt,
    this.status = MessageStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      message: json['message'] as String,
      imageUrl: json['image_url'] as String?,
      isFromUser: json['is_from_user'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      status: MessageStatus.sent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'image_url': imageUrl,
      'is_from_user': isFromUser,
      'created_at': createdAt,
    };
  }

  /// Create a copy with optional new values
  ChatMessage copyWith({
    int? id,
    String? message,
    String? imageUrl,
    bool? isFromUser,
    String? createdAt,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      isFromUser: isFromUser ?? this.isFromUser,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

/// Message status enum
enum MessageStatus {
  sending,
  sent,
  failed,
  read,
}

/// Chat room information
class ChatRoom {
  final int id;
  final String title;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.title,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as int,
      title: json['title'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'is_active': isActive,
    };
  }
}

/// Send message request
class SendMessageRequest {
  final String message;
  final String? imageUrl;

  SendMessageRequest({
    required this.message,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}

/// WebSocket message types
enum WSMessageType {
  chat,
  notification,
  typing,
  read,
  error,
}

/// WebSocket message model
class WSMessage {
  final WSMessageType type;
  final dynamic data;

  WSMessage({
    required this.type,
    required this.data,
  });

  factory WSMessage.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = WSMessageType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => WSMessageType.chat,
    );

    return WSMessage(
      type: type,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'data': data,
    };
  }
}
