import 'package:flutter/material.dart';
import '../../domain/models/advanced_filter_models.dart';
import 'filter_api_service.dart';

/// 高级筛选器服务
class AdvancedFilterService {
  static AdvancedFilterService? _instance;
  static AdvancedFilterService get instance =>
      _instance ??= AdvancedFilterService._();

  AdvancedFilterService._();

  FilterTreeConfig? _config;
  AdvancedFilterSelection _currentSelection = const AdvancedFilterSelection();
  final FilterApiService _apiService = FilterApiService.instance;

  /// 获取筛选器配置
  FilterTreeConfig? get config => _config;

  /// 获取当前选择状态
  AdvancedFilterSelection get currentSelection => _currentSelection;

  /// 加载筛选器配置
  Future<void> loadConfig() async {
    try {
      _config = await _apiService.getFilterConfig();
    } catch (e) {
      debugPrint('Failed to load filter config: $e');
      // 使用默认配置
      _config = _getDefaultConfig();
    }
  }

  /// 获取默认配置
  FilterTreeConfig _getDefaultConfig() {
    return FilterTreeConfig(
      root: FilterNode(
        id: 'root',
        title: '产品筛选',
        children: [
          FilterNode(
            id: 'brand_filter',
            title: '品牌筛选',
            type: FilterType.multiSelect,
            children: [
              FilterNode(
                id: 'apple',
                title: 'Apple',
                value: 'Apple',
                icon: '🍎',
              ),
              FilterNode(
                id: 'samsung',
                title: 'Samsung',
                value: 'Samsung',
                icon: '📱',
              ),
              FilterNode(id: 'dell', title: 'Dell', value: 'Dell', icon: '💻'),
              FilterNode(id: 'hp', title: 'HP', value: 'HP', icon: '🖥️'),
            ],
          ),
          FilterNode(
            id: 'category_filter',
            title: '类别筛选',
            type: FilterType.singleSelect,
            children: [
              FilterNode(id: 'phone', title: '手机', value: '手机', icon: '📱'),
              FilterNode(id: 'laptop', title: '笔记本', value: '笔记本', icon: '💻'),
              FilterNode(id: 'tablet', title: '平板', value: '平板', icon: '📱'),
              FilterNode(
                id: 'desktop',
                title: '台式机',
                value: '台式机',
                icon: '🖥️',
              ),
            ],
          ),
          FilterNode(
            id: 'product_line_filter',
            title: '产品线',
            type: FilterType.multiSelect,
            children: [
              FilterNode(id: 'flagship', title: '旗舰', value: '旗舰', icon: '⭐'),
              FilterNode(id: 'mid_range', title: '中端', value: '中端', icon: '🔸'),
              FilterNode(
                id: 'entry_level',
                title: '入门',
                value: '入门',
                icon: '🔹',
              ),
            ],
          ),
        ],
      ),
      comparisonModes: {
        'same_brand': FilterModeConfig(
          title: '自家对比',
          enabledFilters: ['category_filter', 'product_line_filter'],
        ),
        'same_category': FilterModeConfig(
          title: '同类对比',
          enabledFilters: ['brand_filter', 'product_line_filter'],
        ),
      },
    );
  }

  /// 获取指定对比模式的配置
  FilterModeConfig? getComparisonModeConfig(String mode) {
    return _config?.comparisonModes[mode];
  }

  /// 获取当前对比模式启用的筛选器
  List<FilterNode> getEnabledFilters(String comparisonMode) {
    final modeConfig = getComparisonModeConfig(comparisonMode);
    if (modeConfig == null) return [];

    return _config?.root.children
            .where((filter) => modeConfig.enabledFilters.contains(filter.id))
            .toList() ??
        [];
  }

  /// 异步获取当前对比模式启用的筛选器
  Future<List<FilterNode>> getEnabledFiltersAsync(String comparisonMode) async {
    try {
      return await _apiService.getEnabledFilters(comparisonMode);
    } catch (e) {
      debugPrint('Failed to get enabled filters: $e');
      return getEnabledFilters(comparisonMode);
    }
  }

  /// 更新选择状态
  void updateSelection(AdvancedFilterSelection selection) {
    _currentSelection = selection;
  }

  /// 设置对比模式
  void setComparisonMode(String mode) {
    _currentSelection = _currentSelection.copyWith(comparisonMode: mode);
  }

  /// 切换筛选器选择
  void toggleFilterSelection(String filterId, String value) {
    _currentSelection = _currentSelection.toggleFilterSelection(
      filterId,
      value,
    );
  }

  /// 设置筛选器选择
  void setFilterSelection(String filterId, List<String> values) {
    _currentSelection = _currentSelection.setFilterSelection(filterId, values);
  }

  /// 清空所有选择
  void clearAllSelections() {
    _currentSelection = _currentSelection.clearAll();
  }

  /// 获取筛选器节点
  FilterNode? getFilterNode(String filterId) {
    return _findFilterNode(_config?.root, filterId);
  }

  /// 递归查找筛选器节点
  FilterNode? _findFilterNode(FilterNode? node, String filterId) {
    if (node == null) return null;
    if (node.id == filterId) return node;

    for (final child in node.children) {
      final found = _findFilterNode(child, filterId);
      if (found != null) return found;
    }
    return null;
  }

  /// 检查筛选器是否支持多选
  bool isMultiSelect(String filterId) {
    final node = getFilterNode(filterId);
    return node?.type == FilterType.multiSelect;
  }

  /// 获取筛选器的选择值
  List<String> getFilterSelection(String filterId) {
    return _currentSelection.getFilterSelection(filterId);
  }

  /// 检查筛选器是否有选择
  bool hasFilterSelection(String filterId) {
    return getFilterSelection(filterId).isNotEmpty;
  }

  /// 获取所有选择的数量
  int getTotalSelections() {
    return _currentSelection.totalSelections;
  }

  /// 检查是否有任何选择
  bool get hasAnySelections => _currentSelection.hasSelections;
}
