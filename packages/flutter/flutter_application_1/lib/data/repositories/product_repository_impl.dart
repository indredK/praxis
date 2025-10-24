import '../../domain/repositories/product_repository.dart';
import '../../models/product.dart';
import '../datasources/api_datasource.dart';
import '../datasources/local_datasource.dart';
import '../services/cache_service.dart';

/// 产品仓库实现
/// 实现产品数据的具体操作逻辑
class ProductRepositoryImpl implements ProductRepository {
  final ApiDataSource _apiDataSource;
  final LocalDataSource _localDataSource;
  final CacheService _cacheService;

  ProductRepositoryImpl({
    required ApiDataSource apiDataSource,
    required LocalDataSource localDataSource,
    required CacheService cacheService,
  }) : _apiDataSource = apiDataSource,
       _localDataSource = localDataSource,
       _cacheService = cacheService;

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      // 先尝试从缓存获取
      final cachedProducts = await _cacheService.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }

      // 缓存为空，从API获取
      final products = await _apiDataSource.getAllProducts();

      // 保存到缓存
      await _cacheService.cacheProducts(products);

      return products;
    } catch (e) {
      // API失败时尝试从本地存储获取
      try {
        return await _localDataSource.getAllProducts();
      } catch (localError) {
        // 本地也失败时返回空列表
        return [];
      }
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await _apiDataSource.getProductsByCategory(category);
    } catch (e) {
      return await _localDataSource.getProductsByCategory(category);
    }
  }

  @override
  Future<List<Product>> getProductsByCompany(String company) async {
    try {
      return await _apiDataSource.getProductsByCompany(company);
    } catch (e) {
      return await _localDataSource.getProductsByCompany(company);
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      return await _apiDataSource.getProductById(id);
    } catch (e) {
      return await _localDataSource.getProductById(id);
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _apiDataSource.searchProducts(query);
    } catch (e) {
      return await _localDataSource.searchProducts(query);
    }
  }

  @override
  Future<List<SpecComparison>> getProductComparison(
    List<String> productIds,
  ) async {
    try {
      return await _apiDataSource.getProductComparison(productIds);
    } catch (e) {
      return await _localDataSource.getProductComparison(productIds);
    }
  }

  @override
  Future<ChartData> getChartData(
    String chartType,
    List<String> productIds,
  ) async {
    try {
      return await _apiDataSource.getChartData(chartType, productIds);
    } catch (e) {
      return await _localDataSource.getChartData(chartType, productIds);
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      return await _apiDataSource.getAllCategories();
    } catch (e) {
      return await _localDataSource.getAllCategories();
    }
  }

  @override
  Future<List<String>> getAllCompanies() async {
    try {
      return await _apiDataSource.getAllCompanies();
    } catch (e) {
      return await _localDataSource.getAllCompanies();
    }
  }

  @override
  Future<void> refreshProducts() async {
    try {
      final products = await _apiDataSource.getAllProducts();
      await _cacheService.cacheProducts(products);
      await _localDataSource.saveProducts(products);
    } catch (e) {
      // 刷新失败时抛出异常
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    await _cacheService.clearCache();
    await _localDataSource.clearData();
  }
}
