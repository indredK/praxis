import '../../models/product.dart';

/// API数据源接口
/// 定义与远程API交互的方法
abstract class ApiDataSource {
  /// 获取所有产品
  Future<List<Product>> getAllProducts();

  /// 根据类别获取产品
  Future<List<Product>> getProductsByCategory(String category);

  /// 根据公司获取产品
  Future<List<Product>> getProductsByCompany(String company);

  /// 根据ID获取产品详情
  Future<Product> getProductById(String id);

  /// 搜索产品
  Future<List<Product>> searchProducts(String query);

  /// 获取产品对比数据
  Future<List<SpecComparison>> getProductComparison(List<String> productIds);

  /// 获取图表数据
  Future<ChartData> getChartData(String chartType, List<String> productIds);

  /// 获取所有类别
  Future<List<String>> getAllCategories();

  /// 获取所有公司
  Future<List<String>> getAllCompanies();
}
