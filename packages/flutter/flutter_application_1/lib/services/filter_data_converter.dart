import 'package:flutter/material.dart';
import '../models/filter_data_model.dart';
import '../models/filter_tree.dart';

/// 筛选器数据转换服务
class FilterDataConverter {
  // 私有构造函数，防止实例化
  FilterDataConverter._();

  /// 将后端筛选器数据转换为前端筛选器树
  static List<FilterTreeNode> convertToFilterTree(
    List<FilterDataModel> filterData, {
    Map<String, FilterSelectionModel>? selections,
  }) {
    return filterData
        .map((data) => _convertSingleFilter(data, selections))
        .toList();
  }

  /// 转换单个筛选器数据
  static FilterTreeNode _convertSingleFilter(
    FilterDataModel data,
    Map<String, FilterSelectionModel>? selections,
  ) {
    // 检查是否有选中状态
    final isSelected = selections?[data.id]?.selectedId == data.id;

    // 转换子节点
    final children = data.children
        .map((child) => _convertSingleFilter(child, selections))
        .toList();

    return FilterTreeNode(
      id: data.id,
      title: data.displayName,
      value: data.name,
      isExpanded: data.level == 0, // 顶级节点默认展开
      isSelected: isSelected,
      children: children,
    );
  }

  /// 从筛选器组数据创建筛选器树
  static List<FilterTreeNode> convertFromFilterGroup(
    FilterGroupModel group, {
    Map<String, FilterSelectionModel>? selections,
  }) {
    return convertToFilterTree(group.filters, selections: selections);
  }

  /// 从筛选器配置数据创建筛选器树
  static List<FilterTreeNode> convertFromConfig(
    FilterConfigDataModel config, {
    Map<String, FilterSelectionModel>? selections,
  }) {
    // 获取默认组或第一个组
    final defaultGroup = config.groups.firstWhere(
      (group) => group.isActive,
      orElse: () => config.groups.first,
    );

    return convertFromFilterGroup(defaultGroup, selections: selections);
  }

  /// 创建产品选择页面的筛选器树
  static List<FilterTreeNode> createProductSelectionTree({
    required String comparisonMode,
    required List<String> companies,
    required List<String> categories,
    required List<String> productsForCompany,
    required List<String> productsForCategory,
    required Map<String, String> currentSelections,
  }) {
    if (comparisonMode == 'same_brand') {
      return [
        // 公司选择
        FilterTreeNode(
          id: 'company',
          title: '选择公司',
          isExpanded: true,
          children: companies
              .map(
                (company) => FilterTreeNode(
                  id: 'company_$company',
                  title: company,
                  value: company,
                  isSelected: company == currentSelections['company'],
                ),
              )
              .toList(),
        ),

        // 类别选择
        FilterTreeNode(
          id: 'category',
          title: '选择类别',
          isExpanded: true,
          children: categories
              .map(
                (category) => FilterTreeNode(
                  id: 'category_$category',
                  title: category,
                  value: category,
                  isSelected: category == currentSelections['category'],
                ),
              )
              .toList(),
        ),

        // 产品选择
        FilterTreeNode(
          id: 'product',
          title: '选择产品',
          isExpanded: true,
          children: productsForCompany
              .map(
                (product) => FilterTreeNode(
                  id: 'product_$product',
                  title: product,
                  value: product,
                  isSelected: product == currentSelections['product'],
                ),
              )
              .toList(),
        ),
      ];
    } else {
      return [
        // 类别选择
        FilterTreeNode(
          id: 'category',
          title: '选择类别',
          isExpanded: true,
          children: categories
              .map(
                (category) => FilterTreeNode(
                  id: 'category_$category',
                  title: category,
                  value: category,
                  isSelected: category == currentSelections['category'],
                ),
              )
              .toList(),
        ),

        // 产品选择
        FilterTreeNode(
          id: 'product',
          title: '选择产品',
          isExpanded: true,
          children: productsForCategory
              .map(
                (product) => FilterTreeNode(
                  id: 'product_$product',
                  title: product,
                  value: product,
                  isSelected: product == currentSelections['product'],
                ),
              )
              .toList(),
        ),
      ];
    }
  }

  /// 从后端数据创建产品选择筛选器树
  static List<FilterTreeNode> createProductSelectionTreeFromBackend({
    required FilterConfigDataModel config,
    required String comparisonMode,
    required Map<String, String> currentSelections,
  }) {
    // 根据对比模式选择不同的筛选器组
    String groupName;
    if (comparisonMode == 'same_brand') {
      groupName = 'same_brand_filters';
    } else {
      groupName = 'same_category_filters';
    }

    // 查找对应的筛选器组
    final targetGroup = config.groups.firstWhere(
      (group) => group.name == groupName,
      orElse: () => config.groups.first,
    );

    // 转换筛选器组为筛选器树
    return convertFromFilterGroup(
      targetGroup,
      selections: _convertSelectionsToModel(currentSelections),
    );
  }

  /// 将选择状态转换为选择模型
  static Map<String, FilterSelectionModel> _convertSelectionsToModel(
    Map<String, String> selections,
  ) {
    final Map<String, FilterSelectionModel> result = {};

    selections.forEach((key, value) {
      result[key] = FilterSelectionModel(
        filterId: key,
        selectedId: value,
        selectedValue: value,
        selectedAt: DateTime.now(),
      );
    });

    return result;
  }

  /// 获取筛选器配置
  static FilterTreeConfig getConfigFromBackend(
    FilterConfigDataModel config,
    BuildContext context,
  ) {
    final configData = config.config;

    return FilterTreeConfig(
      width: (configData['width'] as num?)?.toDouble() ?? 200,
      fontSize: (configData['fontSize'] as num?)?.toDouble() ?? 11,
      titleFontSize: (configData['titleFontSize'] as num?)?.toDouble() ?? 12,
      backgroundColor: configData['backgroundColor'] != null
          ? Color(int.parse(configData['backgroundColor'] as String))
          : null,
      selectedColor: configData['selectedColor'] != null
          ? Color(int.parse(configData['selectedColor'] as String))
          : null,
      textColor: configData['textColor'] != null
          ? Color(int.parse(configData['textColor'] as String))
          : null,
      titleColor: configData['titleColor'] != null
          ? Color(int.parse(configData['titleColor'] as String))
          : null,
      padding: configData['padding'] != null
          ? EdgeInsets.fromLTRB(
              (configData['padding']['left'] as num?)?.toDouble() ?? 8,
              (configData['padding']['top'] as num?)?.toDouble() ?? 8,
              (configData['padding']['right'] as num?)?.toDouble() ?? 8,
              (configData['padding']['bottom'] as num?)?.toDouble() ?? 8,
            )
          : const EdgeInsets.all(8),
      borderRadius: configData['borderRadius'] != null
          ? BorderRadius.circular(
              (configData['borderRadius'] as num?)?.toDouble() ?? 12,
            )
          : const BorderRadius.all(Radius.circular(12)),
    );
  }
}
