import 'dart:math';
import '../models/product.dart';
import '../config/app_config.dart';

// 模拟后端服务 - 提供完整的API数据
class MockBackendService {
  static final Random _random = Random();

  // 模拟产品数据库
  static final List<Product> _products = _generateMockProducts();

  // 生成模拟产品数据
  static List<Product> _generateMockProducts() {
    final companies = AppConfig.supportedCompanies;
    final categories = AppConfig.productCategories;

    List<Product> products = [];
    int id = 1;

    // 为每个公司和类别组合生成产品
    for (final company in companies) {
      for (final category in categories) {
        // 每个公司-类别组合生成1-3个产品
        final productCount = _random.nextInt(3) + 1;

        for (int i = 0; i < productCount; i++) {
          products.add(_generateProduct(id++, company, category));
        }
      }
    }

    return products;
  }

  // 生成单个产品
  static Product _generateProduct(int id, String company, String category) {
    final productNames = _getProductNames(company, category);
    final name = productNames[_random.nextInt(productNames.length)];

    return Product(
      id: 'product_$id',
      name: name,
      company: company,
      category: category,
      imageUrl: 'https://via.placeholder.com/300x200?text=${company}+$name',
      price: _generatePrice(category),
      releaseDate: _generateReleaseDate(),
      specs: _generateSpecs(category),
    );
  }

