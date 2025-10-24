import '../../models/product.dart';

/// 缓存服务接口
abstract class CacheService {
  /// 获取缓存的产品
  Future<List<Product>> getCachedProducts();

  /// 缓存产品数据
  Future<void> cacheProducts(List<Product> products);

  /// 清除缓存
  Future<void> clearCache();
}
