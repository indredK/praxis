import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/filter_tree.dart';

/// 基于Material Design的筛选器组件
/// 使用Flutter官方组件实现，提供简洁高效的筛选功能
class MaterialFilterWidget extends StatefulWidget {
  final List<FilterTreeNode> filterTree;
  final FilterTreeConfig config;
  final Function(String nodeId, String? value)? onSelectionChanged;
  final bool isLoading;

  const MaterialFilterWidget({
    super.key,
    required this.filterTree,
    this.config = const FilterTreeConfig(),
    this.onSelectionChanged,
    this.isLoading = false,
  });

  @override
  State<MaterialFilterWidget> createState() => _MaterialFilterWidgetState();
}

class _MaterialFilterWidgetState extends State<MaterialFilterWidget> {
  late List<FilterTreeNode> _currentTree;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentTree = widget.filterTree;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MaterialFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterTree != widget.filterTree) {
      _currentTree = _updateTreeWithCurrentSelections(widget.filterTree);
    }
  }

  /// 更新树结构，保持当前选择状态
  List<FilterTreeNode> _updateTreeWithCurrentSelections(
    List<FilterTreeNode> newTree,
  ) {
    return newTree.map((node) {
      final currentSelection = _findNodeSelection(_currentTree, node.id);

      if (node.children.isNotEmpty) {
        return node.copyWith(
          isSelected: currentSelection,
          children: _updateTreeWithCurrentSelections(node.children),
        );
      } else {
        return node.copyWith(isSelected: currentSelection);
      }
    }).toList();
  }

  /// 查找节点在当前树中的选择状态
  bool _findNodeSelection(List<FilterTreeNode> tree, String nodeId) {
    for (final node in tree) {
      if (node.id == nodeId) {
        return node.isSelected;
      }
      if (node.children.isNotEmpty) {
        final found = _findNodeSelection(node.children, nodeId);
        if (found) return found;
      }
    }
    return false;
  }

  /// 更新节点选择状态（同级别单选，不同级别独立）
  List<FilterTreeNode> _updateNodeSelection(
    List<FilterTreeNode> tree,
    FilterTreeNode selectedNode,
  ) {
    return tree.map((node) {
      if (node.children.isNotEmpty) {
        return node.copyWith(
          children: _updateNodeSelection(node.children, selectedNode),
        );
      } else {
        final isInSameLevel = _isInSameParent(tree, node.id, selectedNode.id);

        if (isInSameLevel) {
          final shouldSelect = node.id == selectedNode.id;
          return node.copyWith(isSelected: shouldSelect);
        } else {
          return node;
        }
      }
    }).toList();
  }

  /// 判断两个节点是否在同一个级别
  bool _isInSameParent(
    List<FilterTreeNode> tree,
    String nodeId1,
    String nodeId2,
  ) {
    final parts1 = nodeId1.split('_');
    final parts2 = nodeId2.split('_');

    // 确保分割后有足够的元素
    if (parts1.isEmpty || parts2.isEmpty) {
      return false;
    }

    final prefix1 = parts1[0];
    final prefix2 = parts2[0];
    return prefix1 == prefix2;
  }

  /// 更新节点展开状态
  List<FilterTreeNode> _updateNodeExpansion(
    List<FilterTreeNode> nodes,
    String nodeId,
  ) {
    return nodes.map((node) {
      if (node.id == nodeId) {
        return node.copyWith(isExpanded: !node.isExpanded);
      } else if (node.children.isNotEmpty) {
        return node.copyWith(
          children: _updateNodeExpansion(node.children, nodeId),
        );
      }
      return node;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // 使用ExpansionTile实现可展开的分组
                ..._currentTree.map((node) => _buildExpansionTile(node)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建ExpansionTile
  Widget _buildExpansionTile(FilterTreeNode node) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          node.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        initiallyExpanded: node.isExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _currentTree = _updateNodeExpansion(_currentTree, node.id);
          });
        },
        // 去掉分割线
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        children: [
          // 使用Wrap布局显示筛选器选项
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: node.children
                  .map((child) => _buildFilterChip(child))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建FilterChip
  Widget _buildFilterChip(FilterTreeNode node) {
    final isSelected = node.isSelected;
    final isDisabled = _shouldDisableNode(node);

    return FilterChip(
      label: Text(
        node.title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isDisabled
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)
              : (isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface),
        ),
      ),
      selected: isSelected,
      onSelected: isDisabled
          ? null
          : (bool value) {
              setState(() {
                _currentTree = _updateNodeSelection(_currentTree, node);
              });
              widget.onSelectionChanged?.call(node.id, node.value);
            },
      backgroundColor: _getChipBackgroundColor(isDisabled),
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.8),
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isSelected ? 4 : 1,
      shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// 获取Chip背景色
  Color _getChipBackgroundColor(bool isDisabled) {
    if (isDisabled) {
      return Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    }
    return Theme.of(context).colorScheme.surface;
  }

  /// 判断节点是否应该被禁用
  bool _shouldDisableNode(FilterTreeNode node) {
    if (!widget.isLoading) return false;

    // 根据节点ID判断禁用逻辑
    if (node.id.startsWith('category_') && node.id != 'category_all') {
      return _hasSelectedBrand();
    }

    if (node.id.startsWith('product_line_') && node.id != 'product_line_all') {
      return _hasSelectedBrand() || _hasSelectedCategory();
    }

    return false;
  }

  /// 检查是否已选择品牌
  bool _hasSelectedBrand() {
    return _currentTree.any(
      (node) =>
          node.id == 'brand_filter' &&
          node.children.any(
            (child) => child.isSelected && child.id != 'brand_all',
          ),
    );
  }

  /// 检查是否已选择类别
  bool _hasSelectedCategory() {
    return _currentTree.any(
      (node) =>
          node.id == 'category_filter' &&
          node.children.any(
            (child) => child.isSelected && child.id != 'category_all',
          ),
    );
  }
}