  // 获取产品名称
  static List<String> _getProductNames(String company, String category) {
    final nameMap = {
      '手机': {
        'Apple': ['iPhone 15 Pro', 'iPhone 15', 'iPhone 14 Pro', 'iPhone 14'],
        'Samsung': [
          'Galaxy S24 Ultra',
          'Galaxy S24',
          'Galaxy Z Fold5',
          'Galaxy Z Flip5',
        ],
        'Google': ['Pixel 8 Pro', 'Pixel 8', 'Pixel 7a'],
        'Huawei': ['Mate 60 Pro', 'P60 Pro', 'nova 11'],
        'Xiaomi': ['14 Pro', '14', '13 Ultra', 'Redmi Note 13'],
        'Oppo': ['Find X7 Ultra', 'Find X7', 'Reno11 Pro'],
        'Vivo': ['X100 Pro', 'X100', 'S18 Pro'],
        'OnePlus': ['12 Pro', '12', '11'],
        'Tesla': ['Model Phone', 'Cyber Phone'],
        'Microsoft': ['Surface Phone', 'Lumia Pro'],
      },
      '笔记本电脑': {
        'Apple': [
          'MacBook Pro 16"',
          'MacBook Pro 14"',
          'MacBook Air 15"',
          'MacBook Air 13"',
        ],
        'Samsung': ['Galaxy Book4 Ultra', 'Galaxy Book4 Pro', 'Galaxy Book4'],
        'Google': ['Pixelbook Go', 'Chromebook Plus'],
        'Microsoft': ['Surface Laptop 5', 'Surface Pro 9', 'Surface Studio 2+'],
        'Huawei': ['MateBook X Pro', 'MateBook D16', 'MateBook 14'],
        'Xiaomi': ['RedmiBook Pro 15', 'Mi Notebook Pro'],
        'Oppo': ['Find X7 Ultra', 'Find X7'],
        'Vivo': ['X100 Pro', 'X100'],
        'OnePlus': ['OnePlus Book'],
        'Tesla': ['Model Laptop', 'Cyber Laptop'],
      },
      '汽车': {
        'Tesla': ['Model S', 'Model 3', 'Model X', 'Model Y', 'Cybertruck'],
        'Apple': ['Apple Car', 'iCar Pro'],
        'Google': ['Waymo One', 'Pixel Car'],
        'Microsoft': ['Surface Car', 'Xbox Car'],
        'Samsung': ['Galaxy Car', 'Smart Car'],
        'Huawei': ['Mate Car', 'P Car'],
        'Xiaomi': ['Mi Car', 'Redmi Car'],
        'Oppo': ['Find Car', 'Reno Car'],
        'Vivo': ['X Car', 'S Car'],
        'OnePlus': ['OnePlus Car'],
      },
      '平板电脑': {
        'Apple': ['iPad Pro 12.9"', 'iPad Pro 11"', 'iPad Air', 'iPad'],
        'Samsung': ['Galaxy Tab S9 Ultra', 'Galaxy Tab S9+', 'Galaxy Tab S9'],
        'Google': ['Pixel Tablet', 'Pixel Slate'],
        'Microsoft': ['Surface Pro 9', 'Surface Go 4'],
        'Huawei': ['MatePad Pro', 'MatePad'],
        'Xiaomi': ['Mi Pad 6', 'Redmi Pad'],
        'Oppo': ['Find Pad', 'Reno Pad'],
        'Vivo': ['X Pad', 'S Pad'],
        'OnePlus': ['OnePlus Pad'],
        'Tesla': ['Model Pad', 'Cyber Pad'],
      },
      '智能手表': {
        'Apple': [
          'Apple Watch Series 9',
          'Apple Watch SE',
          'Apple Watch Ultra 2',
        ],
        'Samsung': [
          'Galaxy Watch6 Classic',
          'Galaxy Watch6',
          'Galaxy Watch5 Pro',
        ],
        'Google': ['Pixel Watch 2', 'Pixel Watch'],
        'Huawei': ['Watch GT 4', 'Watch 4 Pro'],
        'Xiaomi': ['Mi Watch S3', 'Redmi Watch 4'],
        'Oppo': ['Watch 3 Pro', 'Watch 3'],
        'Vivo': ['Watch 3', 'Watch 2'],
        'OnePlus': ['OnePlus Watch 2'],
        'Tesla': ['Model Watch', 'Cyber Watch'],
        'Microsoft': ['Surface Watch'],
      },
      '耳机': {
        'Apple': ['AirPods Pro 2', 'AirPods 3', 'AirPods Max'],
        'Samsung': ['Galaxy Buds2 Pro', 'Galaxy Buds2', 'Galaxy Buds Live'],
        'Google': ['Pixel Buds Pro', 'Pixel Buds A-Series'],
        'Huawei': ['FreeBuds Pro 3', 'FreeBuds 5i'],
        'Xiaomi': ['Mi Buds 4 Pro', 'Redmi Buds 5 Pro'],
        'Oppo': ['Enco X3', 'Enco Air3 Pro'],
        'Vivo': ['TWS 3 Pro', 'TWS 3'],
        'OnePlus': ['OnePlus Buds Pro 2'],
        'Tesla': ['Model Buds', 'Cyber Buds'],
        'Microsoft': ['Surface Earbuds'],
      },
      '家电': {
        'Apple': ['HomePod 2', 'HomePod mini'],
        'Samsung': ['SmartThings Hub', 'Smart TV'],
        'Google': ['Nest Hub Max', 'Nest Hub'],
        'Huawei': ['Sound X', 'Vision S'],
        'Xiaomi': ['Mi TV', 'Mi Speaker'],
        'Oppo': ['Smart TV', 'Smart Speaker'],
        'Vivo': ['Smart Display', 'Smart Speaker'],
        'OnePlus': ['OnePlus TV', 'OnePlus Speaker'],
        'Tesla': ['Model Home', 'Cyber Home'],
        'Microsoft': ['Surface Hub', 'Xbox'],
      },
      '游戏设备': {
        'Apple': ['Apple Arcade', 'Apple TV'],
        'Samsung': ['Gaming Monitor', 'Gaming Phone'],
        'Google': ['Stadia', 'Pixel Gaming'],
        'Microsoft': ['Xbox Series X', 'Xbox Series S', 'Surface Gaming'],
        'Huawei': ['Gaming Laptop', 'Gaming Phone'],
        'Xiaomi': ['Gaming Phone', 'Gaming Laptop'],
        'Oppo': ['Gaming Phone', 'Gaming Monitor'],
        'Vivo': ['Gaming Phone', 'Gaming Laptop'],
        'OnePlus': ['Gaming Phone', 'Gaming Monitor'],
        'Tesla': ['Model Gaming', 'Cyber Gaming'],
      },
    };

    return nameMap[category]?[company] ?? ['${company} ${category}'];
  }

