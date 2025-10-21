import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/app_config.dart';
import 'mock_data_service.dart';
import 'mock_backend_service.dart';

// API服务 - 负责与后端通信
class ApiService {
  static const String baseUrl = 'https://api.productcompare.com/v1';
  static const Duration timeout = Duration(seconds: 30);

  // HTTP客户端
  static final http.Client _client = http.Client();

  // 获取所有产品
  static Future<List<Product>> getAllProducts() async {
    try {
      // 暂时使用模拟后端，后续可以切换到真实API
      return await MockBackendService.getAllProducts();

      // 真实API调用 (暂时注释)
      /*
      final response = await _client
          .get(Uri.parse('$baseUrl/products'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('获取产品列表失败: ${response.statusCode}');
      }
      */
    } catch (e) {
      // 网络错误时返回模拟数据
      return MockDataService.getAllProducts();
    }
  }

  // 根据类别获取产品
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      // 暂时使用模拟后端
      return await MockBackendService.getProductsByCategory(category);
    } catch (e) {
      return MockDataService.getProductsByCategory(category);
    }
  }

  // 根据公司获取产品
  static Future<List<Product>> getProductsByCompany(String company) async {
    try {
      // 暂时使用模拟后端
      return await MockBackendService.getProductsByCompany(company);
    } catch (e) {
      return MockDataService.getProductsByCompany(company);
    }
  }

  // 获取产品详情
  static Future<Product> getProductById(String id) async {
    try {
      // 暂时使用模拟后端
      return await MockBackendService.getProductById(id);
    } catch (e) {
      final products = MockDataService.getAllProducts();
      return products.firstWhere((p) => p.id == id);
    }
  }

  // 获取产品对比数据
  static Future<List<SpecComparison>> getProductComparison(
    List<String> productIds,
  ) async {
    try {
      // 暂时使用模拟后端
      return await MockBackendService.getProductComparison(productIds);
    } catch (e) {
      return MockDataService.getSpecComparisons(productIds);
    }
  }

  // 获取图表数据
  static Future<ChartData> getChartData(
    String chartType,
    List<String> productIds,
  ) async {
    try {
      // 暂时使用模拟后端
      return await MockBackendService.getChartData(chartType, productIds);
    } catch (e) {
      return _getMockChartData(chartType, productIds);
    }
  }

  // 搜索产品
  static Future<List<Product>> searchProducts(String query) async {
    try {
      // 暂时使用模拟后端
      return await MockBackendService.searchProducts(query);
    } catch (e) {
      final products = MockDataService.getAllProducts();
      return products
          .where(
            (p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.company.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  // 获取所有公司列表
  static Future<List<String>> getAllCompanies() async {
    try {
      // 暂时使用模拟后端
      return await MockBackendService.getAllCompanies();
    } catch (e) {
      return AppConfig.supportedCompanies;
    }
  }

  // 获取所有类别列表
  static Future<List<String>> getAllCategories() async {
    try {
      // 暂时使用模拟后端
      return await MockBackendService.getAllCategories();
    } catch (e) {
      return AppConfig.productCategories;
    }
  }

  // 获取模拟图表数据
  static ChartData _getMockChartData(
    String chartType,
    List<String> productIds,
  ) {
    switch (chartType) {
      case 'price_comparison':
        return MockDataService.getPriceComparisonChart(productIds);
      case 'performance_analysis':
        return MockDataService.getPerformanceRadarChart(productIds);
      default:
        return MockDataService.getPriceComparisonChart(productIds);
    }
  }

  // 获取请求头 (暂时未使用，保留用于后续真实API调用)
  // static Map<String, String> _getHeaders() {
  //   return {
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //     'User-Agent': 'ProductCompare/1.0.0',
  //     // 这里可以添加认证token等
  //     // 'Authorization': 'Bearer $token',
  //   };
  // }

  // 释放资源
  static void dispose() {
    _client.close();
  }
}

// API异常类
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
