import '../models/product.dart';

class MockDataService {
  // 模拟网络延迟 - 设置为0.1秒
  static const Duration _networkDelay = Duration(milliseconds: 100);

  static final List<Product> _products = [
    // 手机产品
    Product(
      id: 'iphone15pro',
      name: 'iPhone 15 Pro',
      company: 'Apple',
      category: '手机',
      imageUrl:
          'https://via.placeholder.com/200x200/007AFF/FFFFFF?text=iPhone+15+Pro',
      price: 999.0,
      releaseDate: DateTime(2023, 9, 15),
      specs: {
        '屏幕尺寸': '6.1英寸',
        '分辨率': '2556×1179',
        '处理器': 'A17 Pro',
        '内存': '8GB',
        '存储': '128GB',
        '摄像头': '48MP主摄',
        '电池容量': '3274mAh',
        '重量': '187g',
        '防水等级': 'IP68',
        '操作系统': 'iOS 17',
      },
    ),
    Product(
      id: 'samsung_s24',
      name: 'Galaxy S24 Ultra',
      company: 'Samsung',
      category: '手机',
      imageUrl:
          'https://via.placeholder.com/200x200/1F2937/FFFFFF?text=Galaxy+S24',
      price: 1199.0,
      releaseDate: DateTime(2024, 1, 17),
      specs: {
        '屏幕尺寸': '6.8英寸',
        '分辨率': '3120×1440',
        '处理器': 'Snapdragon 8 Gen 3',
        '内存': '12GB',
        '存储': '256GB',
        '摄像头': '200MP主摄',
        '电池容量': '5000mAh',
        '重量': '232g',
        '防水等级': 'IP68',
        '操作系统': 'Android 14',
      },
    ),
    Product(
      id: 'pixel8pro',
      name: 'Pixel 8 Pro',
      company: 'Google',
      category: '手机',
      imageUrl:
          'https://via.placeholder.com/200x200/4285F4/FFFFFF?text=Pixel+8+Pro',
      price: 999.0,
      releaseDate: DateTime(2023, 10, 4),
      specs: {
        '屏幕尺寸': '6.7英寸',
        '分辨率': '3120×1440',
        '处理器': 'Google Tensor G3',
        '内存': '12GB',
        '存储': '128GB',
        '摄像头': '50MP主摄',
        '电池容量': '5050mAh',
        '重量': '213g',
        '防水等级': 'IP68',
        '操作系统': 'Android 14',
      },
    ),

    // 汽车产品
    Product(
      id: 'tesla_model3',
      name: 'Model 3',
      company: 'Tesla',
      category: '汽车',
      imageUrl:
          'https://via.placeholder.com/200x200/CC0000/FFFFFF?text=Model+3',
      price: 38990.0,
      releaseDate: DateTime(2017, 7, 28),
      specs: {
        '续航里程': '358km',
        '加速时间': '4.4秒',
        '最高时速': '225km/h',
        '电池容量': '75kWh',
        '充电时间': '15分钟',
        '座位数': '5座',
        '行李箱容积': '425L',
        '自动驾驶': 'FSD',
        '车身长度': '4694mm',
      },
    ),
    Product(
      id: 'tesla_model_y',
      name: 'Model Y',
      company: 'Tesla',
      category: '汽车',
      imageUrl:
          'https://via.placeholder.com/200x200/CC0000/FFFFFF?text=Model+Y',
      price: 43990.0,
      releaseDate: DateTime(2020, 3, 13),
      specs: {
        '续航里程': '565km',
        '加速时间': '3.7秒',
        '最高时速': '250km/h',
        '电池容量': '100kWh',
        '充电时间': '15分钟',
        '座位数': '7座',
        '行李箱容积': '854L',
        '自动驾驶': 'FSD',
        '车身长度': '4751mm',
      },
    ),

    // 笔记本电脑
    Product(
      id: 'macbook_pro_14',
      name: 'MacBook Pro 14"',
      company: 'Apple',
      category: '笔记本电脑',
      imageUrl:
          'https://via.placeholder.com/200x200/007AFF/FFFFFF?text=MacBook+Pro',
      price: 1999.0,
      releaseDate: DateTime(2023, 10, 30),
      specs: {
        '屏幕尺寸': '14.2英寸',
        '分辨率': '3024×1964',
        '处理器': 'M3 Pro',
        '内存': '18GB',
        '存储': '512GB SSD',
        '显卡': 'M3 Pro GPU',
        '电池续航': '18小时',
        '重量': '1.6kg',
        '接口': '3×Thunderbolt 4',
        '操作系统': 'macOS Sonoma',
      },
    ),
    Product(
      id: 'surface_laptop_studio',
      name: 'Surface Laptop Studio 2',
      company: 'Microsoft',
      category: '笔记本电脑',
      imageUrl:
          'https://via.placeholder.com/200x200/00BCF2/FFFFFF?text=Surface',
      price: 1599.0,
      releaseDate: DateTime(2023, 10, 3),
      specs: {
        '屏幕尺寸': '14.4英寸',
        '分辨率': '2400×1600',
        '处理器': 'Intel Core i7-13700H',
        '内存': '16GB',
        '存储': '512GB SSD',
        '显卡': 'RTX 4060',
        '电池续航': '19小时',
        '重量': '1.82kg',
        '接口': '2×USB-C, 1×USB-A',
        '操作系统': 'Windows 11',
      },
    ),
  ];

