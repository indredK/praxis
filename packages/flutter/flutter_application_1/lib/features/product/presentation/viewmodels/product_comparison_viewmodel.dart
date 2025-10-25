import 'package:flutter/foundation.dart';
import '../../domain/models/product.dart' as models;
import '../../data/services/data_service.dart';
import '../../data/services/global_data_cache.dart';
import '../../domain/models/advanced_filter_models.dart';

/// 产品对比页面的 ViewModel
/// 负责管理对比页面的所有业务逻辑和状态
class ProductComparisonViewModel extends ChangeNotifier {
  // ============ 私有状态 ============

  // 所有产品数据
  List<models.Product> _allProducts = [];

  // 当前显示的产品列表（经过筛选后）
  List<models.Product> _displayedProducts = [];

  // 产品ID列表
  List<String> _productIds = [];

  // 基准对比索引
  int _baselineIndex = 0;

  // 筛选器状态
  AdvancedFilterSelection _filterSelection = const AdvancedFilterSelection();

  // 缓存的对比数据
  List<models.SpecComparison>? _cachedComparisons;

  // 加载状态
  bool _isLoading = true;

  // 错误信息
  String? _errorMessage;

  // 滚动偏移量（用于吸顶效果）
  double _scrollOffset = 0.0;
  bool _isSticky = false;

  // ============ Getters ============

  List<models.Product> get allProducts => List.unmodifiable(_allProducts);
  List<models.Product> get displayedProducts =>
      List.unmodifiable(_displayedProducts);
  List<String> get productIds => List.unmodifiable(_productIds);
  int get baselineIndex => _baselineIndex;
  AdvancedFilterSelection get filterSelection => _filterSelection;
  List<models.SpecComparison>? get cachedComparisons => _cachedComparisons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get scrollOffset => _scrollOffset;
  bool get isSticky => _isSticky;

  int get productCount => _displayedProducts.length;
  bool get hasProducts => _displayedProducts.isNotEmpty;
  bool get hasComparisons =>
      _cachedComparisons != null && _cachedComparisons!.isNotEmpty;

  // ============ 初始化方法 ============

  /// 初始化并加载产品数据
  Future<void> initialize(List<String> productIds) async {
    _productIds = productIds;
    await loadProducts();
  }

