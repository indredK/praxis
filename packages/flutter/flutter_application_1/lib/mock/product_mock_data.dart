import '../models/product.dart';

/// 产品模拟数据
class ProductMockData {
  /// 模拟网络延迟
  static Future<void> simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// 获取所有产品数据（用于筛选）
  static Future<List<Product>> getProducts({
    String? comparisonMode,
    List<String>? brands,
    List<String>? categories,
    List<String>? productLines,
    List<String>? priceRanges,
    List<String>? colors,
    List<String>? features,
  }) async {
    await simulateNetworkDelay();

    // 获取所有产品
    var products = _getAllProducts();

    // 根据筛选条件过滤
    if (brands != null && brands.isNotEmpty) {
      products = products.where((p) => brands.contains(p.company)).toList();
    }

    if (categories != null && categories.isNotEmpty) {
      products = products
          .where((p) => categories.contains(p.category))
          .toList();
    }

    // 根据产品线筛选
    if (productLines != null && productLines.isNotEmpty) {
      products = products.where((p) {
        final line = p.specs['productLine'] as String?;
        return line != null && productLines.contains(line);
      }).toList();
    }

    // 根据价格区间筛选
    if (priceRanges != null && priceRanges.isNotEmpty) {
      products = products.where((p) {
        return priceRanges.any((range) => _isInPriceRange(p.price, range));
      }).toList();
    }

    // 根据颜色筛选
    if (colors != null && colors.isNotEmpty) {
      products = products.where((p) {
        final productColors = p.specs['colors'] as List<dynamic>?;
        if (productColors == null) return false;
        return colors.any((color) => productColors.contains(color));
      }).toList();
    }

    return products;
  }

  /// 根据产品 ID 列表获取产品
  static Future<List<Product>> getProductsByIds(List<String> ids) async {
    await simulateNetworkDelay();
    final allProducts = _getAllProducts();
    return allProducts.where((p) => ids.contains(p.id)).toList();
  }

