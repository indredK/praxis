import '../../domain/models/product.dart';
import '../mock/product_mock_data.dart';
import '../../../../config/api_config.dart';
import '../../../../core/services/http_client.dart';

/// 产品API服务 - 支持真实后端和Mock数据
///
/// 提供产品数据的获取接口，支持：
/// - 根据筛选条件获取产品列表
/// - 根据ID获取单个/批量产品
/// - 自动Fallback到Mock数据
class ProductApiService {
  static ProductApiService? _instance;
  static ProductApiService get instance => _instance ??= ProductApiService._();

  ProductApiService._();

  // 延迟获取HttpClient实例
  HttpClient get _httpClient => HttpClient.instance;

  /// 获取产品列表（根据筛选条件）
  Future<List<Product>> getProducts({
    String? comparisonMode,
    List<String>? brands,
    List<String>? categories,
    List<String>? productLines,
    List<String>? priceRanges,
    List<String>? colors,
    List<String>? features,
    int? page,
    int? limit,
  }) async {
    try {
      // 如果启用Mock数据
      if (ApiConfig.useMockData) {
        final mockProducts = await ProductMockData.getProducts(
          comparisonMode: comparisonMode,
          brands: brands,
          categories: categories,
          productLines: productLines,
          priceRanges: priceRanges,
          colors: colors,
          features: features,
        );
        // 给Mock数据加标识
        return _addMockLabel(mockProducts);
      }

      // 构建查询参数
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (comparisonMode != null) queryParams['mode'] = comparisonMode;
      if (brands != null && brands.isNotEmpty) {
        queryParams['company'] = brands.join(',');
      }
      if (categories != null && categories.isNotEmpty) {
        queryParams['category'] = categories.join(',');
      }

      // 构建URL
      final uri = Uri.parse(
        ApiConfig.productsUrl,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print('📡 请求产品列表: $uri');
      final response = await _httpClient.get(uri.toString());
      print('✅ 获取到 ${response['meta']['total']} 个产品');

      // 后端返回: { data: [...], meta: { total, page, limit, totalPages } }
      final List<dynamic> productsJson = response['data'] as List;
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('⚠️ 后端请求失败，使用Mock数据: $e');
      print('堆栈: $stackTrace');
      // Fallback到Mock数据
      final mockProducts = await ProductMockData.getProducts(
        comparisonMode: comparisonMode,
        brands: brands,
        categories: categories,
        productLines: productLines,
        priceRanges: priceRanges,
        colors: colors,
        features: features,
      );
      // 给Mock数据加标识
      return _addMockLabel(mockProducts);
    }
  }

  /// 给Mock数据添加标识
  List<Product> _addMockLabel(List<Product> products) {
    return products.map((product) {
      return Product(
        id: product.id,
        name: '🔧 [Mock] ${product.name}', // 添加Mock标识
        company: product.company,
        category: product.category,
        imageUrl: product.imageUrl,
        price: product.price,
        releaseDate: product.releaseDate,
        specs: product.specs,
        description: product.description,
        specifications: product.specifications,
      );
    }).toList();
  }

  /// 根据产品ID列表获取产品
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    try {
      if (ApiConfig.useMockData) {
        final mockProducts = await ProductMockData.getProductsByIds(ids);
        return _addMockLabel(mockProducts);
      }

      // 逐个获取产品（后端暂无batch接口）
      final products = <Product>[];
      for (final id in ids) {
        try {
          final product = await getProductById(id);
          if (product != null) products.add(product);
        } catch (e) {
          print('⚠️ 获取产品 $id 失败: $e');
        }
      }
      return products;
    } catch (e, stackTrace) {
      print('⚠️ 批量获取失败，使用Mock数据: $e');
      final mockProducts = await ProductMockData.getProductsByIds(ids);
      return _addMockLabel(mockProducts);
    }
  }

  /// 根据产品ID获取单个产品
  Future<Product?> getProductById(String id) async {
    try {
      if (ApiConfig.useMockData) {
        final mockProduct = await ProductMockData.getProductById(id);
        return mockProduct != null ? _addMockLabelSingle(mockProduct) : null;
      }

      print('📡 请求产品详情: $id');
      final response = await _httpClient.get('${ApiConfig.productsUrl}/$id');
      print('✅ 获取产品成功: ${response['name']}');

      return Product.fromJson(response);
    } catch (e, stackTrace) {
      print('⚠️ 获取产品失败，使用Mock数据: $e');
      final mockProduct = await ProductMockData.getProductById(id);
      return mockProduct != null ? _addMockLabelSingle(mockProduct) : null;
    }
  }

