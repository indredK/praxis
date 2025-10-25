import '../../domain/models/product.dart' as models;
import 'product_api_service.dart';

/// 数据服务 - 提供产品数据访问（统一使用ProductApiService）
class DataService {
  static final _api = ProductApiService.instance;

  /// 获取所有产品
  static Future<List<models.Product>> getAllProducts() async {
    return await _api.getProducts(limit: 100);
  }

  /// 根据ID获取产品
  static Future<models.Product?> getProductById(String id) async {
    return await _api.getProductById(id);
  }

  /// 根据产品ID列表获取产品
  static Future<List<models.Product>> getProductsByIds(List<String> ids) async {
    return await _api.getProductsByIds(ids);
  }

  /// 搜索产品
  static Future<List<models.Product>> searchProducts(String query) async {
    return await _api.searchProducts(query, limit: 50);
  }

  /// 根据类别获取产品
  static Future<List<models.Product>> getProductsByCategory(
    String category,
  ) async {
    return await _api.getProducts(categories: [category], limit: 50);
  }

  /// 根据公司获取产品
  static Future<List<models.Product>> getProductsByCompany(
    String company,
  ) async {
    return await _api.getProducts(brands: [company], limit: 50);
  }

  /// 根据筛选条件获取产品
  static Future<List<models.Product>> getProductsWithFilters({
    List<String>? brands,
    List<String>? categories,
    List<String>? productLines,
    List<String>? priceRanges,
    List<String>? colors,
    List<String>? features,
  }) async {
    return await _api.getProducts(
      brands: brands,
      categories: categories,
      productLines: productLines,
      priceRanges: priceRanges,
      colors: colors,
      features: features,
    );
  }

  /// 获取产品对比数据
  /// 从产品的 specifications 字段自动生成规格对比数据
  static Future<List<models.SpecComparison>> getProductComparison(
    List<String> productIds,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 获取产品数据
    final products = await getProductsByIds(productIds);
    if (products.isEmpty) {
      return [];
    }

    // 收集所有规格参数名称（使用Set去重）
    final Set<String> allSpecNames = {};
    for (final product in products) {
      allSpecNames.addAll(product.specifications.keys);
    }

    // 按照一定的顺序排列规格参数（可以根据需要调整）
    final specOrder = [
      '屏幕尺寸',
      '分辨率',
      '处理器',
      '内存',
      '存储',
      '显卡',
      '主摄像头',
      '超广角',
      '长焦',
      '前置摄像头',
      '电池容量',
      '电池续航',
      '充电功率',
      '重量',
      '厚度',
      '防水等级',
      '操作系统',
      '屏幕刷新率',
      '峰值亮度',
      '显示技术',
      '接口',
      '音频',
      '摄像头',
      '传感器',
      '连接',
      '芯片',
      '降噪',
      '通透模式',
      '空间音频',
      '自适应音频',
      '续航时间',
      '充电盒续航',
      '充电接口',
      '充电盒重量',
      '特殊功能',
      '驱动单元',
      '材质',
    ];

    // 按顺序生成规格对比数据
    final List<models.SpecComparison> comparisons = [];

    // 先添加有序的规格
    for (final specName in specOrder) {
      if (allSpecNames.contains(specName)) {
        final comparison = _createSpecComparison(specName, products);
        if (comparison != null) {
          comparisons.add(comparison);
        }
        allSpecNames.remove(specName);
      }
    }

    // 再添加其他未排序的规格
    for (final specName in allSpecNames) {
      final comparison = _createSpecComparison(specName, products);
      if (comparison != null) {
        comparisons.add(comparison);
      }
    }

    return comparisons;
  }

  /// 创建单个规格对比项
  static models.SpecComparison? _createSpecComparison(
    String specName,
    List<models.Product> products,
  ) {
    final values = <models.SpecValue>[];

    for (final product in products) {
      final specValue = product.specifications[specName];
      if (specValue != null) {
        values.add(
          models.SpecValue(
            productId: product.id,
            productName: product.name,
            value: _extractNumericValue(specValue),
            displayValue: specValue,
          ),
        );
      } else {
        // 如果该产品没有这个规格，添加 N/A
        values.add(
          models.SpecValue(
            productId: product.id,
            productName: product.name,
            value: null,
            displayValue: 'N/A',
          ),
        );
      }
    }

    // 如果所有产品都没有这个规格，则不创建对比项
    if (values.every((v) => v.displayValue == 'N/A')) {
      return null;
    }

    return models.SpecComparison(
      name: specName,
      unit: '', // 单位已包含在displayValue中
      values: values,
    );
  }

  /// 从规格值中提取数字（用于百分比计算）
  /// 例如："8GB" -> 8, "6.1英寸" -> 6.1, "3274mAh" -> 3274
  static dynamic _extractNumericValue(String value) {
    if (value == 'N/A' || value.isEmpty) {
      return null;
    }

    // 尝试提取第一个数字
    final match = RegExp(r'[\d.]+').firstMatch(value);
    if (match != null) {
      final numStr = match.group(0)!;
      // 尝试转换为数字
      final num = double.tryParse(numStr);
      return num;
    }

    return null;
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