  /// 获取单个产品
  static Future<Product?> getProductById(String id) async {
    await simulateNetworkDelay();
    final allProducts = _getAllProducts();
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 判断价格是否在指定区间
  static bool _isInPriceRange(double price, String range) {
    switch (range) {
      case '1000元以下':
        return price < 1000;
      case '1000-3000元':
        return price >= 1000 && price < 3000;
      case '3000-5000元':
        return price >= 3000 && price < 5000;
      case '5000-8000元':
        return price >= 5000 && price < 8000;
      case '8000-12000元':
        return price >= 8000 && price < 12000;
      case '12000元以上':
        return price >= 12000;
      default:
        return true;
    }
  }

  /// 获取所有产品（内部方法）
  static List<Product> _getAllProducts() {
    return [
      // Apple 产品
      Product(
        id: 'iphone_15_pro',
        name: 'iPhone 15 Pro',
        company: 'Apple',
        category: '手机',
        imageUrl: 'https://via.placeholder.com/300x300?text=iPhone+15+Pro',
        price: 7999,
        releaseDate: DateTime(2023, 9, 22),
        specs: {
          'productLine': '旗舰',
          'colors': ['黑色', '白色', '蓝色', '金色'],
          'screen': '6.1英寸',
          'processor': 'A17 Pro',
          'ram': '8GB',
          'storage': '256GB',
          'camera': '48MP主摄 + 12MP超广角 + 12MP长焦',
          'battery': '3274mAh',
          'features': ['防水', '无线', '快充', '高分辨率'],
        },
        description: 'Apple 最新旗舰手机，搭载 A17 Pro 芯片',
        specifications: {
          '屏幕尺寸': '6.1英寸',
          '处理器': 'A17 Pro',
          '内存': '8GB',
          '存储': '256GB',
          '相机': '48MP主摄',
          '电池': '3274mAh',
        },
      ),
      Product(
        id: 'iphone_15',
        name: 'iPhone 15',
        company: 'Apple',
        category: '手机',
        imageUrl: 'https://via.placeholder.com/300x300?text=iPhone+15',
        price: 5999,
        releaseDate: DateTime(2023, 9, 22),
        specs: {
          'productLine': '中端',
          'colors': ['黑色', '白色', '蓝色', '紫色', '红色'],
          'screen': '6.1英寸',
          'processor': 'A16 Bionic',
          'ram': '6GB',
          'storage': '128GB',
          'camera': '48MP主摄 + 12MP超广角',
          'battery': '3349mAh',
          'features': ['防水', '无线', '快充'],
        },
        description: 'iPhone 15 标准版，性能与价格的完美平衡',
        specifications: {
          '屏幕尺寸': '6.1英寸',
          '处理器': 'A16 Bionic',
          '内存': '6GB',
          '存储': '128GB',
          '相机': '48MP主摄',
          '电池': '3349mAh',
        },
      ),
      Product(
        id: 'macbook_pro_14',
        name: 'MacBook Pro 14"',
        company: 'Apple',
        category: '笔记本',
        imageUrl: 'https://via.placeholder.com/300x300?text=MacBook+Pro+14',
        price: 15999,
        releaseDate: DateTime(2023, 11, 7),
        specs: {
          'productLine': '专业级',
          'colors': ['银色', '黑色'],
          'screen': '14.2英寸',
          'processor': 'M3 Pro',
          'ram': '18GB',
          'storage': '512GB SSD',
          'graphics': '14核GPU',
          'battery': '70Wh',
          'features': ['高分辨率', '触屏', '背光'],
        },
        description: 'M3 Pro 芯片驱动的专业笔记本',
        specifications: {
          '屏幕尺寸': '14.2英寸',
          '处理器': 'M3 Pro',
          '内存': '18GB',
          '存储': '512GB SSD',
          '显卡': '14核GPU',
          '电池': '70Wh',
        },
      ),
      Product(
        id: 'macbook_air_13',
        name: 'MacBook Air 13"',
        company: 'Apple',
        category: '笔记本',
        imageUrl: 'https://via.placeholder.com/300x300?text=MacBook+Air+13',
        price: 8999,
        releaseDate: DateTime(2023, 6, 13),
        specs: {
          'productLine': '中端',
          'colors': ['银色', '金色', '黑色', '蓝色'],
          'screen': '13.6英寸',
          'processor': 'M2',
          'ram': '8GB',
          'storage': '256GB SSD',
          'graphics': '8核GPU',
          'battery': '52.6Wh',
          'features': ['高分辨率', '背光'],
        },
        description: '轻薄便携的日常使用笔记本',
        specifications: {
          '屏幕尺寸': '13.6英寸',
          '处理器': 'M2',
          '内存': '8GB',
          '存储': '256GB SSD',
          '显卡': '8核GPU',
          '电池': '52.6Wh',
        },
      ),

      // Samsung 产品
      Product(
        id: 'galaxy_s24_ultra',
        name: 'Galaxy S24 Ultra',
        company: 'Samsung',
        category: '手机',
        imageUrl: 'https://via.placeholder.com/300x300?text=Galaxy+S24+Ultra',
        price: 9999,
        releaseDate: DateTime(2024, 1, 17),
        specs: {
          'productLine': '旗舰',
          'colors': ['黑色', '紫色', '金色'],
          'screen': '6.8英寸',
          'processor': 'Snapdragon 8 Gen 3',
          'ram': '12GB',
          'storage': '256GB',
          'camera': '200MP主摄 + 50MP + 12MP + 10MP',
          'battery': '5000mAh',
          'features': ['防水', '无线', '快充', '高分辨率', 'RGB灯效'],
        },
        description: 'Samsung 最强旗舰手机',
        specifications: {
          '屏幕尺寸': '6.8英寸',
          '处理器': 'Snapdragon 8 Gen 3',
          '内存': '12GB',
          '存储': '256GB',
          '相机': '200MP主摄',
          '电池': '5000mAh',
        },
      ),
      Product(
        id: 'galaxy_s24',
        name: 'Galaxy S24',
        company: 'Samsung',
        category: '手机',
        imageUrl: 'https://via.placeholder.com/300x300?text=Galaxy+S24',
        price: 5999,
        releaseDate: DateTime(2024, 1, 17),
        specs: {
          'productLine': '中端',
          'colors': ['黑色', '白色', '紫色', '绿色'],
          'screen': '6.2英寸',
          'processor': 'Snapdragon 8 Gen 3',
          'ram': '8GB',
          'storage': '128GB',
          'camera': '50MP主摄 + 12MP超广角 + 10MP长焦',
          'battery': '4000mAh',
          'features': ['防水', '无线', '快充'],
        },
        description: 'Galaxy S24 标准版',
        specifications: {
          '屏幕尺寸': '6.2英寸',
          '处理器': 'Snapdragon 8 Gen 3',
          '内存': '8GB',
          '存储': '128GB',
          '相机': '50MP主摄',
          '电池': '4000mAh',
        },
      ),

      // Huawei 产品
      Product(
        id: 'mate_60_pro',
        name: 'Mate 60 Pro',
        company: 'Huawei',
        category: '手机',
        imageUrl: 'https://via.placeholder.com/300x300?text=Mate+60+Pro',
        price: 6999,
        releaseDate: DateTime(2023, 8, 29),
        specs: {
          'productLine': '旗舰',
          'colors': ['黑色', '白色', '紫色', '银色'],
          'screen': '6.82英寸',
          'processor': 'Kirin 9000S',
          'ram': '12GB',
          'storage': '512GB',
          'camera': '50MP主摄 + 12MP超广角 + 48MP潜望长焦',
          'battery': '5000mAh',
          'features': ['防水', '无线', '快充', '高分辨率'],
        },
        description: '华为旗舰手机，支持5G',
        specifications: {
          '屏幕尺寸': '6.82英寸',
          '处理器': 'Kirin 9000S',
          '内存': '12GB',
          '存储': '512GB',
          '相机': '50MP主摄',
          '电池': '5000mAh',
        },
      ),
      Product(
        id: 'matebook_x_pro',
        name: 'MateBook X Pro',
        company: 'Huawei',
        category: '笔记本',
        imageUrl: 'https://via.placeholder.com/300x300?text=MateBook+X+Pro',
        price: 8999,
        releaseDate: DateTime(2023, 9, 25),
        specs: {
          'productLine': '高端',
          'colors': ['银色', '黑色'],
          'screen': '14.2英寸',
          'processor': 'Intel Core i7-1360P',
          'ram': '16GB',
          'storage': '1TB SSD',
          'graphics': 'Intel Iris Xe',
          'battery': '60Wh',
          'features': ['触屏', '高分辨率', '背光'],
        },
        description: '华为高端商务笔记本',
        specifications: {
          '屏幕尺寸': '14.2英寸',
          '处理器': 'Intel Core i7-1360P',
          '内存': '16GB',
          '存储': '1TB SSD',
          '显卡': 'Intel Iris Xe',
          '电池': '60Wh',
        },
      ),

      // Xiaomi 产品
      Product(
        id: 'xiaomi_14_ultra',
        name: 'Xiaomi 14 Ultra',
        company: 'Xiaomi',
        category: '手机',
        imageUrl: 'https://via.placeholder.com/300x300?text=Xiaomi+14+Ultra',
        price: 5999,
        releaseDate: DateTime(2024, 2, 22),
        specs: {
          'productLine': '旗舰',
          'colors': ['黑色', '白色', '蓝色'],
          'screen': '6.73英寸',
          'processor': 'Snapdragon 8 Gen 3',
          'ram': '16GB',
          'storage': '512GB',
          'camera': '50MP主摄 + 50MP超广角 + 50MP长焦',
          'battery': '5000mAh',
          'features': ['防水', '无线', '快充', '高分辨率'],
        },
        description: '小米超大杯旗舰',
        specifications: {
          '屏幕尺寸': '6.73英寸',
          '处理器': 'Snapdragon 8 Gen 3',
          '内存': '16GB',
          '存储': '512GB',
          '相机': '50MP主摄',
          '电池': '5000mAh',
        },
      ),
      Product(
        id: 'redmi_note_13_pro',
        name: 'Redmi Note 13 Pro',
        company: 'Xiaomi',
        category: '手机',
        imageUrl: 'https://via.placeholder.com/300x300?text=Redmi+Note+13+Pro',
        price: 1799,
        releaseDate: DateTime(2023, 9, 21),
        specs: {
          'productLine': '经济型',
          'colors': ['黑色', '白色', '蓝色', '紫色'],
          'screen': '6.67英寸',
          'processor': 'Snapdragon 7s Gen 2',
          'ram': '8GB',
          'storage': '256GB',
          'camera': '200MP主摄 + 8MP超广角 + 2MP微距',
          'battery': '5000mAh',
          'features': ['快充'],
        },
        description: 'Redmi 性价比中端机',
        specifications: {
          '屏幕尺寸': '6.67英寸',
          '处理器': 'Snapdragon 7s Gen 2',
          '内存': '8GB',
          '存储': '256GB',
          '相机': '200MP主摄',
          '电池': '5000mAh',
        },
      ),

      // Dell 产品
      Product(
        id: 'xps_13',
        name: 'XPS 13',
        company: 'Dell',
        category: '笔记本',
        imageUrl: 'https://via.placeholder.com/300x300?text=Dell+XPS+13',
        price: 9999,
        releaseDate: DateTime(2023, 10, 3),
        specs: {
          'productLine': '高端',
          'colors': ['银色', '黑色'],
          'screen': '13.4英寸',
          'processor': 'Intel Core i7-1355U',
          'ram': '16GB',
          'storage': '512GB SSD',
          'graphics': 'Intel Iris Xe',
          'battery': '55Wh',
          'features': ['触屏', '高分辨率', '背光'],
        },
        description: 'Dell XPS 系列高端超极本',
        specifications: {
          '屏幕尺寸': '13.4英寸',
          '处理器': 'Intel Core i7-1355U',
          '内存': '16GB',
          '存储': '512GB SSD',
          '显卡': 'Intel Iris Xe',
          '电池': '55Wh',
        },
      ),
      Product(
        id: 'g15_gaming',
        name: 'G15 Gaming',
        company: 'Dell',
        category: '游戏本',
        imageUrl: 'https://via.placeholder.com/300x300?text=Dell+G15',
        price: 6999,
        releaseDate: DateTime(2023, 8, 15),
        specs: {
          'productLine': '游戏级',
          'colors': ['黑色'],
          'screen': '15.6英寸',
          'processor': 'Intel Core i7-13650HX',
          'ram': '16GB',
          'storage': '512GB SSD',
          'graphics': 'RTX 4060',
          'battery': '86Wh',
          'features': ['高分辨率', '背光', 'RGB灯效'],
        },
        description: 'Dell 游戏本，RTX 4060 显卡',
        specifications: {
          '屏幕尺寸': '15.6英寸',
          '处理器': 'Intel Core i7-13650HX',
          '内存': '16GB',
          '存储': '512GB SSD',
          '显卡': 'RTX 4060',
          '电池': '86Wh',
        },
      ),

      // HP 产品
      Product(
        id: 'pavilion_15',
        name: 'Pavilion 15',
        company: 'HP',
        category: '笔记本',
        imageUrl: 'https://via.placeholder.com/300x300?text=HP+Pavilion+15',
        price: 4999,
        releaseDate: DateTime(2023, 7, 12),
        specs: {
          'productLine': '中端',
          'colors': ['银色', '金色'],
          'screen': '15.6英寸',
          'processor': 'AMD Ryzen 5 7530U',
          'ram': '8GB',
          'storage': '512GB SSD',
          'graphics': 'AMD Radeon',
          'battery': '41Wh',
          'features': ['背光'],
        },
        description: 'HP Pavilion 系列日常办公本',
        specifications: {
          '屏幕尺寸': '15.6英寸',
          '处理器': 'AMD Ryzen 5 7530U',
          '内存': '8GB',
          '存储': '512GB SSD',
          '显卡': 'AMD Radeon',
          '电池': '41Wh',
        },
      ),
      Product(
        id: 'omen_16',
        name: 'OMEN 16',
        company: 'HP',
        category: '游戏本',
        imageUrl: 'https://via.placeholder.com/300x300?text=HP+OMEN+16',
        price: 8999,
        releaseDate: DateTime(2023, 9, 8),
        specs: {
          'productLine': '游戏级',
          'colors': ['黑色'],
          'screen': '16.1英寸',
          'processor': 'Intel Core i7-13700HX',
          'ram': '16GB',
          'storage': '1TB SSD',
          'graphics': 'RTX 4070',
          'battery': '83Wh',
          'features': ['高分辨率', '背光', 'RGB灯效'],
        },
        description: 'HP OMEN 游戏本，RTX 4070 显卡',
        specifications: {
          '屏幕尺寸': '16.1英寸',
          '处理器': 'Intel Core i7-13700HX',
          '内存': '16GB',
          '存储': '1TB SSD',
          '显卡': 'RTX 4070',
          '电池': '83Wh',
        },
      ),
    ];
  }
}
