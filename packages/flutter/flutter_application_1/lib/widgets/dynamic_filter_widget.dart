import 'package:flutter/material.dart';
import '../models/product_filter_models.dart';
import '../models/filter_tree.dart';
import '../services/dynamic_filter_service.dart';
import '../config/filter_config.dart';
import 'tree_filter_widget.dart';

/// 动态筛选器组件 - 支持联动加载
class DynamicFilterWidget extends StatefulWidget {
  final String comparisonMode;
  final FilterSelectionState initialSelection;
  final Function(String nodeId, String? value) onSelectionChanged;
  final FilterTreeConfig? config;

  const DynamicFilterWidget({
    Key? key,
    required this.comparisonMode,
    required this.initialSelection,
    required this.onSelectionChanged,
    this.config,
  }) : super(key: key);

  @override
  State<DynamicFilterWidget> createState() => _DynamicFilterWidgetState();
}

class _DynamicFilterWidgetState extends State<DynamicFilterWidget> {
  FilterSelectionState _currentSelection = const FilterSelectionState();

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.initialSelection;
  }

  @override
  void didUpdateWidget(DynamicFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.comparisonMode != widget.comparisonMode ||
        oldWidget.initialSelection != widget.initialSelection) {
      _currentSelection = widget.initialSelection;
    }
  }

  /// 处理选择变化
  void _handleSelectionChanged(String nodeId, String? value) {
    // 更新当前选择状态
    FilterSelectionState newSelection = _currentSelection;

    if (nodeId.startsWith('brand_')) {
      newSelection = newSelection.copyWith(selectedBrand: value);
      // 清空后续选择
      newSelection = newSelection.copyWith(
        selectedCategory: null,
        selectedProductLine: null,
      );
    } else if (nodeId.startsWith('category_')) {
      newSelection = newSelection.copyWith(selectedCategory: value);
      // 清空后续选择
      newSelection = newSelection.copyWith(selectedProductLine: null);
    } else if (nodeId.startsWith('product_line_')) {
      newSelection = newSelection.copyWith(selectedProductLine: value);
      // 产品线是筛选器的最后一级，选择后会在右边产品列表中显示具体产品
    }

    setState(() {
      _currentSelection = newSelection;
    });

    // 通知外部选择变化
    widget.onSelectionChanged(nodeId, value);
  }

  @override
  Widget build(BuildContext context) {
    // 使用 FutureBuilder 来动态构建筛选器树
    return FutureBuilder<List<FilterTreeNode>>(
      future: DynamicFilterService.createDynamicFilterTree(
        comparisonMode: widget.comparisonMode,
        currentSelection: _currentSelection,
        onSelectionChanged: _handleSelectionChanged,
      ),
      builder: (context, snapshot) {
        // 即使正在加载也显示筛选器，但会禁用后续选择
        final filterTree = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return TreeFilterWidget(
          filterTree: filterTree,
          config:
              widget.config ?? FilterConfig.getProductSelectionConfig(context),
          onSelectionChanged: _handleSelectionChanged,
          isLoading: isLoading, // 传递加载状态
        );
      },
    );
  }
}

/// 产品选择动态筛选器组件 - 专门用于产品选择页面
class ProductSelectionDynamicFilterWidget extends StatefulWidget {
  final String comparisonMode;
  final FilterSelectionState initialSelection;
  final Function(String nodeId, String? value) onSelectionChanged;
  final FilterTreeConfig? config;

  const ProductSelectionDynamicFilterWidget({
    Key? key,
    required this.comparisonMode,
    required this.initialSelection,
    required this.onSelectionChanged,
    this.config,
  }) : super(key: key);

  @override
  State<ProductSelectionDynamicFilterWidget> createState() =>
      _ProductSelectionDynamicFilterWidgetState();
}

class _ProductSelectionDynamicFilterWidgetState
    extends State<ProductSelectionDynamicFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return DynamicFilterWidget(
      comparisonMode: widget.comparisonMode,
      initialSelection: widget.initialSelection,
      onSelectionChanged: widget.onSelectionChanged,
      config: widget.config,
    );
  }
}
