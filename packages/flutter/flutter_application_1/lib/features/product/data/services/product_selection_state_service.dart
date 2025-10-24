/// 产品选择状态管理服务
class ProductSelectionStateService {
  static final ProductSelectionStateService _instance =
      ProductSelectionStateService._internal();
  factory ProductSelectionStateService() => _instance;
  ProductSelectionStateService._internal();

  final List<String> _selectedProductIds = [];
  String _comparisonMode = 'same_brand';

  /// 获取选中的产品ID列表
  List<String> get selectedProductIds => List.unmodifiable(_selectedProductIds);

  /// 获取选中产品数量
  int get selectedCount => _selectedProductIds.length;

  /// 获取对比模式
  String get comparisonMode => _comparisonMode;

  /// 检查是否可以开始对比
  bool get canStartComparison => _selectedProductIds.length >= 2;

  /// 添加产品ID
  void addProductId(String productId) {
    if (!_selectedProductIds.contains(productId)) {
      _selectedProductIds.add(productId);
    }
  }

  /// 移除产品ID
  void removeProductId(String productId) {
    _selectedProductIds.remove(productId);
  }

  /// 检查产品是否已选中
  bool isProductSelected(String productId) {
    return _selectedProductIds.contains(productId);
  }

  /// 设置对比模式
  void setComparisonMode(String mode) {
    _comparisonMode = mode;
  }

  /// 清除所有选择
  void clearSelection() {
    _selectedProductIds.clear();
  }

  /// 切换产品选择状态
  void toggleProduct(String productId) {
    if (_selectedProductIds.contains(productId)) {
      _selectedProductIds.remove(productId);
    } else {
      _selectedProductIds.add(productId);
    }
  }
}