/// 使用Material Design的简化版筛选器组件
/// 适用于简单的筛选场景
class SimpleMaterialFilterWidget extends StatefulWidget {
  final List<FilterTreeNode> filterTree;
  final FilterTreeConfig config;
  final Function(String nodeId, String? value)? onSelectionChanged;
  final bool isLoading;

  const SimpleMaterialFilterWidget({
    super.key,
    required this.filterTree,
    this.config = const FilterTreeConfig(),
    this.onSelectionChanged,
    this.isLoading = false,
  });

  @override
  State<SimpleMaterialFilterWidget> createState() =>
      _SimpleMaterialFilterWidgetState();
}

class _SimpleMaterialFilterWidgetState
    extends State<SimpleMaterialFilterWidget> {
  late List<FilterTreeNode> _currentTree;

  @override
  void initState() {
    super.initState();
    _currentTree = widget.filterTree;
  }

  @override
  void didUpdateWidget(SimpleMaterialFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterTree != widget.filterTree) {
      _currentTree = widget.filterTree;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.config.width,
      decoration: BoxDecoration(
        color: widget.config.backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: widget.config.borderRadius,
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 使用ListTile显示分组标题
            ..._currentTree.map(
              (node) => Column(
                children: [
                  ListTile(
                    title: Text(
                      node.title,
                      style: TextStyle(
                        fontSize: widget.config.titleFontSize,
                        fontWeight: FontWeight.w600,
                        color:
                            widget.config.titleColor ??
                            Theme.of(context).primaryColor,
                      ),
                    ),
                    trailing: node.children.isNotEmpty
                        ? Icon(
                            Icons.keyboard_arrow_down,
                            color:
                                widget.config.titleColor ??
                                Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                  // 使用Wrap显示筛选器选项
                  if (node.children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: node.children
                            .map((child) => _buildFilterChip(child))
                            .toList(),
                      ),
                    ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建FilterChip
  Widget _buildFilterChip(FilterTreeNode node) {
    final isSelected = node.isSelected;

    return FilterChip(
      label: Text(
        node.title,
        style: TextStyle(
          fontSize: widget.config.fontSize,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : widget.config.textColor ??
                    Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      selected: isSelected,
      onSelected: (bool value) {
        setState(() {
          _currentTree = _updateNodeSelection(_currentTree, node);
        });
        widget.onSelectionChanged?.call(node.id, node.value);
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor:
          widget.config.selectedColor ?? Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? (widget.config.selectedColor ?? Theme.of(context).primaryColor)
            : Theme.of(context).dividerColor,
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: widget.config.borderRadius),
      elevation: isSelected ? 2 : 0,
      shadowColor:
          widget.config.selectedColor ?? Theme.of(context).primaryColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// 更新节点选择状态
  List<FilterTreeNode> _updateNodeSelection(
    List<FilterTreeNode> tree,
    FilterTreeNode selectedNode,
  ) {
    return tree.map((node) {
      if (node.children.isNotEmpty) {
        return node.copyWith(
          children: _updateNodeSelection(node.children, selectedNode),
        );
      } else {
        final isInSameLevel = _isInSameParent(tree, node.id, selectedNode.id);

        if (isInSameLevel) {
          final shouldSelect = node.id == selectedNode.id;
          return node.copyWith(isSelected: shouldSelect);
        } else {
          return node;
        }
      }
    }).toList();
  }

  /// 判断两个节点是否在同一个级别
  bool _isInSameParent(
    List<FilterTreeNode> tree,
    String nodeId1,
    String nodeId2,
  ) {
    final parts1 = nodeId1.split('_');
    final parts2 = nodeId2.split('_');

    // 确保分割后有足够的元素
    if (parts1.isEmpty || parts2.isEmpty) {
      return false;
    }

    final prefix1 = parts1[0];
    final prefix2 = parts2[0];
    return prefix1 == prefix2;
  }
}
