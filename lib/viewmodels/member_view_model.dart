import 'package:tklab_ec_v2/models/auth_models.dart';
import 'package:tklab_ec_v2/services/auth_service.dart';
import 'package:tklab_ec_v2/utils/token_manager.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';

/// MemberViewModel manages user authentication and profile data
class MemberViewModel extends BaseViewModel {
  final AuthService _authService;
  final TokenManager _tokenManager;

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get userName => _currentUser?.name;
  String? get userEmail => _currentUser?.email;

  MemberViewModel({
    AuthService? authService,
    TokenManager? tokenManager,
  })  : _authService = authService ?? AuthService(),
        _tokenManager = tokenManager ?? TokenManager();

  /// Initialize member data - check if user is logged in
  Future<void> initialize() async {
    setLoading();
    try {
      final loggedIn = await _tokenManager.isLoggedIn();
      if (loggedIn) {
        await loadUserProfile();
      } else {
        _currentUser = null;
        setSuccess();
      }
    } catch (e) {
      setError('初始化失敗: ${e.toString()}');
    }
  }

  /// Load user profile from API
  Future<void> loadUserProfile() async {
    try {
      _currentUser = await _authService.getUser();
      setSuccess();
    } catch (e) {
      // Token might be invalid
      await logout();
      setError('載入用戶資料失敗: ${e.toString()}');
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    setLoading();
    try {
      final response = await _authService.login(email, password);
      _currentUser = response.user;
      setSuccess();
      return true;
    } catch (e) {
      setError('登入失敗: ${e.toString()}');
      return false;
    }
  }

  /// Signup with user information
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    setLoading();
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _currentUser = response.user;
      setSuccess();
      return true;
    } catch (e) {
      setError('註冊失敗: ${e.toString()}');
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Ignore logout errors, just clear local data
    } finally {
      _currentUser = null;
      await _tokenManager.clearTokens();
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    setLoading();
    try {
      // Call API to update profile
      // For now, just update locally
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          name: name ?? _currentUser!.name,
          email: email ?? _currentUser!.email,
        );
        notifyListeners();
      }
      setSuccess();
      return true;
    } catch (e) {
      setError('更新資料失敗: ${e.toString()}');
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

  /// Refresh user data
  Future<void> refresh() async {
    await loadUserProfile();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