  /// 给单个产品添加Mock标识
  Product _addMockLabelSingle(Product product) {
    return Product(
      id: product.id,
      name: '🔧 [Mock] ${product.name}',
      company: product.company,
      category: product.category,
      imageUrl: product.imageUrl,
      price: product.price,
      releaseDate: product.releaseDate,
      specs: product.specs,
      description: product.description,
      specifications: product.specifications,
    );
  }

  /// 搜索产品（根据关键词）
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    try {
      if (ApiConfig.useMockData) {
        await ProductMockData.simulateNetworkDelay();
        final allProducts = await ProductMockData.getProducts();
        final filtered = allProducts
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.company.toLowerCase().contains(query.toLowerCase()) ||
                  p.category.toLowerCase().contains(query.toLowerCase()),
            )
            .take(limit)
            .toList();
        return _addMockLabel(filtered);
      }

      // 使用后端列表接口进行简单过滤
      final allProducts = await getProducts(limit: 100);
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
      print('⚠️ 搜索失败: $e');
      throw Exception('搜索产品失败: $e');
    }
  }

  /// 获取热门产品
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    try {
      // 使用普通产品列表接口
      return await getProducts(limit: limit);
    } catch (e) {
      throw Exception('获取热门产品失败: $e');
    }
  }

  /// 获取推荐产品（基于已选产品）
  Future<List<Product>> getRecommendations(List<String> baseProductIds) async {
    try {
      if (ApiConfig.useMockData) {
        await ProductMockData.simulateNetworkDelay();
        final baseProducts = await ProductMockData.getProductsByIds(
          baseProductIds,
        );
        if (baseProducts.isEmpty) return [];

        final category = baseProducts.first.category;
        final company = baseProducts.first.company;
        final allProducts = await ProductMockData.getProducts();

        final recommendations = allProducts
            .where(
              (p) =>
                  !baseProductIds.contains(p.id) &&
                  (p.category == category || p.company == company),
            )
            .take(5)
            .toList();
        return _addMockLabel(recommendations);
      }

      // 使用后端数据（简单实现：返回同类别的其他产品）
      final baseProducts = await getProductsByIds(baseProductIds);
      if (baseProducts.isEmpty) return [];

      final category = baseProducts.first.category;
      final company = baseProducts.first.company;

      // 获取同类别或同品牌的产品
      final allProducts = await getProducts(categories: [category], limit: 20);

      return allProducts
          .where((p) => !baseProductIds.contains(p.id))
          .take(5)
          .toList();
    } catch (e) {
      throw Exception('获取推荐产品失败: $e');
    }
  }

  /// 创建产品
  Future<Product> createProduct(Product product) async {
    try {
      if (ApiConfig.useMockData) {
        await ProductMockData.createProduct(product);
        return product;
      }

      print('📡 创建产品: ${product.id}');
      final response = await _httpClient.post(
        ApiConfig.productsUrl,
        body: product.toJson(),
      );
      print('✅ 产品创建成功');

      return Product.fromJson(response);
    } catch (e) {
      print('⚠️ 后端创建失败，使用Mock数据: $e');
      await ProductMockData.createProduct(product);
      return product;
    }
  }

  /// 更新产品
  Future<Product> updateProduct(String productId, Product product) async {
    try {
      if (ApiConfig.useMockData) {
        await ProductMockData.updateProduct(productId, product);
        return product;
      }

      print('📡 更新产品: $productId');
      final response = await _httpClient.patch(
        '${ApiConfig.productsUrl}/$productId',
        body: product.toJson(),
      );
      print('✅ 产品更新成功');

      return Product.fromJson(response);
    } catch (e) {
      print('⚠️ 后端更新失败，使用Mock数据: $e');
      await ProductMockData.updateProduct(productId, product);
      return product;
    }
  }

  /// 删除产品
  Future<void> deleteProduct(String productId) async {
    try {
      if (ApiConfig.useMockData) {
        await ProductMockData.deleteProduct(productId);
        return;
      }

      print('📡 删除产品: $productId');
      await _httpClient.delete('${ApiConfig.productsUrl}/$productId');
      print('✅ 产品删除成功');
    } catch (e) {
      print('⚠️ 后端删除失败，使用Mock数据: $e');
      await ProductMockData.deleteProduct(productId);
    }
  }
}
