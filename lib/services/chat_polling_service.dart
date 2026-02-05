import 'dart:async';
import 'package:dio/dio.dart';
import 'package:tklab_ec_v2/config/flavor_config.dart';
import 'package:tklab_ec_v2/models/chat_models.dart';
import 'package:tklab_ec_v2/services/chat_token_service.dart';

/// 聊天 Long Polling 服務
/// 負責監聽新訊息並透過 Stream 通知
class ChatPollingService {
  final ChatTokenService _tokenService;
  final Dio _dio;

  bool _isListening = false;
  int _lastTs = 0;
  CancelToken? _cancelToken;
  ChatConnectionState _currentState = ChatConnectionState.disconnected;

  // 訊息串流控制器
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _connectionStateController = StreamController<ChatConnectionState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// 訊息串流 - 監聽新訊息
  Stream<ChatMessage> get messageStream => _messageController.stream;

  /// 連接狀態串流
  Stream<ChatConnectionState> get connectionStateStream => _connectionStateController.stream;

  /// 錯誤串流
  Stream<String> get errorStream => _errorController.stream;

  /// 是否正在監聽
  bool get isListening => _isListening;

  /// 目前時間戳
  int get lastTs => _lastTs;

  ChatPollingService({
    ChatTokenService? tokenService,
    Dio? dio,
  })  : _tokenService = tokenService ?? ChatTokenService(),
        _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 60), // Long Polling 需要較長的超時時間
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// 啟動監聽
  /// [initialTs] 初始時間戳，0 表示從頭開始獲取
  Future<void> startListening({int initialTs = 0}) async {
    if (_isListening) return;

    _isListening = true;
    _lastTs = initialTs;
    _updateConnectionState(ChatConnectionState.connecting);

    _pollLoop();
  }

  /// 停止監聯
  void stopListening() {
    _isListening = false;
    _cancelToken?.cancel('停止監聽');
    _cancelToken = null;
    _updateConnectionState(ChatConnectionState.disconnected);
  }

  /// 重新連接
  Future<void> reconnect() async {
    stopListening();
    await Future.delayed(const Duration(seconds: 1));
    await startListening(initialTs: _lastTs);
  }

  /// 重置時間戳（用於重新獲取所有訊息）
  void resetTs() {
    _lastTs = 0;
  }

  /// 輪詢迴圈
  Future<void> _pollLoop() async {
    while (_isListening) {
      try {
        await _poll();
      } catch (e) {
        if (!_isListening) break; // 如果已停止監聽，跳出迴圈

        _errorController.add(e.toString());
        _updateConnectionState(ChatConnectionState.reconnecting);

        // 發生錯誤時等待後重試
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  /// 執行一次 poll 請求
  Future<void> _poll() async {
    // 確保有有效的 token
    final token = await _tokenService.ensureValidToken();

    _cancelToken = CancelToken();

    final listenUrl = FlavorConfig.instance.chatListenEndpoint;

    final response = await _dio.get(
      listenUrl,
      queryParameters: {
        'token': token.accessToken,
        'Ts': _lastTs,
      },
      cancelToken: _cancelToken,
    );

    if (!_isListening) return; // 如果在請求過程中停止，直接返回

    // 第一次成功收到回應後，設置為已連接
    _updateConnectionState(ChatConnectionState.connected);

    final listenResponse = ListenResponse.fromJson(response.data as Map<String, dynamic>);

    // 更新時間戳
    if (listenResponse.nextTs > 0) {
      _lastTs = listenResponse.nextTs;
    }

    // 處理回應
    if (listenResponse.hasNewMessages) {
      _processMessages(listenResponse.data);
    } else if (listenResponse.hasError) {
      // 可能是 token 過期，嘗試刷新
      if (listenResponse.m?.contains('token') == true ||
          listenResponse.m?.contains('授權') == true ||
          listenResponse.m?.contains('過期') == true) {
        await _tokenService.refreshToken();
      } else {
        _errorController.add(listenResponse.m ?? '未知錯誤');
      }
    }
    // s == 0 表示無新訊息，繼續下一輪 poll
  }

  /// 處理接收到的訊息
  void _processMessages(List<dynamic> data) {
    for (final msgData in data) {
      try {
        // 嘗試解析訊息（根據實際 API 回傳格式調整）
        final message = _parseMessage(msgData);
        if (message != null) {
          _messageController.add(message);
        }
      } catch (e) {
        // 單一訊息解析失敗不影響其他訊息
        // 在 debug 模式下可透過 debugPrint 查看
        assert(() {
          // ignore: avoid_print
          print('解析訊息失敗: $e, 資料: $msgData');
          return true;
        }());
      }
    }
  }

  /// 解析單一訊息
  /// 注意：實際欄位需根據後端回傳格式調整
  ChatMessage? _parseMessage(dynamic msgData) {
    if (msgData is! Map<String, dynamic>) return null;

    // 根據 API 文件，Data 陣列的結構需確認
    // 暫時使用靈活的解析方式
    return ChatMessage(
      id: msgData['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      message: msgData['message'] as String? ?? msgData['txt'] as String? ?? msgData['content'] as String? ?? '',
      imageUrl: msgData['image_url'] as String? ?? msgData['imageUrl'] as String?,
      isFromUser: msgData['is_from_user'] as bool? ?? msgData['isFromUser'] as bool? ?? msgData['fromUser'] as bool? ?? false,
      createdAt: msgData['created_at'] as String? ?? msgData['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      status: MessageStatus.sent,
    );
  }

  /// 更新連接狀態（只在狀態改變時才發送通知）
  void _updateConnectionState(ChatConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _connectionStateController.add(newState);
    }
  }

  /// 釋放資源
  void dispose() {
    stopListening();
    _messageController.close();
    _connectionStateController.close();
    _errorController.close();
    _dio.close();
  }
}

/// 連接狀態列舉
enum ChatConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}
