import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';
import 'package:tklab_ec_v2/utils/token_manager.dart';

/// HTTP Client for API requests
/// Supports both session-based (Cookie) and token-based authentication
class ApiClient {
  late final Dio _dio;
  final TokenManager _tokenManager;
  static CookieJar? _cookieJar;

  ApiClient({
    Dio? dio,
    TokenManager? tokenManager,
    Duration timeout = const Duration(seconds: 30),
  }) : _tokenManager = tokenManager ?? TokenManager() {
    _dio = dio ?? Dio();
    _initializeDio(timeout);
  }

  /// Initialize Dio with interceptors and cookie management
  Future<void> _initializeDio(Duration timeout) async {
    // Setup cookie jar for session management
    if (_cookieJar == null) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final cookiePath = '${appDocDir.path}/.cookies';
        _cookieJar = PersistCookieJar(
          storage: FileStorage(cookiePath),
        );
      } catch (e) {
        // Fallback to default cookie jar if file storage fails
        _cookieJar = CookieJar();
      }
    }

    _dio.interceptors.add(CookieManager(_cookieJar!));

    _dio.options = BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Don't throw on any status code, we'll handle it
        return status != null && status < 500;
      },
    );
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return _request(
      'GET',
      endpoint,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return _request(
      'POST',
      endpoint,
      data: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return _request(
      'PUT',
      endpoint,
      data: body,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return _request(
      'DELETE',
      endpoint,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  /// Generic request handler
  Future<dynamic> _request(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final url = ApiEndpoints.buildUrl(endpoint);
    final requestHeaders = await _buildHeaders(headers, requiresAuth);

    try {
      final options = Options(
        method: method,
        headers: requestHeaders,
      );

      final Response response;
      switch (method) {
        case 'GET':
          response = await _dio.get(url, options: options);
          break;
        case 'POST':
          response = await _dio.post(url, data: data, options: options);
          break;
        case 'PUT':
          response = await _dio.put(url, data: data, options: options);
          break;
        case 'DELETE':
          response = await _dio.delete(url, options: options);
          break;
        default:
          throw ApiException('不支援的 HTTP 方法: $method');
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw TimeoutException('請求超時，請稍後再試');
      } else if (e.error is SocketException) {
        throw NetworkException();
      } else if (e.response != null) {
        return _handleResponse(e.response!);
      } else {
        throw ApiException('網路請求錯誤: ${e.message}');
      }
    } catch (e) {
      throw ApiException('發生未知錯誤: $e');
    }
  }

  /// Build request headers
  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? customHeaders,
    bool requiresAuth,
  ) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add custom headers
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    // For session-based auth, we rely on cookies
    // Only add Bearer token if specifically needed for token-based endpoints
    // Member auth endpoints use session cookies, so we don't need Bearer token
    if (requiresAuth) {
      final token = await _tokenManager.getAccessToken();
      // Only throw if it's a token-based API (not session-based)
      // For now, we'll check if token exists to determine if user is logged in
      if (token == null) {
        throw UnauthorizedException('未找到登入憑證');
      }
      // For session-based APIs (member auth), don't add Authorization header
      // The cookie will be automatically included by CookieManager
    }

    return headers;
  }

  /// Handle API response
  dynamic _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 500;
    final responseBody = response.data;

    // Success responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    }

    // Error responses
    final errorMessage = _extractErrorMessage(responseBody);

    switch (statusCode) {
      case 400:
        throw ApiException(errorMessage, statusCode: 400);
      case 401:
        // Clear token on unauthorized
        _tokenManager.clearTokens();
        throw UnauthorizedException(errorMessage);
      case 403:
        throw ForbiddenException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      case 422:
        final errors = _extractValidationErrors(responseBody);
        throw ValidationException(errorMessage, errors: errors);
      case 500:
      case 502:
      case 503:
        throw ServerException(errorMessage);
      default:
        throw ApiException(
          errorMessage,
          statusCode: statusCode,
        );
    }
  }

  /// Extract error message from response
  String _extractErrorMessage(dynamic responseBody) {
    if (responseBody is Map) {
      // Try 'msg' field first (member API format)
      if (responseBody.containsKey('msg')) {
        return responseBody['msg'] as String? ?? '發生未知錯誤';
      }
      // Fallback to 'message' field
      return responseBody['message'] as String? ?? '發生未知錯誤';
    }
    return '發生未知錯誤';
  }

  /// Extract validation errors from 422 response
  Map<String, List<String>>? _extractValidationErrors(dynamic responseBody) {
    if (responseBody is Map && responseBody.containsKey('errors')) {
      final errorsData = responseBody['errors'];
      if (errorsData is Map) {
        final errors = <String, List<String>>{};
        errorsData.forEach((key, value) {
          if (value is List) {
            errors[key.toString()] = value.map((e) => e.toString()).toList();
          }
        });
        return errors;
      }
    }
    return null;
  }

  /// Clear all cookies (useful for logout)
  Future<void> clearCookies() async {
    if (_cookieJar != null) {
      await _cookieJar!.deleteAll();
    }
  }

  /// Dispose the client
  void dispose() {
    _dio.close();
  }
}
