import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/filter_tree.dart';

class TreeFilterWidget extends StatefulWidget {
  final List<FilterTreeNode> filterTree;
  final FilterTreeConfig config;
  final Function(String nodeId, String? value)? onSelectionChanged;
  final bool isLoading;

  const TreeFilterWidget({
    super.key,
    required this.filterTree,
    this.config = const FilterTreeConfig(),
    this.onSelectionChanged,
    this.isLoading = false,
  });

  @override
  State<TreeFilterWidget> createState() => _TreeFilterWidgetState();
}

class _TreeFilterWidgetState extends State<TreeFilterWidget> {
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
  void didUpdateWidget(TreeFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterTree != widget.filterTree) {
      // 保持当前的选择状态，但更新树结构
      _currentTree = _updateTreeWithCurrentSelections(widget.filterTree);
    }
  }

  void _toggleExpansion(String nodeId) {
    setState(() {
      _currentTree = _updateNodeExpansion(_currentTree, nodeId);
    });
  }

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

  /// 使用当前选择状态更新树结构
  List<FilterTreeNode> _updateTreeWithCurrentSelections(
    List<FilterTreeNode> newTree,
  ) {
    return newTree.map((node) {
      // 查找当前树中对应节点的选择状态
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
        // 如果是父节点，递归处理子节点
        return node.copyWith(
          children: _updateNodeSelection(node.children, selectedNode),
        );
      } else {
        // 简化逻辑：直接处理选择状态
        // 检查是否与选中节点在同一个级别
        final isInSameLevel = _isInSameParent(tree, node.id, selectedNode.id);

        if (isInSameLevel) {
          // 同一个级别：只有选中的节点高亮，其他都取消高亮（单选）
          final shouldSelect = node.id == selectedNode.id;
          return node.copyWith(isSelected: shouldSelect);
        } else {
          // 不同级别：保持原状态（独立选择）
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
    // 基于节点ID前缀判断是否同级别
    // 品牌: brand_all, brand_Apple, brand_Samsung
    // 类别: category_all, category_Electronics
    // 产品线: product_line_all, product_line_iPhone

    final prefix1 = nodeId1.split('_')[0];
    final prefix2 = nodeId2.split('_')[0];

    return prefix1 == prefix2;
  }

  void _handleNodeTap(FilterTreeNode node) {
    if (node.children.isNotEmpty) {
      // 如果是父节点，切换展开状态
      _toggleExpansion(node.id);
    } else {
      // 如果是叶子节点，处理选择
      widget.onSelectionChanged?.call(node.id, node.value);
    }
  }

  void _handleFilterChipTap(FilterTreeNode node) {
    // 立即更新本地选择状态，提供即时视觉反馈
    setState(() {
      // 更新选择状态：同级别单选，不同级别独立
      _currentTree = _updateNodeSelection(_currentTree, node);
    });

    // 通知外部选择变化
    widget.onSelectionChanged?.call(node.id, node.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.config.width,
      decoration: BoxDecoration(
        color:
            widget.config.backgroundColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade50),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 2.5),
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            trackVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(5),
            radius: const Radius.circular(2.5),
            thumbColor: WidgetStateProperty.all(
              Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
            trackColor: WidgetStateProperty.all(
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ),
          ),
          child: Scrollbar(
            controller: _scrollController,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: _buildFilterSlivers(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFilterSlivers() {
    return _currentTree.expand((node) {
      final widgets = <Widget>[_buildStickyHeader(node)];

      // 如果节点展开且有子节点，添加子节点列表
      if (node.isExpanded && node.children.isNotEmpty) {
        widgets.add(
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 3),
              ...node.children.map((child) => _buildFilterChip(child)),
              const SizedBox(height: 6),
            ]),
          ),
        );
      }

      return widgets;
    }).toList();
  }

  Widget _buildStickyHeader(FilterTreeNode node) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        title: node.title,
        isExpanded: node.isExpanded,
        hasChildren: node.children.isNotEmpty,
        onTap: () => _handleNodeTap(node),
        config: widget.config,
      ),
    );
  }

  Widget _buildFilterChip(FilterTreeNode node) {
    final isSelected = node.isSelected;
    final isDisabled = _shouldDisableNode(node);

    return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 1, right: 8),
          child: FilterChip(
            labelPadding: EdgeInsets.zero,
            label: _buildChipLabel(node, isSelected, isDisabled),
            selected: isSelected,
            onSelected: isDisabled ? null : (_) => _handleFilterChipTap(node),
            backgroundColor: _getChipBackgroundColor(isDisabled),
            selectedColor: _getChipSelectedColor(isDisabled),
            showCheckmark: false,
            side: _getChipBorder(isSelected, isDisabled),
            shape: RoundedRectangleBorder(
              borderRadius: widget.config.borderRadius,
            ),
            elevation: isSelected && !isDisabled ? 2 : 0,
            shadowColor: _getChipShadowColor(),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideX(begin: -0.1, end: 0)
        .animate(target: isDisabled && widget.isLoading ? 1 : 0)
        .shimmer(
          duration: 1500.ms,
          color: Colors.white.withValues(alpha: 0.3),
          angle: 0,
        )
        .animate(target: isDisabled && widget.isLoading ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.02, 1.02),
          duration: 800.ms,
          curve: Curves.easeInOut,
        )
        .animate(target: isDisabled && widget.isLoading ? 1 : 0)
        .fade(begin: 1.0, end: 0.7, duration: 1000.ms, curve: Curves.easeInOut);
  }

  Widget _buildChipLabel(
    FilterTreeNode node,
    bool isSelected,
    bool isDisabled,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Text(
        node.title,
        style: TextStyle(
          fontSize: widget.config.fontSize,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: _getChipTextColor(isSelected, isDisabled),
          letterSpacing: 0.1,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getChipTextColor(bool isSelected, bool isDisabled) {
    if (isDisabled) {
      return isSelected
          ? Colors.white.withValues(alpha: 0.6)
          : (widget.config.textColor ?? Colors.black).withValues(alpha: 0.4);
    }
    return isSelected
        ? Colors.white
        : (widget.config.textColor ?? Colors.black);
  }

  Color _getChipBackgroundColor(bool isDisabled) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDisabled) {
      return isDark
          ? Colors.grey.shade800.withValues(alpha: 0.3)
          : Colors.grey.shade50.withValues(alpha: 0.5);
    }
    return isDark
        ? Colors.grey.shade800.withValues(alpha: 0.5)
        : Colors.grey.shade50;
  }

  Color _getChipSelectedColor(bool isDisabled) {
    final selectedColor =
        widget.config.selectedColor ?? Theme.of(context).primaryColor;
    return selectedColor.withValues(alpha: isDisabled ? 0.3 : 0.7);
  }

  BorderSide _getChipBorder(bool isSelected, bool isDisabled) {
    if (!isSelected) return BorderSide.none;

    final selectedColor =
        widget.config.selectedColor ?? Theme.of(context).primaryColor;
    return BorderSide(
      color: selectedColor.withValues(alpha: isDisabled ? 0.2 : 0.3),
      width: 1,
    );
  }

  Color _getChipShadowColor() {
    final selectedColor =
        widget.config.selectedColor ?? Theme.of(context).primaryColor;
    return selectedColor.withValues(alpha: 0.3);
  }

  /// 判断节点是否应该被禁用
  bool _shouldDisableNode(FilterTreeNode node) {
    if (!widget.isLoading) return false;

    // 根据节点ID判断禁用逻辑
    if (node.id.startsWith('category_') && node.id != 'category_all') {
      // 如果正在加载且选择了品牌，禁用所有类别选择
      return _hasSelectedBrand();
    }

    if (node.id.startsWith('product_line_') && node.id != 'product_line_all') {
      // 如果正在加载且选择了品牌或类别，禁用所有产品线选择
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

// 吸顶标题委托
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final bool isExpanded;
  final bool hasChildren;
  final VoidCallback onTap;
  final FilterTreeConfig config;

  _StickyHeaderDelegate({
    required this.title,
    required this.isExpanded,
    required this.hasChildren,
    required this.onTap,
    required this.config,
  });

  @override
  double get minExtent => 40.0;

  @override
  double get maxExtent => 40.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: hasChildren ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: config.titleFontSize,
                    fontWeight: FontWeight.w600,
                    color:
                        config.titleColor ??
                        Theme.of(context).primaryColor.withValues(alpha: 0.6),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (hasChildren)
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color:
                      config.titleColor ??
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is _StickyHeaderDelegate &&
        (oldDelegate.title != title ||
            oldDelegate.isExpanded != isExpanded ||
            oldDelegate.hasChildren != hasChildren);
  }
}
