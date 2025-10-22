import 'package:flutter/material.dart';
import '../models/filter_tree.dart';
import '../models/filter_data_model.dart';
import '../services/filter_data_converter.dart';
import '../services/filter_data_service.dart';
import '../config/filter_config.dart';
import 'tree_filter_widget.dart';

/// 智能筛选器组件 - 支持静态和动态数据源
class SmartFilterWidget extends StatefulWidget {
  /// 静态筛选器树（优先级高于动态数据）
  final List<FilterTreeNode>? staticFilterTree;

  /// 动态筛选器配置ID（从后端获取）
  final String? dynamicConfigId;

  /// 筛选器配置
  final FilterTreeConfig? config;

  /// 选择变化回调
  final Function(String nodeId, String? value)? onSelectionChanged;

  /// 加载状态回调
  final Function(bool isLoading)? onLoadingChanged;

  /// 错误回调
  final Function(String error)? onError;

  /// 是否显示加载指示器
  final bool showLoadingIndicator;

  /// 是否显示错误信息
  final bool showErrorInfo;

  /// 自定义加载组件
  final Widget? loadingWidget;

  /// 自定义错误组件
  final Widget? errorWidget;

  const SmartFilterWidget({
    Key? key,
    this.staticFilterTree,
    this.dynamicConfigId,
    this.config,
    this.onSelectionChanged,
    this.onLoadingChanged,
    this.onError,
    this.showLoadingIndicator = true,
    this.showErrorInfo = true,
    this.loadingWidget,
    this.errorWidget,
  }) : assert(
         staticFilterTree != null || dynamicConfigId != null,
         'Either staticFilterTree or dynamicConfigId must be provided',
       ),
       super(key: key);

  @override
  State<SmartFilterWidget> createState() => _SmartFilterWidgetState();
}

class _SmartFilterWidgetState extends State<SmartFilterWidget> {
  List<FilterTreeNode> _filterTree = [];
  bool _isLoading = false;
  String? _error;
  FilterConfigDataModel? _dynamicConfig;

  @override
  void initState() {
    super.initState();
    _initializeFilter();
  }

  @override
  void didUpdateWidget(SmartFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查是否需要重新初始化
    if (oldWidget.staticFilterTree != widget.staticFilterTree ||
        oldWidget.dynamicConfigId != widget.dynamicConfigId) {
      _initializeFilter();
    }
  }

  /// 初始化筛选器
  Future<void> _initializeFilter() async {
    if (widget.staticFilterTree != null) {
      // 使用静态数据
      setState(() {
        _filterTree = widget.staticFilterTree!;
        _isLoading = false;
        _error = null;
      });
      widget.onLoadingChanged?.call(false);
    } else if (widget.dynamicConfigId != null) {
      // 使用动态数据
      await _loadDynamicFilter();
    }
  }

  /// 加载动态筛选器数据
  Future<void> _loadDynamicFilter() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      widget.onLoadingChanged?.call(true);

      // 从后端获取配置
      final config = await FilterDataService.getFilterConfigById(
        widget.dynamicConfigId!,
      );

      if (config == null) {
        throw Exception('筛选器配置不存在: ${widget.dynamicConfigId}');
      }

      // 获取用户选择状态
      final selections = await FilterDataService.getFilterSelections(
        'current_user',
      );
      final selectionMap = <String, FilterSelectionModel>{};
      for (final selection in selections) {
        selectionMap[selection.filterId] = selection;
      }

      // 转换为筛选器树
      final filterTree = FilterDataConverter.convertFromConfig(
        config,
        selections: selectionMap,
      );

      setState(() {
        _dynamicConfig = config;
        _filterTree = filterTree;
        _isLoading = false;
      });
      widget.onLoadingChanged?.call(false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      widget.onLoadingChanged?.call(false);
      widget.onError?.call(e.toString());
    }
  }

  /// 处理筛选器项选择
  void _onFilterSelectionChanged(String nodeId, String? value) {
    widget.onSelectionChanged?.call(nodeId, value);

    // 如果是动态数据，保存选择状态
    if (widget.dynamicConfigId != null && _dynamicConfig != null) {
      _saveSelection(nodeId, value);
    }
  }

  /// 保存选择状态
  Future<void> _saveSelection(String nodeId, String? value) async {
    try {
      final selection = FilterSelectionModel(
        filterId: nodeId,
        selectedId: nodeId,
        selectedValue: value ?? '',
        selectedAt: DateTime.now(),
      );

      await FilterDataService.saveFilterSelections([selection]);
    } catch (e) {
      // 静默处理保存错误
      print('保存筛选器选择失败: $e');
    }
  }

  /// 获取筛选器配置
  FilterTreeConfig _getFilterConfig() {
    if (widget.config != null) {
      return widget.config!;
    }

    if (widget.dynamicConfigId != null && _dynamicConfig != null) {
      return FilterDataConverter.getConfigFromBackend(_dynamicConfig!, context);
    }

    return FilterConfig.getProductSelectionConfig(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.showLoadingIndicator) {
      return widget.loadingWidget ?? _buildDefaultLoadingWidget();
    }

    if (_error != null && widget.showErrorInfo) {
      return widget.errorWidget ?? _buildDefaultErrorWidget();
    }

    return TreeFilterWidget(
      filterTree: _filterTree,
      config: _getFilterConfig(),
      onSelectionChanged: _onFilterSelectionChanged,
    );
  }

  /// 默认加载组件
  Widget _buildDefaultLoadingWidget() {
    return Container(
      width: _getFilterConfig().width,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('加载筛选器中...'),
          ],
        ),
      ),
    );
  }

  /// 默认错误组件
  Widget _buildDefaultErrorWidget() {
    return Container(
      width: _getFilterConfig().width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            Text('加载失败', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              _error ?? '未知错误',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initializeFilter,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 产品选择筛选器组件 - 专门用于产品选择页面
class ProductSelectionFilterWidget extends StatelessWidget {
  final String comparisonMode;
  final List<String> companies;
  final List<String> categories;
  final List<String> productsForCompany;
  final List<String> productsForCategory;
  final Map<String, String> currentSelections;
  final Function(String nodeId, String? value) onSelectionChanged;
  final FilterTreeConfig? config;

  const ProductSelectionFilterWidget({
    Key? key,
    required this.comparisonMode,
    required this.companies,
    required this.categories,
    required this.productsForCompany,
    required this.productsForCategory,
    required this.currentSelections,
    required this.onSelectionChanged,
    this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterTree = FilterDataConverter.createProductSelectionTree(
      comparisonMode: comparisonMode,
      companies: companies,
      categories: categories,
      productsForCompany: productsForCompany,
      productsForCategory: productsForCategory,
      currentSelections: currentSelections,
    );

    return TreeFilterWidget(
      filterTree: filterTree,
      config: config ?? FilterConfig.getProductSelectionConfig(context),
      onSelectionChanged: onSelectionChanged,
    );
  }
}
