import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shop/services/api/api_endpoints.dart';
import 'package:shop/services/api/api_exception.dart';
import 'package:shop/utils/token_manager.dart';

/// HTTP Client for API requests
class ApiClient {
  final http.Client _client;
  final TokenManager _tokenManager;
  final Duration timeout;

  ApiClient({
    http.Client? client,
    TokenManager? tokenManager,
    this.timeout = const Duration(seconds: 30),
  })  : _client = client ?? http.Client(),
        _tokenManager = tokenManager ?? TokenManager();

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
      body: body,
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
      body: body,
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
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse(ApiEndpoints.buildUrl(endpoint));
    final requestHeaders = await _buildHeaders(headers, requiresAuth);

    try {
      http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(url, headers: requestHeaders)
              .timeout(timeout);
          break;
        case 'POST':
          response = await _client
              .post(
                url,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                url,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(url, headers: requestHeaders)
              .timeout(timeout);
          break;
        default:
          throw ApiException('不支援的 HTTP 方法: $method');
      }

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } on http.ClientException catch (e) {
      throw ApiException('網路請求錯誤: ${e.message}');
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

    // Add authorization header if required
    if (requiresAuth) {
      final token = await _tokenManager.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw UnauthorizedException('未找到登入憑證');
      }
    }

    return headers;
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Try to decode response body
    dynamic responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      responseBody = response.body;
    }

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

  /// Dispose the client
  void dispose() {
    _client.close();
  }
}
