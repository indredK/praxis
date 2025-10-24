import '../features/product/domain/models/product.dart' as models;

/// 数据服务 - 提供产品数据访问
class DataService {
  // 模拟数据
  static final List<models.Product> _mockProducts = [
    models.Product(
      id: '1',
      name: 'iPhone 15 Pro',
      company: 'Apple',
      category: '手机',
      imageUrl: '',
      price: 7999.0,
      releaseDate: DateTime.now(),
      specs: {},
      description: '最新款iPhone，搭载A17 Pro芯片',
      specifications: {
        '处理器': 'A17 Pro',
        '内存': '8GB',
        '存储': '256GB',
        '屏幕': '6.1英寸',
      },
    ),
    models.Product(
      id: '2',
      name: 'Samsung Galaxy S24',
      company: 'Samsung',
      category: '手机',
      imageUrl: '',
      price: 6999.0,
      releaseDate: DateTime.now(),
      specs: {},
      description: '三星旗舰手机，AI功能强大',
      specifications: {
        '处理器': 'Snapdragon 8 Gen 3',
        '内存': '12GB',
        '存储': '512GB',
        '屏幕': '6.2英寸',
      },
    ),
    models.Product(
      id: '3',
      name: 'MacBook Pro 16',
      company: 'Apple',
      category: '笔记本',
      imageUrl: '',
      price: 19999.0,
      releaseDate: DateTime.now(),
      specs: {},
      description: '专业级笔记本电脑',
      specifications: {
        '处理器': 'M3 Pro',
        '内存': '18GB',
        '存储': '512GB',
        '屏幕': '16.2英寸',
      },
    ),
    models.Product(
      id: '4',
      name: 'Dell XPS 13',
      company: 'Dell',
      category: '笔记本',
      imageUrl: '',
      price: 8999.0,
      releaseDate: DateTime.now(),
      specs: {},
      description: '轻薄便携的商务笔记本',
      specifications: {
        '处理器': 'Intel i7',
        '内存': '16GB',
        '存储': '512GB',
        '屏幕': '13.4英寸',
      },
    ),
  ];

  /// 获取所有产品
  static Future<List<models.Product>> getAllProducts() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockProducts);
  }

  /// 根据ID获取产品
  static Future<models.Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 搜索产品
  static Future<List<models.Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.company.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// 根据类别获取产品
  static Future<List<models.Product>> getProductsByCategory(
    String category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducts
        .where((product) => product.category == category)
        .toList();
  }

  /// 根据公司获取产品
  static Future<List<models.Product>> getProductsByCompany(
    String company,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducts
        .where((product) => product.company == company)
        .toList();
  }

  /// 获取产品对比数据
  static Future<List<models.SpecComparison>> getProductComparison(
    List<String> productIds,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟对比数据
    return [
      models.SpecComparison(
        name: '处理器',
        unit: 'GHz',
        values: [
          models.SpecValue(
            productId: productIds[0],
            productName: 'Product 1',
            value: 3.2,
            displayValue: '3.2',
          ),
          models.SpecValue(
            productId: productIds[1],
            productName: 'Product 2',
            value: 3.0,
            displayValue: '3.0',
          ),
        ],
      ),
      models.SpecComparison(
        name: '内存',
        unit: 'GB',
        values: [
          models.SpecValue(
            productId: productIds[0],
            productName: 'Product 1',
            value: 8,
            displayValue: '8',
          ),
          models.SpecValue(
            productId: productIds[1],
            productName: 'Product 2',
            value: 12,
            displayValue: '12',
          ),
        ],
      ),
      models.SpecComparison(
        name: '存储',
        unit: 'GB',
        values: [
          models.SpecValue(
            productId: productIds[0],
            productName: 'Product 1',
            value: 256,
            displayValue: '256',
          ),
          models.SpecValue(
            productId: productIds[1],
            productName: 'Product 2',
            value: 512,
            displayValue: '512',
          ),
        ],
      ),
    ];
  }

  /// 获取图表数据
  static Future<models.ChartData> getChartData(
    String chartType,
    List<String> productIds,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return models.ChartData(
      type: models.ChartType.bar,
      title: '产品对比图表',
      items: [],
    );
  }
}
