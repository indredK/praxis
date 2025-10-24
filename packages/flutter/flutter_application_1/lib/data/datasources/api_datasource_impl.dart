import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/product.dart';
import '../../core/constants/app_constants.dart';
import 'api_datasource.dart';

/// API数据源实现
class ApiDataSourceImpl implements ApiDataSource {
  final http.Client _client = http.Client();

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/products'),
            headers: _getHeaders(),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('获取产品列表失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/products?category=$category'),
            headers: _getHeaders(),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('获取产品列表失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCompany(String company) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/products?company=$company'),
            headers: _getHeaders(),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('获取产品列表失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/products/$id'),
            headers: _getHeaders(),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw ApiException('获取产品详情失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/products/search?q=$query'),
            headers: _getHeaders(),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('搜索产品失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  @override
  Future<List<SpecComparison>> getProductComparison(
    List<String> productIds,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConstants.apiBaseUrl}/products/compare'),
            headers: _getHeaders(),
            body: json.encode({'productIds': productIds}),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SpecComparison.fromJson(json)).toList();
      } else {
        throw ApiException('获取产品对比失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  @override
  Future<ChartData> getChartData(
    String chartType,
    List<String> productIds,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConstants.apiBaseUrl}/charts/$chartType'),
            headers: _getHeaders(),
            body: json.encode({'productIds': productIds}),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ChartData.fromJson(data);
      } else {
        throw ApiException('获取图表数据失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/categories'),
            headers: _getHeaders(),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      } else {
        throw ApiException('获取类别列表失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  @override
  Future<List<String>> getAllCompanies() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/companies'),
            headers: _getHeaders(),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      } else {
        throw ApiException('获取公司列表失败: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  /// 获取请求头
  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }
}

/// API异常类
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
