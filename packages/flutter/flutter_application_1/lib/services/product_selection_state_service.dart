import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 产品选择状态管理服务
/// 用于持久化产品选择状态，支持在页面间切换时保持选择状态
class ProductSelectionStateService extends ChangeNotifier {
  static const String _keySelectedProductIds = 'selected_product_ids';
  static const String _keyComparisonMode = 'comparison_mode';
  static const String _keySelectedCompany = 'selected_company';
  static const String _keySelectedCategory = 'selected_category';
  static const String _keySelectedProduct = 'selected_product';
  static const String _keySelectedCategoryForComparison =
      'selected_category_for_comparison';
  static const String _keySelectedProductForComparison =
      'selected_product_for_comparison';

  // 选中的产品ID列表
  List<String> _selectedProductIds = [];

  // 对比模式：'same_brand' 自家对比, 'same_category' 同类对比
  String _comparisonMode = 'same_brand';

  // 自家对比模式的选择
  String _selectedCompany = '全部';
  String _selectedCategory = '全部';
  String _selectedProduct = '全部';

  // 同类对比模式的选择
  String _selectedCategoryForComparison = '全部';
  String _selectedProductForComparison = '全部';

  // 单例模式
  static final ProductSelectionStateService _instance =
      ProductSelectionStateService._internal();
  factory ProductSelectionStateService() => _instance;
  ProductSelectionStateService._internal();

  // Getters
  List<String> get selectedProductIds => List.unmodifiable(_selectedProductIds);
  String get comparisonMode => _comparisonMode;
  String get selectedCompany => _selectedCompany;
  String get selectedCategory => _selectedCategory;
  String get selectedProduct => _selectedProduct;
  String get selectedCategoryForComparison => _selectedCategoryForComparison;
  String get selectedProductForComparison => _selectedProductForComparison;

  /// 初始化服务，从本地存储加载状态
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载选中的产品ID
      final productIdsJson = prefs.getString(_keySelectedProductIds);
      if (productIdsJson != null) {
        final List<dynamic> productIdsList = json.decode(productIdsJson);
        _selectedProductIds = productIdsList.cast<String>();
      }

      // 加载对比模式
      _comparisonMode = prefs.getString(_keyComparisonMode) ?? 'same_brand';

      // 加载自家对比模式的选择
      _selectedCompany = prefs.getString(_keySelectedCompany) ?? '全部';
      _selectedCategory = prefs.getString(_keySelectedCategory) ?? '全部';
      _selectedProduct = prefs.getString(_keySelectedProduct) ?? '全部';

      // 加载同类对比模式的选择
      _selectedCategoryForComparison =
          prefs.getString(_keySelectedCategoryForComparison) ?? '全部';
      _selectedProductForComparison =
          prefs.getString(_keySelectedProductForComparison) ?? '全部';

      print('✅ 产品选择状态加载完成: ${_selectedProductIds.length}个产品');
    } catch (e) {
      print('❌ 加载产品选择状态失败: $e');
    }
  }

  /// 设置选中的产品ID列表
  void setSelectedProductIds(List<String> productIds) {
    _selectedProductIds = List.from(productIds);
    _saveToStorage();
    notifyListeners();
  }

  /// 添加产品ID到选择列表
  void addProductId(String productId) {
    if (!_selectedProductIds.contains(productId)) {
      _selectedProductIds.add(productId);
      _saveToStorage();
      notifyListeners();
    }
  }

  /// 从选择列表中移除产品ID
  void removeProductId(String productId) {
    if (_selectedProductIds.remove(productId)) {
      _saveToStorage();
      notifyListeners();
    }
  }

  /// 清空所有选择
  void clearAll() {
    _selectedProductIds.clear();
    _saveToStorage();
    notifyListeners();
  }

  /// 设置对比模式
  void setComparisonMode(String mode) {
    if (_comparisonMode != mode) {
      _comparisonMode = mode;
      _saveToStorage();
      notifyListeners();
    }
  }

  /// 设置自家对比模式的选择
  void setSameBrandSelections({
    String? company,
    String? category,
    String? product,
  }) {
    bool changed = false;

    if (company != null && _selectedCompany != company) {
      _selectedCompany = company;
      changed = true;
    }

    if (category != null && _selectedCategory != category) {
      _selectedCategory = category;
      changed = true;
    }

    if (product != null && _selectedProduct != product) {
      _selectedProduct = product;
      changed = true;
    }

    if (changed) {
      _saveToStorage();
      notifyListeners();
    }
  }

  /// 设置同类对比模式的选择
  void setSameCategorySelections({String? category, String? product}) {
    bool changed = false;

    if (category != null && _selectedCategoryForComparison != category) {
      _selectedCategoryForComparison = category;
      changed = true;
    }

    if (product != null && _selectedProductForComparison != product) {
      _selectedProductForComparison = product;
      changed = true;
    }

    if (changed) {
      _saveToStorage();
      notifyListeners();
    }
  }

  /// 检查产品是否已选中
  bool isProductSelected(String productId) {
    return _selectedProductIds.contains(productId);
  }

  /// 获取选中产品的数量
  int get selectedCount => _selectedProductIds.length;

  /// 检查是否可以开始对比（至少2个产品）
  bool get canStartComparison => _selectedProductIds.length >= 2;

  /// 保存状态到本地存储
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存选中的产品ID
      await prefs.setString(
        _keySelectedProductIds,
        json.encode(_selectedProductIds),
      );

      // 保存对比模式
      await prefs.setString(_keyComparisonMode, _comparisonMode);

      // 保存自家对比模式的选择
      await prefs.setString(_keySelectedCompany, _selectedCompany);
      await prefs.setString(_keySelectedCategory, _selectedCategory);
      await prefs.setString(_keySelectedProduct, _selectedProduct);

      // 保存同类对比模式的选择
      await prefs.setString(
        _keySelectedCategoryForComparison,
        _selectedCategoryForComparison,
      );
      await prefs.setString(
        _keySelectedProductForComparison,
        _selectedProductForComparison,
      );

      print('✅ 产品选择状态已保存');
    } catch (e) {
      print('❌ 保存产品选择状态失败: $e');
    }
  }

  /// 重置所有状态到默认值
  Future<void> reset() async {
    _selectedProductIds.clear();
    _comparisonMode = 'same_brand';
    _selectedCompany = '全部';
    _selectedCategory = '全部';
    _selectedProduct = '全部';
    _selectedCategoryForComparison = '全部';
    _selectedProductForComparison = '全部';

    await _saveToStorage();
    notifyListeners();
  }

  /// 获取状态摘要（用于调试）
  Map<String, dynamic> getStateSummary() {
    return {
      'selectedProductIds': _selectedProductIds,
      'comparisonMode': _comparisonMode,
      'selectedCompany': _selectedCompany,
      'selectedCategory': _selectedCategory,
      'selectedProduct': _selectedProduct,
      'selectedCategoryForComparison': _selectedCategoryForComparison,
      'selectedProductForComparison': _selectedProductForComparison,
      'selectedCount': _selectedProductIds.length,
      'canStartComparison': canStartComparison,
    };
  }
}
