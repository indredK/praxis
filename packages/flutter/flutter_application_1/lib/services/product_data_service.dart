import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_api_service.dart';

/// 产品数据服务
///
/// 功能特性：
/// 1. 智能缓存：按筛选条件缓存产品列表
/// 2. 后端支持：预留从后端获取数据的能力
/// 3. 缓存管理：支持清除指定缓存或全部缓存
/// 4. 筛选支持：支持多种筛选条件组合
///
/// 使用示例：
/// ```dart
/// // 1. 获取产品列表（根据筛选条件）
/// final products = await ProductDataService.instance.getProducts(
///   brands: ['Apple', 'Samsung'],
///   categories: ['手机'],
/// );
///
/// // 2. 获取单个产品
/// final product = await service.getProductById('iphone_15_pro');
///
/// // 3. 清除缓存
/// service.clearCache();
/// ```
class ProductDataService {
  static ProductDataService? _instance;
  static ProductDataService get instance =>
      _instance ??= ProductDataService._();

  ProductDataService._();

  final ProductApiService _apiService = ProductApiService.instance;

  // 产品列表缓存（按筛选条件的 key 缓存）
  final Map<String, List<Product>> _productsCache = {};

  // 单个产品缓存（按 ID 缓存）
  final Map<String, Product> _productCache = {};

  // 缓存时间戳
  final Map<String, DateTime> _cacheTimestamps = {};

  // 缓存有效期（3分钟）
  static const Duration _cacheExpiry = Duration(minutes: 3);

  /// 检查缓存是否有效
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// 生成缓存 key（根据筛选条件）
  String _generateCacheKey({
    String? comparisonMode,
    List<String>? brands,
    List<String>? categories,
    List<String>? productLines,
    List<String>? priceRanges,
    List<String>? colors,
    List<String>? features,
  }) {
    final parts = <String>[
      'products',
      if (comparisonMode != null) 'mode:$comparisonMode',
      if (brands != null && brands.isNotEmpty) 'brands:${brands.join(",")}',
      if (categories != null && categories.isNotEmpty)
        'categories:${categories.join(",")}',
      if (productLines != null && productLines.isNotEmpty)
        'lines:${productLines.join(",")}',
      if (priceRanges != null && priceRanges.isNotEmpty)
        'prices:${priceRanges.join(",")}',
      if (colors != null && colors.isNotEmpty) 'colors:${colors.join(",")}',
      if (features != null && features.isNotEmpty)
        'features:${features.join(",")}',
    ];
    return parts.join('_');
  }

  /// 获取产品列表（支持从后端获取，带缓存）
  ///
  /// 工作流程：
  /// 1. 生成缓存 key
  /// 2. 检查缓存是否有效，有效则直接返回
  /// 3. 尝试从后端 API 获取数据
  /// 4. 缓存结果并返回
  Future<List<Product>> getProducts({
    String? comparisonMode,
    List<String>? brands,
    List<String>? categories,
    List<String>? productLines,
    List<String>? priceRanges,
    List<String>? colors,
    List<String>? features,
  }) async {
    // 1. 生成缓存 key
    final cacheKey = _generateCacheKey(
      comparisonMode: comparisonMode,
      brands: brands,
      categories: categories,
      productLines: productLines,
      priceRanges: priceRanges,
      colors: colors,
      features: features,
    );

    // 2. 检查缓存
    if (_isCacheValid(cacheKey)) {
      final cached = _productsCache[cacheKey];
      if (cached != null) {
        debugPrint('返回缓存的产品列表: $cacheKey (${cached.length} 个产品)');
        return cached;
      }
    }

    debugPrint('从后端获取产品列表: $cacheKey');

    try {
      // 3. 从 API 获取数据
      final products = await _apiService.getProducts(
        comparisonMode: comparisonMode,
        brands: brands,
        categories: categories,
        productLines: productLines,
        priceRanges: priceRanges,
        colors: colors,
        features: features,
      );

      // 4. 缓存结果
      _productsCache[cacheKey] = products;
      _cacheTimestamps[cacheKey] = DateTime.now();

      // 同时缓存单个产品
      for (final product in products) {
        _productCache[product.id] = product;
        _cacheTimestamps['product:${product.id}'] = DateTime.now();
      }

      debugPrint('已缓存产品列表: $cacheKey (${products.length} 个产品)');
      return products;
    } catch (e) {
      debugPrint('获取产品列表失败: $e');
      rethrow;
    }
  }

