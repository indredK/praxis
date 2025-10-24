import '../../domain/models/product.dart';
import '../mock/product_mock_data.dart';

/// 产品API服务 - 模拟后端数据获取
///
/// 提供产品数据的获取接口，支持：
/// - 根据筛选条件获取产品列表
/// - 根据ID获取单个/批量产品
/// - 预留真实后端接口对接能力
class ProductApiService {
  static ProductApiService? _instance;
  static ProductApiService get instance => _instance ??= ProductApiService._();

  ProductApiService._();

  /// 获取产品列表（根据筛选条件）
  ///
  /// 参数说明：
  /// - [comparisonMode]: 对比模式（same_brand, same_category等）
  /// - [brands]: 品牌筛选
  /// - [categories]: 类别筛选
  /// - [productLines]: 产品线筛选
  /// - [priceRanges]: 价格区间筛选
  /// - [colors]: 颜色筛选
  /// - [features]: 功能特性筛选
  ///
  /// 后端接口示例：
  /// ```
  /// GET /api/products?mode=same_brand&brands=Apple&categories=手机
  /// ```
  Future<List<Product>> getProducts({
    String? comparisonMode,
    List<String>? brands,
    List<String>? categories,
    List<String>? productLines,
    List<String>? priceRanges,
    List<String>? colors,
    List<String>? features,
  }) async {
    try {
      // TODO: 替换为真实 API 调用
      // final response = await http.get('/api/products', queryParameters: {
      //   'mode': comparisonMode,
      //   'brands': brands?.join(','),
      //   'categories': categories?.join(','),
      //   ...
      // });
      // return response.data.map((json) => Product.fromJson(json)).toList();

      // 使用 Mock 数据
      return await ProductMockData.getProducts(
        comparisonMode: comparisonMode,
        brands: brands,
        categories: categories,
        productLines: productLines,
        priceRanges: priceRanges,
        colors: colors,
        features: features,
      );
    } catch (e) {
      throw Exception('获取产品列表失败: $e');
    }
  }

  /// 根据产品ID列表获取产品
  ///
  /// 后端接口示例：
  /// ```
  /// GET /api/products/batch?ids=iphone_15_pro,galaxy_s24
  /// ```
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    try {
      // TODO: 替换为真实 API 调用
      // final response = await http.get('/api/products/batch',
      //   queryParameters: {'ids': ids.join(',')});
      // return response.data.map((json) => Product.fromJson(json)).toList();

      return await ProductMockData.getProductsByIds(ids);
    } catch (e) {
      throw Exception('批量获取产品失败: $e');
    }
  }

  /// 根据产品ID获取单个产品
  ///
  /// 后端接口示例：
  /// ```
  /// GET /api/products/{id}
  /// ```
  Future<Product?> getProductById(String id) async {
    try {
      // TODO: 替换为真实 API 调用
      // final response = await http.get('/api/products/$id');
      // return Product.fromJson(response.data);

      return await ProductMockData.getProductById(id);
    } catch (e) {
      throw Exception('获取产品详情失败: $e');
    }
  }

  /// 搜索产品（根据关键词）
  ///
  /// 后端接口示例：
  /// ```
  /// GET /api/products/search?q=iPhone&limit=20
  /// ```
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    try {
      // TODO: 替换为真实 API 调用
      // final response = await http.get('/api/products/search',
      //   queryParameters: {'q': query, 'limit': limit});
      // return response.data.map((json) => Product.fromJson(json)).toList();

      // 使用 Mock 数据（简单实现）
      await ProductMockData.simulateNetworkDelay();
      final allProducts = await ProductMockData.getProducts();
      return allProducts
          .where(
            (p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.company.toLowerCase().contains(query.toLowerCase()) ||
                p.category.toLowerCase().contains(query.toLowerCase()),
          )
          .take(limit)
          .toList();
    } catch (e) {
      throw Exception('搜索产品失败: $e');
    }
  }

  /// 获取热门产品
  ///
  /// 后端接口示例：
  /// ```
  /// GET /api/products/popular?limit=10
  /// ```
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    try {
      // TODO: 替换为真实 API 调用
      // final response = await http.get('/api/products/popular',
      //   queryParameters: {'limit': limit});
      // return response.data.map((json) => Product.fromJson(json)).toList();

      // 使用 Mock 数据（返回前N个）
      await ProductMockData.simulateNetworkDelay();
      final allProducts = await ProductMockData.getProducts();
      return allProducts.take(limit).toList();
    } catch (e) {
      throw Exception('获取热门产品失败: $e');
    }
  }

  /// 获取推荐产品（基于已选产品）
  ///
  /// 后端接口示例：
  /// ```
  /// POST /api/products/recommendations
  /// Body: { "productIds": ["iphone_15_pro"] }
  /// ```
  Future<List<Product>> getRecommendations(List<String> baseProductIds) async {
    try {
      // TODO: 替换为真实 API 调用
      // final response = await http.post('/api/products/recommendations',
      //   data: {'productIds': baseProductIds});
      // return response.data.map((json) => Product.fromJson(json)).toList();

      // 使用 Mock 数据（简单实现：返回同类别的其他产品）
      await ProductMockData.simulateNetworkDelay();
      final baseProducts = await ProductMockData.getProductsByIds(
        baseProductIds,
      );
      if (baseProducts.isEmpty) return [];

      final category = baseProducts.first.category;
      final company = baseProducts.first.company;
      final allProducts = await ProductMockData.getProducts();

      return allProducts
          .where(
            (p) =>
                !baseProductIds.contains(p.id) &&
                (p.category == category || p.company == company),
          )
          .take(5)
          .toList();
    } catch (e) {
      throw Exception('获取推荐产品失败: $e');
    }
  }
}