  // 缓存产品列表，避免重复创建
  static List<Product>? _cachedProducts;

  // 获取所有产品（同步方法，无延迟）
  static List<Product> getAllProductsSync() {
    // 如果缓存存在，直接返回
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }

    // 创建缓存
    _cachedProducts = List.from(_products);
    return _cachedProducts!;
  }

  // 获取所有产品（异步方法，带0.1秒延迟）
  static Future<List<Product>> getAllProducts() async {
    await Future.delayed(_networkDelay);

    // 如果缓存存在，直接返回
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }

    // 创建缓存
    _cachedProducts = List.from(_products);
    return _cachedProducts!;
  }

  // 缓存按类别过滤的结果
  static final Map<String, List<Product>> _categoryCache = {};

  // 按类别获取产品（带延迟）
  static Future<List<Product>> getProductsByCategory(String category) async {
    await Future.delayed(_networkDelay);

    if (_categoryCache.containsKey(category)) {
      return _categoryCache[category]!;
    }

    final result = _products
        .where((product) => product.category == category)
        .toList();
    _categoryCache[category] = result;
    return result;
  }

  // 缓存按公司过滤的结果
  static final Map<String, List<Product>> _companyCache = {};

  // 按公司获取产品（带延迟）
  static Future<List<Product>> getProductsByCompany(String company) async {
    await Future.delayed(_networkDelay);

    if (_companyCache.containsKey(company)) {
      return _companyCache[company]!;
    }

    final result = _products
        .where((product) => product.company == company)
        .toList();
    _companyCache[company] = result;
    return result;
  }

  // 获取所有类别
  static List<String> getAllCategories() {
    return _products.map((product) => product.category).toSet().toList();
  }

  // 获取所有公司
  static List<String> getAllCompanies() {
    return _products.map((product) => product.company).toSet().toList();
  }

  // 获取产品对比数据（带延迟）
  static Future<List<SpecComparison>> getSpecComparisons(
    List<String> productIds,
  ) async {
    await Future.delayed(_networkDelay);
    final selectedProducts = _products
        .where((p) => productIds.contains(p.id))
        .toList();

    if (selectedProducts.isEmpty) return [];

    // 优化：只对比共有参数和重要参数
    final commonSpecKeys = _getCommonSpecKeys(selectedProducts);
    final importantSpecs = _getImportantSpecs(selectedProducts);
    final allSpecKeys = {...commonSpecKeys, ...importantSpecs};

    final comparisons = <SpecComparison>[];

    for (final specKey in allSpecKeys) {
      final values = <SpecValue>[];

      for (final product in selectedProducts) {
        final specValue = product.specs[specKey];
        if (specValue != null) {
          values.add(
            SpecValue(
              productId: product.id,
              productName: product.name,
              value: specValue,
              displayValue: specValue.toString(),
            ),
          );
        } else {
          // 对于非共有参数，显示"-"表示无此参数
          values.add(
            SpecValue(
              productId: product.id,
              productName: product.name,
              value: null,
              displayValue: '-',
            ),
          );
        }
      }

      if (values.isNotEmpty) {
        comparisons.add(
          SpecComparison(
            name: specKey,
            unit: getUnitForSpec(specKey),
            values: values,
          ),
        );
      }
    }

    return comparisons;
  }

  // 获取所有产品共有的规格参数
  static Set<String> _getCommonSpecKeys(List<Product> products) {
    if (products.isEmpty) return {};

    // 从第一个产品开始，逐步求交集
    Set<String> commonKeys = Set.from(products.first.specs.keys);

    for (int i = 1; i < products.length; i++) {
      commonKeys = commonKeys.intersection(products[i].specs.keys.toSet());
    }

    return commonKeys;
  }

  // 获取重要参数（即使不是所有产品都有）
  static Set<String> _getImportantSpecs(List<Product> products) {
    final importantSpecs = <String>{};

    // 定义重要参数列表
    final importantKeys = [
      '价格',
      '屏幕尺寸',
      '处理器',
      '内存',
      '存储',
      '电池容量',
      '摄像头',
      '重量',
      '操作系统',
      '网络',
      '颜色',
      '材质',
      'CPU',
      'GPU',
      'RAM',
      'ROM',
      '分辨率',
      '刷新率',
    ];

    // 检查哪些重要参数在至少一半的产品中存在
    final productCount = products.length;
    final threshold = (productCount / 2).ceil();

    for (final key in importantKeys) {
      int count = 0;
      for (final product in products) {
        if (product.specs.containsKey(key)) {
          count++;
        }
      }

      // 如果至少一半的产品有这个参数，就加入对比
      if (count >= threshold) {
        importantSpecs.add(key);
      }
    }

    return importantSpecs;
  }

  // 获取价格对比图表数据
  static ChartData getPriceComparisonChart(List<String> productIds) {
    final selectedProducts = _products
        .where((p) => productIds.contains(p.id))
        .toList();

    final items = selectedProducts
        .map(
          (product) => ChartItem(
            label: product.name,
            value: product.price,
            color: getCompanyColor(product.company),
            metadata: {
              'company': product.company,
              'category': product.category,
            },
          ),
        )
        .toList();

    return ChartData(type: ChartType.bar, title: '价格对比', items: items);
  }

  // 获取性能雷达图数据
  static ChartData getPerformanceRadarChart(List<String> productIds) {
    final selectedProducts = _products
        .where((p) => productIds.contains(p.id))
        .toList();

    // 为每个产品创建性能评分
    final items = <ChartItem>[];

    for (final product in selectedProducts) {
      double performanceScore = calculatePerformanceScore(product);
      items.add(
        ChartItem(
          label: product.name,
          value: performanceScore,
          color: getCompanyColor(product.company),
          metadata: {'company': product.company, 'category': product.category},
        ),
      );
    }

    return ChartData(type: ChartType.radar, title: '性能对比', items: items);
  }

  // 计算产品性能评分（基于规格的简单算法）
  static double calculatePerformanceScore(Product product) {
    double score = 0.0;

    // 基于价格性价比
    score += (10000 / product.price) * 10;

    // 基于内存
    final memory = product.specs['内存']?.toString() ?? '';
    if (memory.contains('18GB'))
      score += 20;
    else if (memory.contains('16GB'))
      score += 18;
    else if (memory.contains('12GB'))
      score += 15;
    else if (memory.contains('8GB'))
      score += 10;

    // 基于存储
    final storage = product.specs['存储']?.toString() ?? '';
    if (storage.contains('1TB'))
      score += 15;
    else if (storage.contains('512GB'))
      score += 12;
    else if (storage.contains('256GB'))
      score += 8;
    else if (storage.contains('128GB'))
      score += 5;

    return score.clamp(0, 100);
  }

  // 获取公司颜色
  static String getCompanyColor(String company) {
    switch (company) {
      case 'Apple':
        return '#007AFF';
      case 'Samsung':
        return '#1F2937';
      case 'Google':
        return '#4285F4';
      case 'Tesla':
        return '#CC0000';
      case 'Microsoft':
        return '#00BCF2';
      default:
        return '#6B7280';
    }
  }

  // 获取规格单位
  static String getUnitForSpec(String specName) {
    switch (specName) {
      case '屏幕尺寸':
        return '英寸';
      case '价格':
        return '美元';
      case '重量':
        return 'g';
      case '电池容量':
        return 'mAh';
      case '续航里程':
        return 'km';
      case '加速时间':
        return '秒';
      case '最高时速':
        return 'km/h';
      case '充电时间':
        return '分钟';
      case '座位数':
        return '座';
      case '行李箱容积':
        return 'L';
      case '车身长度':
        return 'mm';
      case '电池续航':
        return '小时';
      default:
        return '';
    }
  }
}
