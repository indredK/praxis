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

  /// 更新同级别的选择状态（单选模式）
  List<FilterTreeNode> _updateSelectionInSameLevel(
    List<FilterTreeNode> tree,
    FilterTreeNode selectedNode,
  ) {
    return tree.map((node) {
      if (node.children.isNotEmpty) {
        // 如果是父节点，递归处理子节点
        return node.copyWith(
          children: _updateSelectionInSameLevel(node.children, selectedNode),
        );
      } else {
        // 如果是叶子节点，检查是否与选中节点在同一级别
        if (_isInSameLevel(tree, node.id, selectedNode.id)) {
          // 同级别：只有选中的节点高亮，其他都取消高亮
          return node.copyWith(isSelected: node.id == selectedNode.id);
        } else {
          // 不同级别：保持原状态
          return node;
        }
      }
    }).toList();
  }

  /// 判断两个节点是否在同一级别
  bool _isInSameLevel(List<FilterTreeNode> tree, String nodeId1, String nodeId2) {
    // 查找两个节点的父节点ID
    final parentId1 = _findParentId(tree, nodeId1);
    final parentId2 = _findParentId(tree, nodeId2);
    
    // 如果父节点ID相同，说明在同一级别
    return parentId1 == parentId2;
  }

  /// 查找节点的父节点ID
  String? _findParentId(List<FilterTreeNode> tree, String nodeId) {
    for (final node in tree) {
      if (node.children.any((child) => child.id == nodeId)) {
        return node.id;
      }
      if (node.children.isNotEmpty) {
        final parentId = _findParentId(node.children, nodeId);
        if (parentId != null) return parentId;
      }
    }
    return null;
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
      // 先清除同级别的其他选择，然后高亮当前选择
      _currentTree = _updateSelectionInSameLevel(_currentTree, node);
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
              Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            trackColor: WidgetStateProperty.all(
              Theme.of(context).primaryColor.withOpacity(0.05),
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
    List<Widget> slivers = [];
    for (var node in _currentTree) {
      // 添加吸顶标题
      slivers.add(_buildStickyHeader(node));

      // 如果节点展开且有子节点，添加子节点列表
      if (node.isExpanded && node.children.isNotEmpty) {
        slivers.add(
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 3),
              ...node.children.map((child) => _buildFilterChip(child)),
              const SizedBox(height: 6),
            ]),
          ),
        );
      }
    }
    return slivers;
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

    // 判断是否应该禁用此选项
    final isDisabled = _shouldDisableNode(node);

    return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 1, right: 8),
          child: FilterChip(
            labelPadding: EdgeInsets.zero,
            label: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Text(
                node.title,
                style: TextStyle(
                  fontSize: widget.config.fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isDisabled
                      ? (isSelected
                            ? Colors.white.withOpacity(0.6)
                            : (widget.config.textColor ?? Colors.black)
                                  .withOpacity(0.4))
                      : (isSelected ? Colors.white : widget.config.textColor),
                  letterSpacing: 0.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            selected: isSelected,
            onSelected: isDisabled
                ? null
                : (selected) => _handleFilterChipTap(node),
            backgroundColor: isDisabled
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800.withOpacity(0.3)
                      : Colors.grey.shade50.withOpacity(0.5))
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.grey.shade50),
            selectedColor: isDisabled
                ? (widget.config.selectedColor ??
                          Theme.of(context).primaryColor)
                      .withOpacity(0.3)
                : (widget.config.selectedColor ??
                          Theme.of(context).primaryColor)
                      .withOpacity(0.7),
            showCheckmark: false,
            side: BorderSide(
              color: isSelected
                  ? (widget.config.selectedColor ??
                            Theme.of(context).primaryColor)
                        .withOpacity(isDisabled ? 0.2 : 0.3)
                  : Colors.transparent,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: widget.config.borderRadius,
            ),
            elevation: isSelected && !isDisabled ? 2 : 0,
            shadowColor:
                (widget.config.selectedColor ?? Theme.of(context).primaryColor)
                    .withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideX(begin: -0.1, end: 0)
        // 添加波动动画效果
        .animate(target: isDisabled && widget.isLoading ? 1 : 0)
        .shimmer(
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.3),
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
          color: Theme.of(context).primaryColor.withOpacity(0.05),
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
                        Theme.of(context).primaryColor.withOpacity(0.6),
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
                      Theme.of(context).primaryColor.withOpacity(0.6),
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