  /// 加载产品数据
  Future<void> loadProducts() async {
    _isLoading = false; // 立即显示，无加载状态
    notifyListeners();

    try {
      // 优先使用全局缓存
      List<models.Product> products;
      if (GlobalDataCache.getProducts() != null) {
        products = GlobalDataCache.getProducts()!;
      } else {
        final dataServiceProducts = await DataService.getAllProducts();
        products = dataServiceProducts.cast<models.Product>();
      }

      // 边界检查
      if (products.isEmpty) {
        _errorMessage = '没有可用的产品数据';
        notifyListeners();
        return;
      }

      // 限制产品ID数量
      final limitedProductIds = _productIds.take(15).toList();

      _allProducts = products
          .where((product) => limitedProductIds.contains(product.id))
          .toList();

      _displayedProducts = _allProducts;

      // 异步预加载对比数据
      _preloadComparisonData();

      // 检查是否找到产品
      if (_allProducts.isEmpty && limitedProductIds.isNotEmpty) {
        _errorMessage = '未找到选中的产品，请重新选择';
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = '加载产品数据失败: ${e.toString()}';
      notifyListeners();
    }
  }

  /// 预加载对比数据
  Future<void> _preloadComparisonData() async {
    if (_displayedProducts.isEmpty || _cachedComparisons != null) return;

    try {
      final comparisons = await DataService.getProductComparison(
        _displayedProducts.map((p) => p.id).toList(),
      );

      _cachedComparisons = comparisons;
      notifyListeners();
    } catch (e) {
      debugPrint('预加载对比数据失败: $e');
    }
  }

  // ============ 筛选和排序方法 ============

  /// 应用筛选器
  void applyFilter(AdvancedFilterSelection selection) {
    _filterSelection = selection;
    _displayedProducts = _filterProducts(_allProducts, selection);

    // 清除缓存的对比数据，需要重新加载
    _cachedComparisons = null;
    _preloadComparisonData();

    notifyListeners();
  }

  /// 筛选产品列表
  List<models.Product> _filterProducts(
    List<models.Product> products,
    AdvancedFilterSelection selection,
  ) {
    if (!selection.hasSelections) {
      return products;
    }

    List<models.Product> filtered = products;

    // 根据品牌筛选
    final brands = selection.getFilterSelection('brand');
    if (brands.isNotEmpty) {
      filtered = filtered
          .where((product) => brands.contains(product.company))
          .toList();
    }

    // 根据类别筛选
    final categories = selection.getFilterSelection('category');
    if (categories.isNotEmpty) {
      filtered = filtered
          .where((product) => categories.contains(product.category))
          .toList();
    }

    // 根据价格区间筛选
    final priceRanges = selection.getFilterSelection('price');
    if (priceRanges.isNotEmpty) {
      filtered = filtered.where((product) {
        return priceRanges.any(
          (range) => _isInPriceRange(product.price, range),
        );
      }).toList();
    }

    return filtered;
  }

  /// 判断价格是否在指定区间
  bool _isInPriceRange(double price, String range) {
    switch (range) {
      case '0-1000':
        return price <= 1000;
      case '1000-3000':
        return price > 1000 && price <= 3000;
      case '3000-5000':
        return price > 3000 && price <= 5000;
      case '5000-10000':
        return price > 5000 && price <= 10000;
      case '10000+':
        return price > 10000;
      default:
        return true;
    }
  }

  /// 清除筛选器
  void clearFilter() {
    _filterSelection = const AdvancedFilterSelection();
    _displayedProducts = _allProducts;

    // 恢复缓存的对比数据
    _cachedComparisons = null;
    _preloadComparisonData();

    notifyListeners();
  }

  // ============ 基准对比方法 ============

  /// 切换基准产品
  void switchBaseline(int newBaselineIndex) {
    if (newBaselineIndex == _baselineIndex) return;
    if (newBaselineIndex < 0 || newBaselineIndex >= _displayedProducts.length)
      return;

    _baselineIndex = newBaselineIndex;
    notifyListeners();
  }

  /// 获取基准产品
  models.Product? get baselineProduct {
    if (_baselineIndex < 0 || _baselineIndex >= _displayedProducts.length) {
      return null;
    }
    return _displayedProducts[_baselineIndex];
  }

  // ============ 百分比计算方法 ============

  /// 计算百分比差异
  String? calculatePercentage(dynamic baselineValue, dynamic currentValue) {
    try {
      double baseline = 0;
      double current = 0;

      if (baselineValue is num) {
        baseline = baselineValue.toDouble();
      } else if (baselineValue is String) {
        baseline =
            double.tryParse(baselineValue.replaceAll(RegExp(r'[^\d.]'), '')) ??
            0;
      }

      if (currentValue is num) {
        current = currentValue.toDouble();
      } else if (currentValue is String) {
        current =
            double.tryParse(currentValue.replaceAll(RegExp(r'[^\d.]'), '')) ??
            0;
      }

      if (baseline == 0) return null;

      final percentage = ((current - baseline) / baseline * 100);
      if (percentage > 0) {
        return '+${percentage.toStringAsFixed(1)}%';
      } else if (percentage < 0) {
        return '${percentage.toStringAsFixed(1)}%';
      } else {
        return '0%';
      }
    } catch (e) {
      return null;
    }
  }

  // ============ 滚动状态管理 ============

  /// 更新滚动偏移量
  void updateScrollOffset(double offset) {
    _scrollOffset = offset;
    final shouldBeSticky = offset > 200; // 滚动200px后开始吸顶

    if (shouldBeSticky != _isSticky) {
      _isSticky = shouldBeSticky;
    }

    notifyListeners();
  }

  // ============ 清理方法 ============

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 重置所有状态
  void reset() {
    _allProducts = [];
    _displayedProducts = [];
    _productIds = [];
    _baselineIndex = 0;
    _filterSelection = const AdvancedFilterSelection();
    _cachedComparisons = null;
    _isLoading = true;
    _errorMessage = null;
    _scrollOffset = 0.0;
    _isSticky = false;
    notifyListeners();
  }
}
