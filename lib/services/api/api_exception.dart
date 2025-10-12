/// Custom API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when the server returns a 401 Unauthorized response
class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = '未授權，請重新登入'])
      : super(message, statusCode: 401);
}

/// Thrown when the server returns a 403 Forbidden response
class ForbiddenException extends ApiException {
  ForbiddenException([String message = '無權限存取此資源'])
      : super(message, statusCode: 403);
}

/// Thrown when the server returns a 404 Not Found response
class NotFoundException extends ApiException {
  NotFoundException([String message = '找不到資源'])
      : super(message, statusCode: 404);
}

/// Thrown when the server returns a 422 Validation Error response
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException(
    String message, {
    this.errors,
  }) : super(message, statusCode: 422);

  /// Get the first error message for a specific field
  String? getFieldError(String field) {
    return errors?[field]?.first;
  }

  /// Get all error messages as a flat list
  List<String> getAllErrors() {
    if (errors == null) return [message];
    return errors!.values.expand((e) => e).toList();
  }
}

/// Thrown when the server returns a 500 Internal Server Error response
class ServerException extends ApiException {
  ServerException([String message = '伺服器錯誤，請稍後再試'])
      : super(message, statusCode: 500);
}

/// Thrown when there is no internet connection
class NetworkException extends ApiException {
  NetworkException([String message = '無網路連線，請檢查網路設定'])
      : super(message);
}

/// Thrown when the request times out
class TimeoutException extends ApiException {
  TimeoutException([String message = '請求逾時，請稍後再試'])
      : super(message);
}
