import 'package:tklab_ec_v2/models/member_models.dart';
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';
import 'package:tklab_ec_v2/utils/token_manager.dart';

/// 會員認證服務
///
/// 提供會員系統所有認證相關功能，包括：
/// - 註冊/登入/登出
/// - 驗證碼發送與驗證
/// - 忘記密碼流程
/// - 會員資訊查詢
/// - 帳號刪除
///
/// 認證方式：Session-based Authentication (Laravel Session)
///
/// 重要說明：
/// - 台灣（國碼 886）：使用手機簡訊驗證碼
/// - 其他國家：使用 Email 驗證碼（但仍使用手機號碼作為登入帳號）
/// - 所有 API 回應格式統一為 { s: 0|1, msg: string, data?: object, errors?: object }
class MemberAuthService {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  MemberAuthService({
    ApiClient? apiClient,
    TokenManager? tokenManager,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenManager = tokenManager ?? TokenManager();

  /// 1. 發送驗證碼
  ///
  /// 根據國碼發送簡訊驗證碼（台灣）或 Email 驗證碼（其他國家）
  ///
  /// 參數：
  /// - [countryCode]: 手機國碼（1-4位數字），例如：886（台灣）、1（美國）
  /// - [mobile]: 手機號碼（10-15位數字）
  /// - [email]: Email 地址（僅非台灣國家需要）
  ///
  /// 範例：
  /// ```dart
  /// // 台灣用戶
  /// final response = await memberAuthService.sendVerificationCode(
  ///   countryCode: '886',
  ///   mobile: '0912345678',
  /// );
  ///
  /// // 其他國家用戶
  /// final response = await memberAuthService.sendVerificationCode(
  ///   countryCode: '1',
  ///   mobile: '5551234567',
  ///   email: 'user@example.com',
  /// );
  /// ```
  ///
  /// 拋出異常：
  /// - [ValidationException]: 參數格式錯誤
  /// - [ApiException]: 發送失敗或頻率限制
  Future<SendVerificationCodeResponse> sendVerificationCode({
    required String countryCode,
    required String mobile,
    String? email,
  }) async {
    final request = SendVerificationCodeRequest(
      countryCode: countryCode,
      mobile: mobile,
      email: email,
    );

    final response = await _apiClient.post(
      ApiEndpoints.memberSendVerificationCode,
      body: request.toJson(),
    );

    return SendVerificationCodeResponse.fromJson(response);
  }

  /// 2. 會員註冊
  ///
  /// 註冊新會員帳號
  ///
  /// 參數：
  /// - [countryCode]: 手機國碼（1-4位數字）
  /// - [mobile]: 手機號碼（10-15位數字）
  /// - [password]: 密碼（6-50個字元）
  /// - [verificationCode]: 驗證碼（6位數字）
  /// - [name]: 會員姓名（最多100字元，可選）
  /// - [email]: Email 地址（僅非台灣國家需要）
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.register(
  ///   countryCode: '886',
  ///   mobile: '0912345678',
  ///   password: 'password123',
  ///   verificationCode: '123456',
  ///   name: '張三',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('註冊成功！會員ID: ${response.data?.memberId}');
  /// }
  /// ```
  ///
  /// 拋出異常：
  /// - [ValidationException]: 參數格式錯誤或驗證碼錯誤
  /// - [ApiException]: 手機號碼已被註冊（HTTP 409）
  Future<RegisterResponse> register({
    required String countryCode,
    required String mobile,
    required String password,
    required String verificationCode,
    String? name,
    String? email,
  }) async {
    final request = RegisterRequest(
      countryCode: countryCode,
      mobile: mobile,
      password: password,
      verificationCode: verificationCode,
      name: name,
      email: email,
    );

    final response = await _apiClient.post(
      ApiEndpoints.memberRegister,
      body: request.toJson(),
    );

    return RegisterResponse.fromJson(response);
  }

  /// 3. 會員登入
  ///
  /// 會員登入，建立 Session
  ///
  /// 參數：
  /// - [countryCode]: 手機國碼（1-4位數字）
  /// - [mobile]: 手機號碼
  /// - [password]: 密碼
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.login(
  ///   countryCode: '886',
  ///   mobile: '0912345678',
  ///   password: 'password123',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('登入成功！歡迎 ${response.member?.name}');
  /// }
  /// ```
  ///
  /// 特殊說明：
  /// - 登入成功後會自動更新 last_login_time 和 last_login_at
  /// - 黑名單會員（status=8）無法登入
  /// - 登入成功後會建立 Session，後續請求需攜帶 Session Cookie
  ///
  /// 拋出異常：
  /// - [UnauthorizedException]: 帳號或密碼錯誤（HTTP 401）
  /// - [ForbiddenException]: 黑名單會員（HTTP 403）
  Future<LoginResponse> login({
    required String countryCode,
    required String mobile,
    required String password,
  }) async {
    final request = LoginRequest(
      countryCode: countryCode,
      mobile: mobile,
      password: password,
    );

    final response = await _apiClient.post(
      ApiEndpoints.memberLogin,
      body: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response);

    // 如果登入成功，保存會員資訊到本地（可選）
    if (loginResponse.isSuccess && loginResponse.member != null) {
      // 這裡可以保存會員 ID 或其他必要資訊
      // 例如：await _tokenManager.saveAccessToken(loginResponse.member!.memberId.toString());
    }

    return loginResponse;
  }

  /// 4. 會員登出
  ///
  /// 登出會員，清除 Session
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.logout();
  /// if (response.isSuccess) {
  ///   print('登出成功');
  /// }
  /// ```
  ///
  /// 特殊說明：
  /// - 登出後會使 Session 無效並重新生成 CSRF token
  ///
  /// 拋出異常：
  /// - [UnauthorizedException]: 未登入（HTTP 401）
  Future<LogoutResponse> logout() async {
    final response = await _apiClient.post(
      ApiEndpoints.memberLogout,
      requiresAuth: true,
    );

    // 清除本地儲存的會員資訊
    await _tokenManager.clearTokens();

    return LogoutResponse.fromJson(response);
  }

  /// 5. 取得當前會員資訊
  ///
  /// 取得當前登入會員的詳細資訊
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.getCurrentMember();
  /// if (response.isSuccess) {
  ///   final member = response.member!;
  ///   print('會員姓名: ${member.name}');
  ///   print('會員等級: ${MemberLevel.fromValue(member.memberLevel).displayName}');
  /// }
  /// ```
  ///
  /// 特殊說明：
  /// - 會從資料庫取得最新會員資料（非 Session 快取）
  ///
  /// 拋出異常：
  /// - [UnauthorizedException]: 未登入（HTTP 401）
  Future<MemberInfoResponse> getCurrentMember() async {
    final response = await _apiClient.get(
      ApiEndpoints.memberMe,
      requiresAuth: true,
    );

    return MemberInfoResponse.fromJson(response);
  }

  /// 6. 刪除帳號
  ///
  /// 刪除會員帳號（軟刪除，標記 status=16）
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.deleteAccount();
  /// if (response.isSuccess) {
  ///   print('帳號已刪除');
  /// }
  /// ```
  ///
  /// 特殊說明：
  /// - 會刪除 member_auth 表中的驗證資料
  /// - 會將 members 表中的 status 設為 16（會員發動刪除）
  /// - 刪除成功後會自動登出
  ///
  /// 拋出異常：
  /// - [UnauthorizedException]: 未登入（HTTP 401）
  Future<DeleteAccountResponse> deleteAccount() async {
    final response = await _apiClient.post(
      ApiEndpoints.memberDeleteAccount,
      requiresAuth: true,
    );

    // 清除本地儲存的會員資訊
    await _tokenManager.clearTokens();

    return DeleteAccountResponse.fromJson(response);
  }

  /// 7. 忘記密碼 - 發送驗證碼
  ///
  /// 發送密碼重設驗證碼
  ///
  /// 參數：
  /// - [countryCode]: 手機國碼（1-4位數字）
  /// - [mobile]: 手機號碼（10-15位數字）
  /// - [email]: Email 地址（僅非台灣國家需要）
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.sendPasswordResetCode(
  ///   countryCode: '886',
  ///   mobile: '0912345678',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('驗證碼已發送');
  /// }
  /// ```
  ///
  /// 特殊說明：
  /// - 會檢查會員狀態（已刪除、黑名單無法重設）
  /// - 非台灣國家需驗證 Email 是否與帳號設定相符
  ///
  /// 拋出異常：
  /// - [NotFoundException]: 手機號碼尚未註冊（HTTP 404）
  /// - [ForbiddenException]: 黑名單或已刪除帳號（HTTP 403）
  Future<SendPasswordResetCodeResponse> sendPasswordResetCode({
    required String countryCode,
    required String mobile,
    String? email,
  }) async {
    final request = SendPasswordResetCodeRequest(
      countryCode: countryCode,
      mobile: mobile,
      email: email,
    );

    final response = await _apiClient.post(
      ApiEndpoints.memberPasswordSendResetCode,
      body: request.toJson(),
    );

    return SendPasswordResetCodeResponse.fromJson(response);
  }

  /// 8. 忘記密碼 - 驗證驗證碼
  ///
  /// 驗證驗證碼並產生重設密碼 Token
  ///
  /// 參數：
  /// - [countryCode]: 手機國碼（1-4位數字）
  /// - [mobile]: 手機號碼（10-15位數字）
  /// - [verificationCode]: 驗證碼（6位數字）
  /// - [email]: Email 地址（僅非台灣國家需要）
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.verifyPasswordResetCode(
  ///   countryCode: '886',
  ///   mobile: '0912345678',
  ///   verificationCode: '123456',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   final resetToken = response.resetToken!;
  ///   print('驗證成功，Token 有效期: ${response.expiresIn} 秒');
  ///   // 使用 resetToken 進行密碼重設
  /// }
  /// ```
  ///
  /// 特殊說明：
  /// - Token 有效期：15分鐘（900秒）
  /// - Token 為一次性使用
  /// - 驗證失敗會記錄到 password_reset_logs 表
  ///
  /// 拋出異常：
  /// - [ApiException]: 驗證碼錯誤或已過期（HTTP 400）
  Future<VerifyPasswordResetCodeResponse> verifyPasswordResetCode({
    required String countryCode,
    required String mobile,
    required String verificationCode,
    String? email,
  }) async {
    final request = VerifyPasswordResetCodeRequest(
      countryCode: countryCode,
      mobile: mobile,
      verificationCode: verificationCode,
      email: email,
    );

    final response = await _apiClient.post(
      ApiEndpoints.memberPasswordVerifyResetCode,
      body: request.toJson(),
    );

    return VerifyPasswordResetCodeResponse.fromJson(response);
  }

  /// 9. 忘記密碼 - 重設密碼
  ///
  /// 使用 Token 重設密碼
  ///
  /// 參數：
  /// - [resetToken]: 重設密碼 Token（從 verifyPasswordResetCode 取得）
  /// - [password]: 新密碼（6-50個字元）
  /// - [passwordConfirmation]: 確認密碼（需與 password 一致）
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.resetPassword(
  ///   resetToken: 'token-from-verify-step',
  ///   password: 'newPassword123',
  ///   passwordConfirmation: 'newPassword123',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('密碼已更新，請使用新密碼登入');
  /// }
  /// ```
  ///
  /// 特殊說明：
  /// - 每日重設密碼次數限制：3次（以手機號碼計算）
  /// - 超過限制會返回 HTTP 429
  /// - 重設成功會記錄到 password_reset_logs 表
  /// - **重設成功後不會自動登入**，需手動登入
  ///
  /// 拋出異常：
  /// - [ApiException]: Token 無效或已過期（HTTP 400/403）
  /// - [ValidationException]: 密碼格式錯誤或不一致（HTTP 422）
  /// - [ApiException]: 超過每日重設次數限制（HTTP 429）
  Future<ResetPasswordResponse> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    final request = ResetPasswordRequest(
      resetToken: resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    final response = await _apiClient.post(
      ApiEndpoints.memberPasswordReset,
      body: request.toJson(),
    );

    return ResetPasswordResponse.fromJson(response);
  }

  /// 10. 解密手機號碼（除錯用）
  ///
  /// 解密加密後的手機號碼字串（僅開發環境）
  ///
  /// 參數：
  /// - [encryptedText]: 加密後的手機號碼字串
  ///
  /// 範例：
  /// ```dart
  /// final response = await memberAuthService.decryptMobile(
  ///   encryptedText: 'encrypted-string',
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print('解密結果: ${response.decrypted}');
  /// }
  /// ```
  ///
  /// 特殊說明：
  /// - 僅在 APP_DEBUG=true 時可用
  /// - 生產環境會返回 403 Forbidden
  ///
  /// 拋出異常：
  /// - [ForbiddenException]: 非除錯環境（HTTP 403）
  Future<DecryptMobileResponse> decryptMobile({
    required String encryptedText,
  }) async {
    final request = DecryptMobileRequest(encryptedText: encryptedText);

    final response = await _apiClient.post(
      ApiEndpoints.memberDebugDecryptMobile,
      body: request.toJson(),
    );

    return DecryptMobileResponse.fromJson(response);
  }

  /// 完整的忘記密碼流程輔助方法
  ///
  /// 這個方法整合了忘記密碼的三個步驟，簡化調用流程
  ///
  /// 參數：
  /// - [countryCode]: 手機國碼
  /// - [mobile]: 手機號碼
  /// - [email]: Email（非台灣國家需要）
  /// - [onCodeSent]: 驗證碼發送成功的回調，用於獲取用戶輸入的驗證碼
  /// - [onTokenReceived]: Token 接收成功的回調，用於獲取用戶輸入的新密碼
  ///
  /// 範例：
  /// ```dart
  /// await memberAuthService.forgotPasswordFlow(
  ///   countryCode: '886',
  ///   mobile: '0912345678',
  ///   onCodeSent: () async {
  ///     // 提示用戶輸入驗證碼
  ///     return await getUserInputCode();
  ///   },
  ///   onTokenReceived: (token) async {
  ///     // 提示用戶輸入新密碼
  ///     final password = await getUserInputPassword();
  ///     return {'password': password, 'confirmation': password};
  ///   },
  /// );
  /// ```
  Future<ResetPasswordResponse> forgotPasswordFlow({
    required String countryCode,
    required String mobile,
    String? email,
    required Future<String> Function() onCodeSent,
    required Future<Map<String, String>> Function(String token) onTokenReceived,
  }) async {
    // 步驟 1: 發送驗證碼
    await sendPasswordResetCode(
      countryCode: countryCode,
      mobile: mobile,
      email: email,
    );

    // 獲取用戶輸入的驗證碼
    final verificationCode = await onCodeSent();

    // 步驟 2: 驗證驗證碼並取得 Token
    final verifyResponse = await verifyPasswordResetCode(
      countryCode: countryCode,
      mobile: mobile,
      verificationCode: verificationCode,
      email: email,
    );

    if (!verifyResponse.isSuccess || verifyResponse.resetToken == null) {
      throw Exception('驗證碼驗證失敗');
    }

    // 獲取用戶輸入的新密碼
    final passwordData = await onTokenReceived(verifyResponse.resetToken!);
    final password = passwordData['password']!;
    final confirmation = passwordData['confirmation']!;

    // 步驟 3: 重設密碼
    return await resetPassword(
      resetToken: verifyResponse.resetToken!,
      password: password,
      passwordConfirmation: confirmation,
    );
  }

  /// 清理資源
  void dispose() {
    _apiClient.dispose();
  }
}