  /// 根据产品ID获取单个产品（带缓存）
  Future<Product?> getProductById(String id) async {
    final cacheKey = 'product:$id';

    // 检查缓存
    if (_isCacheValid(cacheKey)) {
      final cached = _productCache[id];
      if (cached != null) {
        debugPrint('返回缓存的产品: $id');
        return cached;
      }
    }

    debugPrint('从后端获取产品: $id');

    try {
      final product = await _apiService.getProductById(id);
      if (product != null) {
        _productCache[id] = product;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }
      return product;
    } catch (e) {
      debugPrint('获取产品失败: $e');
      rethrow;
    }
  }

  /// 根据产品ID列表批量获取产品（带缓存）
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    final products = <Product>[];
    final uncachedIds = <String>[];

    // 先从缓存获取
    for (final id in ids) {
      final cacheKey = 'product:$id';
      if (_isCacheValid(cacheKey)) {
        final cached = _productCache[id];
        if (cached != null) {
          products.add(cached);
          continue;
        }
      }
      uncachedIds.add(id);
    }

    // 批量获取未缓存的产品
    if (uncachedIds.isNotEmpty) {
      debugPrint('批量获取产品: ${uncachedIds.length} 个');
      try {
        final fetchedProducts = await _apiService.getProductsByIds(uncachedIds);

        // 缓存新获取的产品
        for (final product in fetchedProducts) {
          _productCache[product.id] = product;
          _cacheTimestamps['product:${product.id}'] = DateTime.now();
          products.add(product);
        }
      } catch (e) {
        debugPrint('批量获取产品失败: $e');
        rethrow;
      }
    }

    return products;
  }

  /// 搜索产品
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    try {
      return await _apiService.searchProducts(query, limit: limit);
    } catch (e) {
      debugPrint('搜索产品失败: $e');
      rethrow;
    }
  }

  /// 获取热门产品
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    final cacheKey = 'popular:$limit';

    // 检查缓存
    if (_isCacheValid(cacheKey)) {
      final cached = _productsCache[cacheKey];
      if (cached != null) {
        debugPrint('返回缓存的热门产品');
        return cached;
      }
    }

    try {
      final products = await _apiService.getPopularProducts(limit: limit);
      _productsCache[cacheKey] = products;
      _cacheTimestamps[cacheKey] = DateTime.now();
      return products;
    } catch (e) {
      debugPrint('获取热门产品失败: $e');
      rethrow;
    }
  }

  /// 获取推荐产品
  Future<List<Product>> getRecommendations(List<String> baseProductIds) async {
    final cacheKey = 'recommendations:${baseProductIds.join(",")}';

    // 检查缓存
    if (_isCacheValid(cacheKey)) {
      final cached = _productsCache[cacheKey];
      if (cached != null) {
        debugPrint('返回缓存的推荐产品');
        return cached;
      }
    }

    try {
      final products = await _apiService.getRecommendations(baseProductIds);
      _productsCache[cacheKey] = products;
      _cacheTimestamps[cacheKey] = DateTime.now();
      return products;
    } catch (e) {
      debugPrint('获取推荐产品失败: $e');
      rethrow;
    }
  }

  /// 清除所有缓存
  void clearCache() {
    _productsCache.clear();
    _productCache.clear();
    _cacheTimestamps.clear();
    debugPrint('已清除所有产品缓存');
  }

  /// 清除产品列表缓存（保留单个产品缓存）
  void clearProductsCache() {
    _productsCache.clear();
    _cacheTimestamps.removeWhere((key, _) => !key.startsWith('product:'));
    debugPrint('已清除产品列表缓存');
  }

  /// 清除指定产品的缓存
  void clearProductCache(String productId) {
    _productCache.remove(productId);
    _cacheTimestamps.remove('product:$productId');
    debugPrint('已清除产品缓存: $productId');
  }

  /// 预加载产品（批量缓存）
  Future<void> preloadProducts(List<String> ids) async {
    try {
      await getProductsByIds(ids);
      debugPrint('预加载完成: ${ids.length} 个产品');
    } catch (e) {
      debugPrint('预加载产品失败: $e');
    }
  }
}