  // 生成价格
  static double _generatePrice(String category) {
    final priceRanges = {
      '手机': [299, 1299],
      '笔记本电脑': [599, 2999],
      '汽车': [25000, 150000],
      '平板电脑': [199, 1299],
      '智能手表': [99, 799],
      '耳机': [29, 549],
      '家电': [49, 1999],
      '游戏设备': [199, 1999],
    };

    final range = priceRanges[category] ?? [99, 999];
    return _random.nextDouble() * (range[1] - range[0]) + range[0];
  }

  // 生成发布日期
  static DateTime _generateReleaseDate() {
    final now = DateTime.now();
    final daysAgo = _random.nextInt(365 * 3); // 过去3年内
    return now.subtract(Duration(days: daysAgo));
  }

  // 生成规格参数
  static Map<String, dynamic> _generateSpecs(String category) {
    final specs = <String, dynamic>{};

    switch (category) {
      case '手机':
        specs.addAll({
          '手机屏幕尺寸': '${5.5 + _random.nextDouble() * 2.5}',
          '手机分辨率': [
            '1080x2400',
            '1170x2532',
            '1284x2778',
            '1440x3200',
          ][_random.nextInt(4)],
          '手机处理器': [
            'A17 Pro',
            'A16 Bionic',
            'Snapdragon 8 Gen 3',
            'Exynos 2400',
          ][_random.nextInt(4)],
          '手机内存': [6, 8, 12, 16][_random.nextInt(4)],
          '手机存储': [64, 128, 256, 512, 1024][_random.nextInt(5)],
          '手机摄像头': '${12 + _random.nextInt(40)}MP',
          '手机电池容量': '${3000 + _random.nextInt(2000)}',
          '手机重量': '${150 + _random.nextInt(100)}',
          '手机防水等级': ['IP67', 'IP68'][_random.nextInt(2)],
          '手机操作系统': ['iOS 17', 'Android 14', 'HarmonyOS 4'][_random.nextInt(3)],
        });
        break;

      case '笔记本电脑':
        specs.addAll({
          '笔记本屏幕尺寸': '${13.3 + _random.nextDouble() * 4.7}',
          '笔记本分辨率': [
            '1920x1080',
            '2560x1440',
            '2880x1800',
            '3840x2160',
          ][_random.nextInt(4)],
          '笔记本处理器': [
            'M3 Pro',
            'M3',
            'Intel i7',
            'AMD Ryzen 7',
          ][_random.nextInt(4)],
          '笔记本内存': [8, 16, 32, 64][_random.nextInt(4)],
          '笔记本存储': [256, 512, 1024, 2048][_random.nextInt(4)],
          '显卡': [
            'M3 Pro GPU',
            'RTX 4060',
            'RTX 4070',
            'RTX 4080',
          ][_random.nextInt(4)],
          '电池续航': '${8 + _random.nextInt(12)}',
          '笔记本重量': '${1.2 + _random.nextDouble() * 1.8}',
          '接口': [
            'USB-C x2, USB-A x1',
            'Thunderbolt 4 x2',
            'HDMI, USB-C',
          ][_random.nextInt(3)],
          '笔记本操作系统': [
            'macOS Sonoma',
            'Windows 11',
            'Ubuntu 22.04',
          ][_random.nextInt(3)],
        });
        break;

      case '汽车':
        specs.addAll({
          '续航里程': '${300 + _random.nextInt(500)}',
          '加速时间': '${3.0 + _random.nextDouble() * 4.0}',
          '最高时速': '${180 + _random.nextInt(120)}',
          '汽车电池容量': '${60 + _random.nextInt(100)}',
          '充电时间': '${30 + _random.nextInt(60)}',
          '座位数': [2, 4, 5, 7][_random.nextInt(4)],
          '行李箱容积': '${300 + _random.nextInt(400)}',
          '自动驾驶': ['L2', 'L3', 'L4'][_random.nextInt(3)],
          '车身长度': '${4500 + _random.nextInt(1000)}',
        });
        break;

      case '平板电脑':
        specs.addAll({
          '笔记本屏幕尺寸': '${9.7 + _random.nextDouble() * 3.3}',
          '笔记本分辨率': ['2048x1536', '2388x1668', '2732x2048'][_random.nextInt(3)],
          '笔记本处理器': ['M2', 'A16 Bionic', 'A15 Bionic'][_random.nextInt(3)],
          '笔记本内存': [4, 8, 16][_random.nextInt(3)],
          '笔记本存储': [64, 128, 256, 512, 1024][_random.nextInt(5)],
          '电池续航': '${8 + _random.nextInt(8)}',
          '笔记本重量': '${0.4 + _random.nextDouble() * 0.6}',
          '接口': ['USB-C', 'Lightning', 'USB-C + 3.5mm'][_random.nextInt(3)],
          '笔记本操作系统': [
            'iPadOS 17',
            'Android 14',
            'Windows 11',
          ][_random.nextInt(3)],
        });
        break;

      case '智能手表':
        specs.addAll({
          '笔记本屏幕尺寸': '${1.2 + _random.nextDouble() * 0.8}',
          '笔记本分辨率': ['324x394', '396x484'][_random.nextInt(2)],
          '笔记本处理器': ['S9', 'S8', 'Wear OS'][_random.nextInt(3)],
          '笔记本内存': [1, 2, 4][_random.nextInt(3)],
          '笔记本存储': [16, 32, 64][_random.nextInt(3)],
          '电池续航': '${18 + _random.nextInt(30)}',
          '笔记本重量': '${30 + _random.nextInt(50)}',
          '接口': ['无线充电', '磁吸充电'][_random.nextInt(2)],
          '笔记本操作系统': [
            'watchOS 10',
            'Wear OS 4',
            'HarmonyOS',
          ][_random.nextInt(3)],
        });
        break;

      default:
        specs.addAll({'规格1': '值1', '规格2': '值2', '规格3': '值3'});
    }

    return specs;
  }

