/// 筛选器类型枚举
enum FilterType { singleSelect, multiSelect, range, date }

/// 解析筛选器类型
FilterType _parseFilterType(String? type) {
  switch (type) {
    case 'single_select':
      return FilterType.singleSelect;
    case 'multi_select':
      return FilterType.multiSelect;
    case 'range':
      return FilterType.range;
    case 'date':
      return FilterType.date;
    default:
      return FilterType.singleSelect;
  }
}

/// 筛选器节点模型
class FilterNode {
  final String id;
  final String title;
  final String? value;
  final String? icon;
  final FilterType type;
  final bool enabled;
  final List<FilterNode> children;
  final Map<String, dynamic>? metadata;

  const FilterNode({
    required this.id,
    required this.title,
    this.value,
    this.icon,
    this.type = FilterType.singleSelect,
    this.enabled = true,
    this.children = const [],
    this.metadata,
  });

  factory FilterNode.fromJson(Map<String, dynamic> json) {
    return FilterNode(
      id: json['id'],
      title: json['title'],
      value: json['value'],
      icon: json['icon'],
      type: _parseFilterType(json['type']),
      enabled: json['enabled'] ?? true,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((child) => FilterNode.fromJson(child))
              .toList() ??
          [],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'icon': icon,
      'type': type.name,
      'enabled': enabled,
      'children': children.map((child) => child.toJson()).toList(),
      'metadata': metadata,
    };
  }

  FilterNode copyWith({
    String? id,
    String? title,
    String? value,
    String? icon,
    FilterType? type,
    bool? enabled,
    List<FilterNode>? children,
    Map<String, dynamic>? metadata,
  }) {
    return FilterNode(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      children: children ?? this.children,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 筛选器树配置
class FilterTreeConfig {
  final FilterNode root;
  final Map<String, FilterModeConfig> comparisonModes;

  const FilterTreeConfig({required this.root, required this.comparisonModes});

  factory FilterTreeConfig.fromJson(Map<String, dynamic> json) {
    return FilterTreeConfig(
      root: FilterNode.fromJson(json['filterTree']),
      comparisonModes: (json['comparisonModes'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, FilterModeConfig.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filterTree': root.toJson(),
      'comparisonModes': comparisonModes.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

/// 对比模式配置
class FilterModeConfig {
  final String title;
  final List<String> enabledFilters;

  const FilterModeConfig({required this.title, required this.enabledFilters});

  factory FilterModeConfig.fromJson(Map<String, dynamic> json) {
    return FilterModeConfig(
      title: json['title'],
      enabledFilters: List<String>.from(json['enabledFilters']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'enabledFilters': enabledFilters};
  }
}

/// 筛选器选择状态
class AdvancedFilterSelection {
  final Map<String, List<String>> selections;
  final String comparisonMode;

  const AdvancedFilterSelection({
    this.selections = const {},
    this.comparisonMode = 'same_brand',
  });

  AdvancedFilterSelection copyWith({
    Map<String, List<String>>? selections,
    String? comparisonMode,
  }) {
    return AdvancedFilterSelection(
      selections: selections ?? this.selections,
      comparisonMode: comparisonMode ?? this.comparisonMode,
    );
  }

  /// 获取指定筛选器的选择值
  List<String> getFilterSelection(String filterId) {
    return selections[filterId] ?? [];
  }

  /// 设置筛选器选择
  AdvancedFilterSelection setFilterSelection(
    String filterId,
    List<String> values,
  ) {
    final newSelections = Map<String, List<String>>.from(selections);
    if (values.isEmpty) {
      newSelections.remove(filterId);
    } else {
      newSelections[filterId] = values;
    }
    return copyWith(selections: newSelections);
  }

  /// 添加筛选器选择
  AdvancedFilterSelection addFilterSelection(String filterId, String value) {
    final currentValues = getFilterSelection(filterId);
    if (!currentValues.contains(value)) {
      return setFilterSelection(filterId, [...currentValues, value]);
    }
    return this;
  }

  /// 移除筛选器选择
  AdvancedFilterSelection removeFilterSelection(String filterId, String value) {
    final currentValues = getFilterSelection(filterId);
    return setFilterSelection(
      filterId,
      currentValues.where((v) => v != value).toList(),
    );
  }

  /// 切换筛选器选择
  AdvancedFilterSelection toggleFilterSelection(String filterId, String value) {
    final currentValues = getFilterSelection(filterId);
    if (currentValues.contains(value)) {
      return removeFilterSelection(filterId, value);
    } else {
      return addFilterSelection(filterId, value);
    }
  }

  /// 检查是否有任何选择
  bool get hasSelections => selections.isNotEmpty;

  /// 获取所有选择的数量
  int get totalSelections {
    return selections.values.fold(0, (sum, values) => sum + values.length);
  }

  /// 清空所有选择
  AdvancedFilterSelection clearAll() {
    return copyWith(selections: {});
  }

  @override
  String toString() {
    return 'AdvancedFilterSelection(selections: $selections, comparisonMode: $comparisonMode)';
  }
}
