import 'dart:async';
import 'package:tklab_ec_v2/models/chat_models.dart';
import 'package:tklab_ec_v2/services/chat_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';
import 'package:tklab_ec_v2/config/flavor_config.dart';

/// ChatViewModel manages chat messages and WebSocket connection
/// Note: WebSocket implementation will be completed in Phase 3
class ChatViewModel extends BaseViewModel {
  final ChatService _chatService;

  List<ChatMessage> _messages = [];
  bool _isConnected = false;
  bool _isTyping = false;
  StreamSubscription? _messageSubscription;

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;
  bool get isTyping => _isTyping;
  int get messageCount => _messages.length;

  String get websocketUrl => FlavorConfig.instance.wssUrl;

  ChatViewModel({ChatService? chatService})
      : _chatService = chatService ?? ChatService();

  /// Initialize chat - load message history
  Future<void> initialize() async {
    setLoading();
    try {
      await loadMessages();
      // TODO: Connect to WebSocket in Phase 3
      // await _connectWebSocket();
      setSuccess();
    } catch (e) {
      setError('初始化聊天失敗: ${e.toString()}');
    }
  }

  /// Load message history from API
  Future<void> loadMessages() async {
    try {
      _messages = await _chatService.getMessages();
      notifyListeners();
    } catch (e) {
      setError('載入訊息失敗: ${e.toString()}');
    }
  }

  /// Send a text message
  Future<bool> sendMessage(String message) async {
    if (message.trim().isEmpty) return false;

    try {
      // Create temporary message with sending status
      final tempMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch, // temporary ID
        message: message,
        isFromUser: true,
        createdAt: DateTime.now().toIso8601String(),
        status: MessageStatus.sending,
      );

      _messages.add(tempMessage);
      notifyListeners();

      // Send via API (WebSocket will be implemented in Phase 3)
      final sentMessage = await _chatService.sendMessage(message: message);

      // Update message with real ID from server
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage.copyWith(status: MessageStatus.sent);
        notifyListeners();
      }

      return true;
    } catch (e) {
      // Mark message as failed
      setError('發送訊息失敗: ${e.toString()}');
      return false;
    }
  }

  /// Send an image message
  Future<bool> sendImageMessage(String imageUrl) async {
    try {
      final tempMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        message: '[圖片]',
        imageUrl: imageUrl,
        isFromUser: true,
        createdAt: DateTime.now().toIso8601String(),
        status: MessageStatus.sending,
      );

      _messages.add(tempMessage);
      notifyListeners();

      // Send via API
      final sentMessage = await _chatService.sendImageMessage(imageUrl);

      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage.copyWith(status: MessageStatus.sent);
        notifyListeners();
      }

      return true;
    } catch (e) {
      setError('發送圖片失敗: ${e.toString()}');
      return false;
    }
  }

  /// Handle incoming message (from WebSocket)
  void onMessageReceived(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Set typing indicator
  void setTyping(bool typing) {
    if (_isTyping != typing) {
      _isTyping = typing;
      notifyListeners();
    }
  }

  /// Connect to WebSocket
  Future<void> connectWebSocket() async {
    try {
      // TODO: Implement WebSocket connection in Phase 3
      // _wsChannel = WebSocketChannel.connect(Uri.parse(websocketUrl));
      // _messageSubscription = _wsChannel.stream.listen(
      //   _handleWebSocketMessage,
      //   onError: _handleWebSocketError,
      //   onDone: _handleWebSocketClose,
      // );

      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      setError('WebSocket 連接失敗: ${e.toString()}');
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnectWebSocket() async {
    try {
      await _messageSubscription?.cancel();
      _messageSubscription = null;
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      // Silent fail on disconnect
    }
  }

  /// Reconnect WebSocket
  Future<void> reconnect() async {
    await disconnectWebSocket();
    await Future.delayed(const Duration(seconds: 1));
    await connectWebSocket();
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  /// Retry sending failed message
  Future<bool> retryMessage(int messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return false;

    final message = _messages[index];
    if (message.status != MessageStatus.failed) return false;

    // Update status to sending
    _messages[index] = message.copyWith(status: MessageStatus.sending);
    notifyListeners();

    // Retry sending
    if (message.imageUrl != null) {
      return await sendImageMessage(message.imageUrl!);
    } else {
      return await sendMessage(message.message);
    }
  }

  /// Refresh messages
  Future<void> refresh() async {
    await loadMessages();
  }

  @override
  void dispose() {
    disconnectWebSocket();
    _chatService.dispose();
    super.dispose();
  }
}