  // API端点模拟

  // 获取所有产品（同步方法）
  static List<Product> getAllProductsSync() {
    return List.from(_products);
  }

  // 获取所有产品（异步方法，带0.1秒延迟）
  static Future<List<Product>> getAllProducts() async {
    await _simulateNetworkDelay();
    return List.from(_products);
  }

  // 根据类别获取产品
  static Future<List<Product>> getProductsByCategory(String category) async {
    await _simulateNetworkDelay();
    return _products.where((p) => p.category == category).toList();
  }

  // 根据公司获取产品
  static Future<List<Product>> getProductsByCompany(String company) async {
    await _simulateNetworkDelay();
    return _products.where((p) => p.company == company).toList();
  }

  // 获取产品详情
  static Future<Product> getProductById(String id) async {
    await _simulateNetworkDelay();
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      throw Exception('Product not found');
    }
  }

  // 获取产品对比数据
  static Future<List<SpecComparison>> getProductComparison(
    List<String> productIds,
  ) async {
    await _simulateNetworkDelay();

    final selectedProducts = _products
        .where((p) => productIds.contains(p.id))
        .toList();
    if (selectedProducts.isEmpty) return [];

    final comparisons = <SpecComparison>[];

    // 获取所有产品的规格键
    final allSpecKeys = <String>{};
    for (final product in selectedProducts) {
      allSpecKeys.addAll(product.specs.keys);
    }

    // 为每个规格创建对比
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
        }
      }

      if (values.isNotEmpty) {
        final config = AppConfig.getSpecConfig(specKey);
        comparisons.add(
          SpecComparison(
            name: specKey,
            unit: config?.unit ?? '',
            values: values,
          ),
        );
      }
    }

    return comparisons;
  }

  // 获取图表数据
  static Future<ChartData> getChartData(
    String chartType,
    List<String> productIds,
  ) async {
    await _simulateNetworkDelay();

    final selectedProducts = _products
        .where((p) => productIds.contains(p.id))
        .toList();
    if (selectedProducts.isEmpty) {
      return ChartData(type: ChartType.bar, title: '无数据', items: []);
    }

    switch (chartType) {
      case 'price_comparison':
        return _generatePriceComparisonChart(selectedProducts);
      case 'performance_analysis':
        return _generatePerformanceChart(selectedProducts);
      case 'market_share':
        return _generateMarketShareChart(selectedProducts);
      case 'price_trend':
        return _generatePriceTrendChart(selectedProducts);
      default:
        return _generatePriceComparisonChart(selectedProducts);
    }
  }

  // 搜索产品
  static Future<List<Product>> searchProducts(String query) async {
    await _simulateNetworkDelay();

    final lowercaseQuery = query.toLowerCase();
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(lowercaseQuery) ||
              p.company.toLowerCase().contains(lowercaseQuery) ||
              p.category.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // 获取所有公司列表
  static Future<List<String>> getAllCompanies() async {
    await _simulateNetworkDelay();
    return AppConfig.supportedCompanies;
  }

  // 获取所有类别列表
  static Future<List<String>> getAllCategories() async {
    await _simulateNetworkDelay();
    return AppConfig.productCategories;
  }

  // 生成价格对比图表
  static ChartData _generatePriceComparisonChart(List<Product> products) {
    final items = products
        .map(
          (product) => ChartItem(
            label: product.name,
            value: product.price,
            color: AppConfig.getCompanyColor(product.company),
          ),
        )
        .toList();

    return ChartData(type: ChartType.bar, title: '价格对比', items: items);
  }

  // 生成性能分析图表
  static ChartData _generatePerformanceChart(List<Product> products) {
    final items = products.map((product) {
      // 基于价格和规格计算性能分数
      final performanceScore = _calculatePerformanceScore(product);
      return ChartItem(
        label: product.name,
        value: performanceScore,
        color: AppConfig.getCompanyColor(product.company),
      );
    }).toList();

    return ChartData(type: ChartType.radar, title: '性能分析', items: items);
  }

  // 生成市场份额图表
  static ChartData _generateMarketShareChart(List<Product> products) {
    final companyCount = <String, int>{};
    for (final product in products) {
      companyCount[product.company] = (companyCount[product.company] ?? 0) + 1;
    }

    final items = companyCount.entries
        .map(
          (entry) => ChartItem(
            label: entry.key,
            value: entry.value.toDouble(),
            color: AppConfig.getCompanyColor(entry.key),
          ),
        )
        .toList();

    return ChartData(
      type: ChartType.bar, // 暂时使用bar类型，后续可以添加pie类型
      title: '市场份额分布',
      items: items,
    );
  }

  // 生成价格趋势图表
  static ChartData _generatePriceTrendChart(List<Product> products) {
    final items = products
        .map(
          (product) => ChartItem(
            label: product.name,
            value: product.price,
            color: AppConfig.getCompanyColor(product.company),
          ),
        )
        .toList();

    return ChartData(type: ChartType.line, title: '价格趋势分析', items: items);
  }

  // 计算性能分数
  static double _calculatePerformanceScore(Product product) {
    double score = 0;

    // 基于价格计算基础分数 (价格越高，基础分数越高)
    score += (product.price / 1000) * 10;

    // 基于规格计算额外分数
    for (final spec in product.specs.entries) {
      if (spec.value is num) {
        score += (spec.value as num).toDouble() / 100;
      }
    }

    // 限制在0-100之间
    return (score % 100).clamp(0, 100);
  }

  // 模拟网络延迟 - 优化为0.1秒
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}
