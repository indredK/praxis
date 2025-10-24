import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../services/global_data_cache.dart';
import '../services/product_selection_state_service.dart';
import '../widgets/dynamic_filter_widget.dart';
import '../widgets/material_product_card.dart';
import '../models/product_filter_models.dart' as filter_models;
import '../config/app_config.dart';
import 'product_comparison_screen.dart';

class ProductSelectionScreen extends StatefulWidget {
  final Function(List<String>)? onNavigateToComparison;

  const ProductSelectionScreen({super.key, this.onNavigateToComparison});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  // 产品选择状态管理服务
  final ProductSelectionStateService _stateService =
      ProductSelectionStateService();

  // 动态筛选器选择状态
  late filter_models.FilterSelectionState _filterSelection;

  List<Product> _products = [];
  bool _isLoading = true;

  // 缓存过滤结果，避免重复计算
  List<Product>? _cachedFilteredProducts;
  String? _lastFilterKey;

  @override
  void initState() {
    super.initState();
    _filterSelection = const filter_models.FilterSelectionState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      List<Product> products;
      final cachedProducts = GlobalDataCache.getProducts();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        products = cachedProducts;
      } else {
        products = await DataService.getAllProducts();
      }

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.05),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppBar(
                title: Text(
                  '产品对比 (${filteredProducts.length}个)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                actions: [
                  if (_stateService.selectedCount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: _showSelectedProducts,
                        borderRadius: BorderRadius.circular(16),
                        child: Chip(
                          label: Text('已选择 ${_stateService.selectedCount} 个'),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (_stateService.selectedProductIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: FilledButton.icon(
                        onPressed: _stateService.canStartComparison
                            ? () => _navigateToComparison()
                            : null,
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text('开始对比'),
                      ),
                    ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          // 左侧筛选器 - 毛玻璃效果
          SizedBox(
            width: 320, // 缩小宽度，更紧凑
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
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
                  child: Column(
                    children: [
                      // 筛选器标题和对比模式选择
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.15),
                              Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment<String>(
                                    value: 'same_brand',
                                    label: Text('自家对比'),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'same_category',
                                    label: Text('同类对比'),
                                  ),
                                ],
                                selected: {_stateService.comparisonMode},
                                onSelectionChanged: (Set<String> selection) {
                                  if (selection.isNotEmpty) {
                                    setState(() {
                                      _stateService.setComparisonMode(
                                        selection.first,
                                      );
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                    const Size(0, 40),
                                  ),
                                  textStyle: WidgetStateProperty.all(
                                    const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 筛选器内容
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: DynamicFilterWidget(
                            comparisonMode: _stateService.comparisonMode,
                            initialSelection: _filterSelection,
                            onSelectionChanged: (nodeId, value) {
                              setState(() {
                                if (nodeId.startsWith('brand_')) {
                                  _filterSelection = _filterSelection.copyWith(
                                    selectedBrand: value,
                                  );
                                } else if (nodeId.startsWith('category_')) {
                                  _filterSelection = _filterSelection.copyWith(
                                    selectedCategory: value,
                                  );
                                } else if (nodeId.startsWith('product_line_')) {
                                  _filterSelection = _filterSelection.copyWith(
                                    selectedProductLine: value,
                                  );
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 右侧产品列表 - 使用Card包装
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(8),
              child: MaterialProductList(
                products: filteredProducts,
                selectedProductIds: _stateService.selectedProductIds,
                onProductTap: (product) {
                  setState(() {
                    if (_stateService.isProductSelected(product.id)) {
                      // 如果已选择，则取消选择
                      _stateService.removeProductId(product.id);
                    } else {
                      // 如果未选择，则添加选择
                      if (_stateService.selectedCount <
                          SettingsService.maxProducts) {
                        _stateService.addProductId(product.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '最多只能选择${SettingsService.maxProducts}个产品进行对比',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  });
                },
                onProductLongPress: (product) {
                  _showProductDetails(product);
                },
                onProductSelect: (product) {
                  setState(() {
                    if (_stateService.isProductSelected(product.id)) {
                      // 如果已选择，则取消选择
                      _stateService.removeProductId(product.id);
                    } else {
                      // 如果未选择，则添加选择
                      if (_stateService.selectedCount <
                          SettingsService.maxProducts) {
                        _stateService.addProductId(product.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '最多只能选择${SettingsService.maxProducts}个产品进行对比',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  });
                },
                onProductDetails: (product) {
                  _showProductDetails(product);
                },
                isLoading: _isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取过滤后的产品列表
  List<Product> _getFilteredProducts() {
    final filterKey =
        '${_stateService.comparisonMode}_${_filterSelection.toString()}';

    // 如果过滤条件没有变化，返回缓存结果
    if (_lastFilterKey == filterKey && _cachedFilteredProducts != null) {
      return _cachedFilteredProducts!;
    }

    List<Product> filtered = _products;

    // 根据对比模式过滤
    if (_stateService.comparisonMode == 'same_brand') {
      // 自家对比：只显示同一品牌的产品
      if (_filterSelection.selectedBrand != null) {
        filtered = filtered
            .where(
              (product) => product.company == _filterSelection.selectedBrand,
            )
            .toList();
      }
    } else if (_stateService.comparisonMode == 'same_category') {
      // 同类对比：显示同一类别的产品
      if (_filterSelection.selectedCategory != null) {
        filtered = filtered
            .where(
              (product) =>
                  product.category == _filterSelection.selectedCategory,
            )
            .toList();
      }
    }

    // 缓存结果
    _cachedFilteredProducts = filtered;
    _lastFilterKey = filterKey;

    return filtered;
  }

  // 导航到对比页面
  void _navigateToComparison() {
    if (widget.onNavigateToComparison != null) {
      widget.onNavigateToComparison!(_stateService.selectedProductIds);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductComparisonScreen(
            selectedProductIds: _stateService.selectedProductIds,
          ),
        ),
      );
    }
  }

  // 显示产品详情
  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductDetailsDialog(product: product),
    );
  }

  void _showSelectedProducts() {
    final selectedProducts = _products
        .where(
          (product) => _stateService.selectedProductIds.contains(product.id),
        )
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '已选择 ${selectedProducts.length} 个产品',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: selectedProducts.length,
            itemBuilder: (context, index) {
              final product = selectedProducts[index];
              final companyColor = _getCompanyColor(product.company);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: companyColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        AppConfig.getCompanyLogo(product.company),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${product.company} • ${product.category}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _stateService.removeProductId(product.id);
                      });
                      Navigator.of(context).pop();
                      _showSelectedProducts(); // 重新显示更新后的列表
                    },
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: '取消选择',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '关闭',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (selectedProducts.length >= 2)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToComparison();
              },
              child: const Text('开始对比'),
            ),
        ],
      ),
    );
  }

  Color _getCompanyColor(String company) {
    final colorString = AppConfig.getCompanyColor(company);
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }
}
