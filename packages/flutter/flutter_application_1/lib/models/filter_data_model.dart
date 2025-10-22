/// 后端筛选器数据模型
class FilterDataModel {
  final String id;
  final String name;
  final String displayName;
  final String? parentId;
  final int level;
  final bool isLeaf;
  final bool isDefault;
  final Map<String, dynamic>? metadata;
  final List<FilterDataModel> children;

  const FilterDataModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.parentId,
    required this.level,
    required this.isLeaf,
    this.isDefault = false,
    this.metadata,
    this.children = const [],
  });

  /// 从JSON创建实例
  factory FilterDataModel.fromJson(Map<String, dynamic> json) {
    return FilterDataModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      parentId: json['parentId'] as String?,
      level: json['level'] as int,
      isLeaf: json['isLeaf'] as bool,
      isDefault: json['isDefault'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      children:
          (json['children'] as List<dynamic>?)
              ?.map(
                (child) =>
                    FilterDataModel.fromJson(child as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'parentId': parentId,
      'level': level,
      'isLeaf': isLeaf,
      'isDefault': isDefault,
      'metadata': metadata,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  /// 复制并修改属性
  FilterDataModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? parentId,
    int? level,
    bool? isLeaf,
    bool? isDefault,
    Map<String, dynamic>? metadata,
    List<FilterDataModel>? children,
  }) {
    return FilterDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      isLeaf: isLeaf ?? this.isLeaf,
      isDefault: isDefault ?? this.isDefault,
      metadata: metadata ?? this.metadata,
      children: children ?? this.children,
    );
  }

  @override
  String toString() {
    return 'FilterDataModel(id: $id, name: $name, displayName: $displayName, level: $level, isLeaf: $isLeaf)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterDataModel &&
        other.id == id &&
        other.name == name &&
        other.displayName == displayName &&
        other.parentId == parentId &&
        other.level == level &&
        other.isLeaf == isLeaf &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        displayName.hashCode ^
        parentId.hashCode ^
        level.hashCode ^
        isLeaf.hashCode ^
        isDefault.hashCode;
  }
}

/// 筛选器组数据模型（用于组织多个筛选器树）
class FilterGroupModel {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final bool isActive;
  final int sortOrder;
  final List<FilterDataModel> filters;

  const FilterGroupModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    this.isActive = true,
    this.sortOrder = 0,
    this.filters = const [],
  });

  /// 从JSON创建实例
  factory FilterGroupModel.fromJson(Map<String, dynamic> json) {
    return FilterGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      filters:
          (json['filters'] as List<dynamic>?)
              ?.map(
                (filter) =>
                    FilterDataModel.fromJson(filter as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'filters': filters.map((filter) => filter.toJson()).toList(),
    };
  }
}

/// 筛选器配置数据模型（从后端获取的配置）
class FilterConfigDataModel {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final bool isDefault;
  final Map<String, dynamic> config;
  final List<FilterGroupModel> groups;

  const FilterConfigDataModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    this.isDefault = false,
    required this.config,
    this.groups = const [],
  });

  /// 从JSON创建实例
  factory FilterConfigDataModel.fromJson(Map<String, dynamic> json) {
    return FilterConfigDataModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      config: json['config'] as Map<String, dynamic>,
      groups:
          (json['groups'] as List<dynamic>?)
              ?.map(
                (group) =>
                    FilterGroupModel.fromJson(group as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'isDefault': isDefault,
      'config': config,
      'groups': groups.map((group) => group.toJson()).toList(),
    };
  }
}

/// 筛选器选择状态数据模型
class FilterSelectionModel {
  final String filterId;
  final String selectedId;
  final String selectedValue;
  final Map<String, dynamic>? metadata;
  final DateTime selectedAt;

  const FilterSelectionModel({
    required this.filterId,
    required this.selectedId,
    required this.selectedValue,
    this.metadata,
    required this.selectedAt,
  });

  /// 从JSON创建实例
  factory FilterSelectionModel.fromJson(Map<String, dynamic> json) {
    return FilterSelectionModel(
      filterId: json['filterId'] as String,
      selectedId: json['selectedId'] as String,
      selectedValue: json['selectedValue'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      selectedAt: DateTime.parse(json['selectedAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'filterId': filterId,
      'selectedId': selectedId,
      'selectedValue': selectedValue,
      'metadata': metadata,
      'selectedAt': selectedAt.toIso8601String(),
    };
  }
}
