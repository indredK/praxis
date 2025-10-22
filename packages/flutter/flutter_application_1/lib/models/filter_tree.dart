import 'package:flutter/material.dart';

// 筛选器树节点模型
class FilterTreeNode {
  final String id;
  final String title;
  final String? value;
  final List<FilterTreeNode> children;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback? onTap;

  const FilterTreeNode({
    required this.id,
    required this.title,
    this.value,
    this.children = const [],
    this.isExpanded = true,
    this.isSelected = false,
    this.onTap,
  });

  FilterTreeNode copyWith({
    String? id,
    String? title,
    String? value,
    List<FilterTreeNode>? children,
    bool? isExpanded,
    bool? isSelected,
    VoidCallback? onTap,
  }) {
    return FilterTreeNode(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      isSelected: isSelected ?? this.isSelected,
      onTap: onTap ?? this.onTap,
    );
  }
}

// 筛选器配置
class FilterTreeConfig {
  final double width;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final Color? titleColor;
  final double fontSize;
  final double titleFontSize;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const FilterTreeConfig({
    this.width = 200,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.titleColor,
    this.fontSize = 11,
    this.titleFontSize = 12,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });
}
