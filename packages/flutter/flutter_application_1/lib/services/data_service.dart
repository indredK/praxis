import '../models/product.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'mock_data_service.dart';

// 数据服务 - 统一的数据访问层
class DataService {
  // 获取所有产品
  static Future<List<Product>> getAllProducts() async {
    try {
      return await ApiService.getAllProducts();
    } catch (e) {
      // API失败时使用模拟数据
      return MockDataService.getAllProducts();
    }
  }

  // 根据类别获取产品
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await ApiService.getProductsByCategory(category);
    } catch (e) {
      return MockDataService.getProductsByCategory(category);
    }
  }

  // 根据公司获取产品
  static Future<List<Product>> getProductsByCompany(String company) async {
    try {
      return await ApiService.getProductsByCompany(company);
    } catch (e) {
      return MockDataService.getProductsByCompany(company);
    }
  }

  // 获取产品详情
  static Future<Product> getProductById(String id) async {
    try {
      return await ApiService.getProductById(id);
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
      return await ApiService.getProductComparison(productIds);
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
      return await ApiService.getChartData(chartType, productIds);
    } catch (e) {
      return _getMockChartData(chartType, productIds);
    }
  }

  // 搜索产品
  static Future<List<Product>> searchProducts(String query) async {
    try {
      return await ApiService.searchProducts(query);
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
      return await ApiService.getAllCompanies();
    } catch (e) {
      return AppConfig.supportedCompanies;
    }
  }

  // 获取所有类别列表
  static Future<List<String>> getAllCategories() async {
    try {
      return await ApiService.getAllCategories();
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

  // 获取公司颜色
  static String getCompanyColor(String company) {
    return AppConfig.getCompanyColor(company);
  }

  // 获取规格配置
  static SpecConfig? getSpecConfig(String specName) {
    return AppConfig.getSpecConfig(specName);
  }

  // 根据类别获取相关规格
  static List<String> getSpecsByCategory(String category) {
    return AppConfig.getSpecsByCategory(category);
  }
}
