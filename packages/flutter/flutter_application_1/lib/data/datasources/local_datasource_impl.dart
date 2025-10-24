import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product.dart';
import 'local_datasource.dart';

/// 本地数据源实现
class LocalDataSourceImpl implements LocalDataSource {
  static const String _keyProducts = 'cached_products';
  static const String _keyCategories = 'cached_categories';
  static const String _keyCompanies = 'cached_companies';

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_keyProducts);
      if (productsJson != null) {
        final List<dynamic> data = json.decode(productsJson);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    final products = await getAllProducts();
    return products.where((product) => product.category == category).toList();
  }

  @override
  Future<List<Product>> getProductsByCompany(String company) async {
    final products = await getAllProducts();
    return products.where((product) => product.company == company).toList();
  }

  @override
  Future<Product> getProductById(String id) async {
    final products = await getAllProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      throw Exception('产品未找到: $id');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final products = await getAllProducts();
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.company.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<SpecComparison>> getProductComparison(
    List<String> productIds,
  ) async {
    // 这里可以实现本地对比逻辑
    // 暂时返回空列表
    return [];
  }

  @override
  Future<ChartData> getChartData(
    String chartType,
    List<String> productIds,
  ) async {
    // 这里可以实现本地图表数据生成逻辑
    // 暂时返回空数据
    return ChartData(title: '图表数据', type: ChartType.bar, items: []);
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_keyCategories);
      if (categoriesJson != null) {
        final List<dynamic> data = json.decode(categoriesJson);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getAllCompanies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companiesJson = prefs.getString(_keyCompanies);
      if (companiesJson != null) {
        final List<dynamic> data = json.decode(companiesJson);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = json.encode(
        products.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_keyProducts, productsJson);
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  @override
  Future<void> clearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyProducts);
      await prefs.remove(_keyCategories);
      await prefs.remove(_keyCompanies);
    } catch (e) {
      // 清除失败时忽略错误
    }
  }
}
