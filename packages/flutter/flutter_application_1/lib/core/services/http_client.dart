import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

/// HTTP客户端服务
class HttpClient {
  static HttpClient? _instance;
  static HttpClient get instance => _instance ??= HttpClient._();

  HttpClient._();

  final http.Client _client = http.Client();

  /// GET请求
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _getHeaders(headers))
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// POST请求
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _getHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// PUT请求
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: _getHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// DELETE请求
  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .delete(Uri.parse(url), headers: _getHeaders(headers))
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }

  /// 获取请求头
  Map<String, String> _getHeaders(Map<String, String>? customHeaders) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } else {
      throw Exception('请求失败: ${response.statusCode} - ${response.body}');
    }
  }

  /// 关闭客户端
  void close() {
    _client.close();
  }
}
