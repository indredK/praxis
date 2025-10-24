import '../models/product.dart';

// 全局数据缓存 - 避免重复加载
class GlobalDataCache {
  static List<Product>? _cachedProducts;
  static Map<String, List<SpecComparison>> _comparisonCache = {};
  static Map<String, ChartData> _chartCache = {};

  // 设置缓存的产品数据
  static void setProducts(List<Product> products) {
    _cachedProducts = products;
  }

  // 获取缓存的产品数据
  static List<Product>? getProducts() {
    return _cachedProducts;
  }

  // 根据ID获取产品
  static List<Product> getProductsByIds(List<String> ids) {
    if (_cachedProducts == null) return [];
    return _cachedProducts!
        .where((product) => ids.contains(product.id))
        .toList();
  }

  // 缓存对比数据
  static void setComparison(String key, List<SpecComparison> comparisons) {
    _comparisonCache[key] = comparisons;
  }

  // 获取缓存的对比数据
  static List<SpecComparison>? getComparison(String key) {
    return _comparisonCache[key];
  }

  // 缓存图表数据
  static void setChartData(String key, ChartData chartData) {
    _chartCache[key] = chartData;
  }

  // 获取缓存的图表数据
  static ChartData? getChartData(String key) {
    return _chartCache[key];
  }

  // 清理缓存
  static void clearCache() {
    _cachedProducts = null;
    _comparisonCache.clear();
    _chartCache.clear();
  }
}
