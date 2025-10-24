import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/product/domain/models/product.dart';
import '../../core/constants/app_constants.dart';
import 'cache_service.dart';

/// 缓存服务实现
class CacheServiceImpl implements CacheService {
  static const String _keyProducts = 'cached_products';
  static const String _keyCacheTime = 'cache_time';

  @override
  Future<List<Product>> getCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_keyProducts);
      final cacheTime = prefs.getInt(_keyCacheTime);

      if (productsJson != null && cacheTime != null) {
        // 检查缓存是否过期
        final now = DateTime.now().millisecondsSinceEpoch;
        final cacheAge = now - cacheTime;

        if (cacheAge < AppConstants.cacheExpiration.inMilliseconds) {
          final List<dynamic> data = json.decode(productsJson);
          return data.map((json) => Product.fromJson(json)).toList();
        } else {
          // 缓存过期，清除数据
          await clearCache();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = json.encode(
        products.map((p) => p.toJson()).toList(),
      );
      final cacheTime = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(_keyProducts, productsJson);
      await prefs.setInt(_keyCacheTime, cacheTime);
    } catch (e) {
      // 缓存失败时忽略错误
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyProducts);
      await prefs.remove(_keyCacheTime);
    } catch (e) {
      // 清除失败时忽略错误
    }
  }
}
