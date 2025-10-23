import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../services/global_data_cache.dart';
import '../services/product_selection_state_service.dart';
import '../widgets/dynamic_filter_widget.dart';
import '../widgets/material_product_card.dart';
import '../models/product_filter_models.dart' as filter_models;
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

      final startTime = DateTime.now();
      print('🔄 开始加载产品数据...');

      List<Product> products;
      final cachedProducts = GlobalDataCache.getProducts();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        products = cachedProducts;
        print('✅ 从全局缓存加载产品数据');
      } else {
        products = await DataService.getAllProducts();
        print('✅ 从数据服务加载产品数据');
      }

      final endTime = DateTime.now();
      print('✅ 产品数据加载完成，耗时: ${endTime.difference(startTime).inMilliseconds}ms');

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 加载失败: $e');
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
      appBar: AppBar(
        title: Text('产品对比 (${filteredProducts.length}个)'),
        actions: [
          if (_stateService.selectedCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Chip(
                label: Text('已选择 ${_stateService.selectedCount} 个'),
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
      body: Row(
        children: [
          // 左侧筛选器 - 使用Card包装
          SizedBox(
            width: 280,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // 筛选器标题和对比模式选择
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
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
                        ),
                      ],
                    ),
                  ),
                  // 筛选器内容
                  Expanded(
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
                ],
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
                    if (!_stateService.isProductSelected(product.id)) {
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
                    if (!_stateService.isProductSelected(product.id)) {
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
}
