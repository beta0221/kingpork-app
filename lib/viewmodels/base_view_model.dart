import 'package:flutter/foundation.dart';

/// View state enum
enum ViewState {
  idle,
  loading,
  success,
  error,
}

/// Base ViewModel class for all ViewModels
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get isIdle => _state == ViewState.idle;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;

  /// Set state to loading
  void setLoading() {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set state to success
  void setSuccess() {
    _state = ViewState.success;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set state to error with message
  void setError(String message) {
    _state = ViewState.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Set state to idle
  void setIdle() {
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Handle errors with optional custom handler
  Future<T?> handleError<T>(
    Future<T> Function() action, {
    String? errorMessage,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await action();
    } catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        setError(errorMessage ?? e.toString());
      }
      return null;
    }
  }
}
