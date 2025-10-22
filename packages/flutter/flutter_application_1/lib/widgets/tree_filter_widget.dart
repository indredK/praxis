import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/filter_tree.dart';

class TreeFilterWidget extends StatefulWidget {
  final List<FilterTreeNode> filterTree;
  final FilterTreeConfig config;
  final Function(String nodeId, String? value)? onSelectionChanged;

  const TreeFilterWidget({
    super.key,
    required this.filterTree,
    this.config = const FilterTreeConfig(),
    this.onSelectionChanged,
  });

  @override
  State<TreeFilterWidget> createState() => _TreeFilterWidgetState();
}

class _TreeFilterWidgetState extends State<TreeFilterWidget> {
  late List<FilterTreeNode> _currentTree;

  @override
  void initState() {
    super.initState();
    _currentTree = widget.filterTree;
  }

  @override
  void didUpdateWidget(TreeFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterTree != widget.filterTree) {
      _currentTree = widget.filterTree;
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
    // 筛选器项点击处理
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
            child: CustomScrollView(slivers: _buildFilterSlivers()),
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
              color: isSelected ? Colors.white : widget.config.textColor,
              letterSpacing: 0.1,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => _handleFilterChipTap(node),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade50,
        selectedColor:
            widget.config.selectedColor ??
            Theme.of(context).primaryColor.withOpacity(0.7),
        showCheckmark: false,
        side: BorderSide(
          color: isSelected
              ? (widget.config.selectedColor ?? Theme.of(context).primaryColor)
                    .withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: widget.config.borderRadius),
        elevation: isSelected ? 2 : 0,
        shadowColor:
            (widget.config.selectedColor ?? Theme.of(context).primaryColor)
                .withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.1, end: 0);
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
