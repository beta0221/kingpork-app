import 'package:tklab_ec_v2/models/member_models.dart';
import 'package:tklab_ec_v2/services/member_auth_service.dart';
import 'package:tklab_ec_v2/utils/token_manager.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// MemberViewModel manages user authentication and profile data
class MemberViewModel extends BaseViewModel {
  final MemberAuthService _memberAuthService;
  final TokenManager _tokenManager;

  Member? _currentMember;

  Member? get currentMember => _currentMember;
  bool get isLoggedIn => _currentMember != null;
  String? get memberName => _currentMember?.name;
  String? get memberMobile => _currentMember?.mobile;
  int? get memberId => _currentMember?.memberId;

  MemberViewModel({
    MemberAuthService? memberAuthService,
    TokenManager? tokenManager,
  })  : _memberAuthService = memberAuthService ?? MemberAuthService(),
        _tokenManager = tokenManager ?? TokenManager();

  /// Initialize member data - check if user is logged in
  Future<void> initialize() async {
    setLoading();
    try {
      final loggedIn = await _tokenManager.isLoggedIn();
      if (loggedIn) {
        await loadMemberProfile();
      } else {
        _currentMember = null;
        setSuccess();
      }
    } catch (e) {
      setError('初始化失敗: ${e.toString()}');
    }
  }

  /// Load member profile from API
  Future<void> loadMemberProfile() async {
    try {
      final response = await _memberAuthService.getCurrentMember();
      if (response.isSuccess && response.member != null) {
        _currentMember = response.member;
        setSuccess();
      } else {
        throw Exception(response.msg ?? '載入會員資料失敗');
      }
    } catch (e) {
      // Token might be invalid
      await logout();
      setError('載入會員資料失敗: ${e.toString()}');
    }
  }

  /// Send verification code for registration
  Future<bool> sendVerificationCode({
    required String countryCode,
    required String mobile,
  }) async {
    try {
      final response = await _memberAuthService.sendVerificationCode(
        countryCode: countryCode,
        mobile: mobile,
      );

      if (response.isSuccess) {
        return true;
      } else {
        setError(response.msg);
        return false;
      }
    } catch (e) {
      setError('發送驗證碼失敗: ${e.toString()}');
      return false;
    }
  }

  /// Login with country code, mobile and password
  Future<bool> login({
    required String countryCode,
    required String mobile,
    required String password,
  }) async {
    setLoading();
    try {
      final response = await _memberAuthService.login(
        countryCode: countryCode,
        mobile: mobile,
        password: password,
      );

      if (response.isSuccess && response.member != null) {
        _currentMember = response.member;
        setSuccess();
        return true;
      } else {
        setError(response.msg);
        return false;
      }
    } catch (e) {
      setError('登入失敗: ${e.toString()}');
      return false;
    }
  }

  /// Register with member information
  Future<bool> register({
    required String countryCode,
    required String mobile,
    required String verificationCode,
    required String password,
    String? name,
  }) async {
    setLoading();
    try {
      final response = await _memberAuthService.register(
        countryCode: countryCode,
        mobile: mobile,
        password: password,
        verificationCode: verificationCode,
        name: name,
      );

      if (response.isSuccess && response.data != null) {
        setSuccess();
        return true;
      } else {
        setError(response.msg);
        return false;
      }
    } catch (e) {
      setError('註冊失敗: ${e.toString()}');
      return false;
    }
  }

  /// Logout current member
  Future<void> logout() async {
    try {
      await _memberAuthService.logout();
    } catch (e) {
      // Ignore logout errors, just clear local data
    } finally {
      _currentMember = null;
      await _tokenManager.clearTokens();
      notifyListeners();
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    setLoading();
    try {
      final response = await _memberAuthService.deleteAccount();

      if (response.isSuccess) {
        _currentMember = null;
        await _tokenManager.clearTokens();
        setSuccess();
        return true;
      } else {
        setError(response.msg);
        return false;
      }
    } catch (e) {
      setError('刪除帳號失敗: ${e.toString()}');
      return false;
    }
  }

  /// Send password reset code
  Future<bool> sendPasswordResetCode({
    required String countryCode,
    required String mobile,
  }) async {
    setLoading();
    try {
      final response = await _memberAuthService.sendPasswordResetCode(
        countryCode: countryCode,
        mobile: mobile,
      );

      if (response.isSuccess) {
        setSuccess();
        return true;
      } else {
        setError(response.msg);
        return false;
      }
    } catch (e) {
      setError('發送密碼重設驗證碼失敗: ${e.toString()}');
      return false;
    }
  }

  /// Verify password reset code
  Future<String?> verifyPasswordResetCode({
    required String countryCode,
    required String mobile,
    required String verificationCode,
  }) async {
    setLoading();
    try {
      final response = await _memberAuthService.verifyPasswordResetCode(
        countryCode: countryCode,
        mobile: mobile,
        verificationCode: verificationCode,
      );

      if (response.isSuccess && response.resetToken != null) {
        setSuccess();
        return response.resetToken;
      } else {
        setError(response.msg);
        return null;
      }
    } catch (e) {
      setError('驗證碼驗證失敗: ${e.toString()}');
      return null;
    }
  }

  /// Reset password
  Future<bool> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    setLoading();
    try {
      final response = await _memberAuthService.resetPassword(
        resetToken: resetToken,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.isSuccess) {
        setSuccess();
        return true;
      } else {
        setError(response.msg);
        return false;
      }
    } catch (e) {
      setError('重設密碼失敗: ${e.toString()}');
      return false;
    }
  }

  /// Check if token is still valid
  Future<bool> checkTokenValidity() async {
    try {
      return await _tokenManager.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  /// Refresh member data
  Future<void> refresh() async {
    await loadMemberProfile();
  }

  @override
  void dispose() {
    _memberAuthService.dispose();
    super.dispose();
  }
}
