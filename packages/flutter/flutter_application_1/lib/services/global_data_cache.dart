import '../models/product.dart';

/// 全局数据缓存服务
class GlobalDataCache {
  static List<Product>? _products;
  static DateTime? _lastUpdate;

  /// 缓存产品数据
  static void cacheProducts(List<Product> products) {
    _products = List.from(products);
    _lastUpdate = DateTime.now();
  }

  /// 获取缓存的产品数据
  static List<Product>? getProducts() {
    return _products;
  }

  /// 清除缓存
  static void clearCache() {
    _products = null;
    _lastUpdate = null;
  }

  /// 检查缓存是否有效（5分钟内）
  static bool isCacheValid() {
    if (_lastUpdate == null) return false;
    return DateTime.now().difference(_lastUpdate!).inMinutes < 5;
  }

  /// 获取最后更新时间
  static DateTime? getLastUpdate() {
    return _lastUpdate;
  }
}
