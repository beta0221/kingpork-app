import 'dart:async';
import 'package:tklab_ec_v2/models/chat_models.dart';
import 'package:tklab_ec_v2/services/chat_service.dart';
import 'package:tklab_ec_v2/services/chat_token_service.dart';
import 'package:tklab_ec_v2/services/chat_polling_service.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// ChatViewModel 管理聊天訊息和 Long Polling 連接
class ChatViewModel extends BaseViewModel {
  final ChatService _chatService;
  final ChatTokenService _tokenService;
  final ChatPollingService _pollingService;

  List<ChatMessage> _messages = [];
  bool _isConnected = false;
  bool _isTyping = false;
  ChatConnectionState _connectionState = ChatConnectionState.disconnected;

  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<ChatConnectionState>? _connectionStateSubscription;
  StreamSubscription<String>? _errorSubscription;

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;
  bool get isTyping => _isTyping;
  int get messageCount => _messages.length;
  ChatConnectionState get connectionState => _connectionState;

  ChatViewModel({
    ChatService? chatService,
    ChatTokenService? tokenService,
    ChatPollingService? pollingService,
  })  : _chatService = chatService ?? ChatService(),
        _tokenService = tokenService ?? ChatTokenService(),
        _pollingService = pollingService ?? ChatPollingService();

  /// 初始化聊天 - 獲取 token 並啟動 Long Polling
  Future<void> initialize() async {
    // 如果已經在監聽，不需要重新初始化
    if (_pollingService.isListening) {
      return;
    }

    setLoading();
    try {
      // 1. 獲取聊天專用 token（顯示 loading）
      await _tokenService.ensureValidToken();

      // 2. 設定訊息監聽
      _setupMessageListener();

      // Token 獲取成功後立即結束 loading
      _isConnected = true;
      setSuccess();

      // 3. 啟動 Long Polling（背景執行，不阻塞 UI）
      _pollingService.startListening(initialTs: 0);
    } catch (e) {
      setError('初始化聊天失敗: ${e.toString()}');
    }
  }

  /// 設定訊息監聽
  void _setupMessageListener() {
    // 先取消舊的訂閱，避免累積多個 listener
    _messageSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _errorSubscription?.cancel();

    // 監聽新訊息
    _messageSubscription = _pollingService.messageStream.listen((message) {
      _addMessage(message);
    });

    // 監聽連接狀態變化（只在狀態實際改變時才通知）
    _connectionStateSubscription = _pollingService.connectionStateStream.listen((state) {
      if (_connectionState != state) {
        _connectionState = state;
        _isConnected = state == ChatConnectionState.connected;
        notifyListeners();
      }
    });

    // 監聽錯誤
    _errorSubscription = _pollingService.errorStream.listen((error) {
      // 可選擇是否要顯示錯誤給用戶
      // setError(error);
    });
  }

  /// 新增訊息到列表（避免重複）
  void _addMessage(ChatMessage message) {
    // 檢查是否為重複訊息
    // 1. 先用 id 精確比對
    // 2. 再用內容 + 發送者 + 時間範圍比對（處理客戶端/服務器時間戳不一致）
    final isDuplicate = _messages.any((m) {
      // 精確 id 比對
      if (m.id == message.id) return true;

      // 內容比對：相同發送者 + 相同內容 + 時間接近（10秒內）
      if (m.isFromUser == message.isFromUser && m.message == message.message) {
        final timeDiff = (m.id - message.id).abs();
        if (timeDiff < 10000) {
          // 10 秒 = 10000 毫秒
          return true;
        }
      }
      return false;
    });

    if (!isDuplicate) {
      _messages.add(message);
      // 按時間排序
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
    }
  }

  /// 載入歷史訊息（透過 REST API）
  Future<void> loadMessages() async {
    try {
      _messages = await _chatService.getMessages();
      notifyListeners();
    } catch (e) {
      setError('載入訊息失敗: ${e.toString()}');
    }
  }

  /// 發送文字訊息
  Future<bool> sendMessage(String message) async {
    if (message.trim().isEmpty) return false;

    try {
      // 建立暫存訊息（發送中狀態）
      final tempMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        message: message,
        isFromUser: true,
        createdAt: DateTime.now().toIso8601String(),
        status: MessageStatus.sending,
      );

      _messages.add(tempMessage);
      notifyListeners();

      // 透過 API 發送訊息
      final response = await _chatService.sendMessage(message);

      // 根據回應更新訊息狀態
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        if (response.isSuccess) {
          _messages[index] = tempMessage.copyWith(status: MessageStatus.sent);
        } else {
          _messages[index] = tempMessage.copyWith(status: MessageStatus.failed);
          setError(response.m ?? '發送訊息失敗');
        }
        notifyListeners();
      }

      return response.isSuccess;
    } catch (e) {
      setError('發送訊息失敗: ${e.toString()}');
      return false;
    }
  }

  /// 發送圖片訊息
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

      final response = await _chatService.sendImageMessage(imageUrl);

      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        if (response.isSuccess) {
          _messages[index] = tempMessage.copyWith(status: MessageStatus.sent);
        } else {
          _messages[index] = tempMessage.copyWith(status: MessageStatus.failed);
        }
        notifyListeners();
      }

      return response.isSuccess;
    } catch (e) {
      setError('發送圖片失敗: ${e.toString()}');
      return false;
    }
  }

  /// 處理接收到的訊息（手動新增）
  void onMessageReceived(ChatMessage message) {
    _addMessage(message);
  }

  /// 設定正在輸入狀態
  void setTyping(bool typing) {
    if (_isTyping != typing) {
      _isTyping = typing;
      notifyListeners();
    }
  }

  /// 開始連接（啟動 Long Polling）
  Future<void> connect() async {
    if (_pollingService.isListening) return;

    try {
      await _tokenService.ensureValidToken();
      _setupMessageListener();
      await _pollingService.startListening(initialTs: _pollingService.lastTs);
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      setError('連接失敗: ${e.toString()}');
    }
  }

  /// 斷開連接（停止 Long Polling）
  void disconnect() {
    _messageSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _errorSubscription?.cancel();
    _pollingService.stopListening();
    _isConnected = false;
    notifyListeners();
  }

  /// 重新連接
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect();
  }

  /// 清除所有訊息
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  /// 重試發送失敗的訊息
  Future<bool> retryMessage(int messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return false;

    final message = _messages[index];
    if (message.status != MessageStatus.failed) return false;

    // 更新狀態為發送中
    _messages[index] = message.copyWith(status: MessageStatus.sending);
    notifyListeners();

    // 重試發送
    if (message.imageUrl != null) {
      return await sendImageMessage(message.imageUrl!);
    } else {
      return await sendMessage(message.message);
    }
  }

  /// 刷新訊息
  Future<void> refresh() async {
    // 重置時間戳以獲取所有訊息
    _pollingService.resetTs();
    clearMessages();
    await reconnect();
  }

  @override
  void dispose() {
    disconnect();
    _chatService.dispose();
    _tokenService.dispose();
    _pollingService.dispose();
    super.dispose();
  }
}
