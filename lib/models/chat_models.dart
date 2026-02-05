/// Chat Token 模型（用於 Long Polling 認證）
class ChatToken {
  final String accessToken;
  final DateTime obtainedAt;

  ChatToken({
    required this.accessToken,
    DateTime? obtainedAt,
  }) : obtainedAt = obtainedAt ?? DateTime.now();

  /// 檢查 token 是否過期（25分鐘後視為過期，預留 5 分鐘緩衝）
  bool get isExpired => DateTime.now().difference(obtainedAt).inMinutes >= 25;

  /// 檢查 token 是否有效
  bool get isValid => accessToken.isNotEmpty && !isExpired;

  factory ChatToken.fromJson(Map<String, dynamic> json) {
    return ChatToken(
      accessToken: json['access_token'] as String? ?? '',
    );
  }
}

/// Listen API 回應模型
class ListenResponse {
  final int s; // 1=有新訊息, 0=無, 其他=錯誤
  final String? m; // 錯誤說明
  final List<dynamic> data; // 新訊息陣列
  final int nextTs; // 下次查詢用時間戳

  ListenResponse({
    required this.s,
    this.m,
    required this.data,
    required this.nextTs,
  });

  /// 是否有新訊息
  bool get hasNewMessages => s == 1 && data.isNotEmpty;

  /// 是否無新訊息（正常輪詢結束）
  bool get noNewMessages => s == 0;

  /// 是否有錯誤
  bool get hasError => s != 0 && s != 1;

  factory ListenResponse.fromJson(Map<String, dynamic> json) {
    return ListenResponse(
      s: json['s'] as int? ?? -1,
      m: json['m'] as String?,
      data: json['Data'] as List<dynamic>? ?? [],
      nextTs: json['nextTs'] as int? ?? 0,
    );
  }
}

/// 發送訊息 API 回應模型
class SendMessageResponse {
  final int s; // 1=成功, 其他=失敗
  final String? m; // 簡易說明

  SendMessageResponse({
    required this.s,
    this.m,
  });

  /// 是否發送成功
  bool get isSuccess => s == 1;

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      s: json['s'] as int? ?? -1,
      m: json['m'] as String?,
    );
  }
}

/// 獲取 Token API 回應模型
class AskTokenResponse {
  final int s; // 1=成功, 其他=失敗
  final String? m; // 簡易說明
  final String? accessToken; // s=1 時返回

  AskTokenResponse({
    required this.s,
    this.m,
    this.accessToken,
  });

  /// 是否成功
  bool get isSuccess => s == 1 && accessToken != null;

  factory AskTokenResponse.fromJson(Map<String, dynamic> json) {
    return AskTokenResponse(
      s: json['s'] as int? ?? -1,
      m: json['m'] as String?,
      accessToken: json['access_token'] as String?,
    );
  }
}

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
