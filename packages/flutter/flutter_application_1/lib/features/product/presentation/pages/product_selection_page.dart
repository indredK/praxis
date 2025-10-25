import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state_manager.dart';
import '../../domain/models/product.dart' as models;
import '../../data/services/data_service.dart';
import '../../../../features/settings/data/services/settings_service.dart';
import '../../data/services/global_data_cache.dart';
import '../../data/services/product_selection_state_service.dart';
import '../widgets/advanced_filter_widget.dart';
import '../widgets/material_product_card.dart';
import '../../domain/models/product_filter_models.dart' as filter_models;
import '../../domain/models/advanced_filter_models.dart';

class ProductSelectionPage extends StatefulWidget {
  const ProductSelectionPage({super.key});

  @override
  State<ProductSelectionPage> createState() => _ProductSelectionPageState();
}

class _ProductSelectionPageState extends State<ProductSelectionPage> {
  // 产品选择状态管理服务
  final ProductSelectionStateService _stateService =
      ProductSelectionStateService();

  // 动态筛选器选择状态
  late filter_models.FilterSelectionState _filterSelection;

  // 高级筛选器选择状态
  late AdvancedFilterSelection _advancedFilterSelection;

  List<models.Product> _products = [];
  bool _isLoading = true;

  // 缓存过滤结果，避免重复计算
  List<models.Product>? _cachedFilteredProducts;
  String? _lastFilterKey;

  @override
  void initState() {
    super.initState();
    _filterSelection = const filter_models.FilterSelectionState();
    _advancedFilterSelection = const AdvancedFilterSelection();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      List<models.Product> products;
      final cachedProducts = GlobalDataCache.getProducts();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        products = cachedProducts;
        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        final dataServiceProducts = await DataService.getAllProducts();
        products = dataServiceProducts.cast<models.Product>();
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
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
    final filteredProducts = _isLoading
        ? <models.Product>[]
        : _getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text('产品对比 (${filteredProducts.length}个)'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.8),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 8,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
          ),
        ),
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
            width: 320, // 增加宽度以容纳固定宽度的筛选器
            child: Card(
              margin: const EdgeInsets.all(12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // 筛选器标题和对比模式选择
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
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
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 300, // 增加宽度避免文字换行
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
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
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment<String>(
                                      value: 'same_brand',
                                      label: Text('自家对比'),
                                      icon: Icon(Icons.business, size: 18),
                                    ),
                                    ButtonSegment<String>(
                                      value: 'same_category',
                                      label: Text('同类对比'),
                                      icon: Icon(Icons.category, size: 18),
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
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                              MaterialState.selected,
                                            )) {
                                              return Theme.of(
                                                context,
                                              ).primaryColor;
                                            }
                                            return Colors.transparent;
                                          },
                                        ),
                                    foregroundColor:
                                        WidgetStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                              MaterialState.selected,
                                            )) {
                                              return Colors.white;
                                            }
                                            return Theme.of(
                                              context,
                                            ).colorScheme.onSurface;
                                          },
                                        ),
                                    side:
                                        WidgetStateProperty.resolveWith<
                                          BorderSide?
                                        >((Set<MaterialState> states) {
                                          return BorderSide.none;
                                        }),
                                    shape:
                                        WidgetStateProperty.all<
                                          RoundedRectangleBorder
                                        >(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                    padding:
                                        WidgetStateProperty.all<
                                          EdgeInsetsGeometry
                                        >(
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 筛选器内容
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AdvancedFilterWidget(
                        comparisonMode: _stateService.comparisonMode,
                        initialSelection: _advancedFilterSelection,
                        onSelectionChanged: (selection) {
                          setState(() {
                            _advancedFilterSelection = selection;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 右侧产品列表 - 使用Card包装
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isLoading
                  ? _buildSkeletonScreen()
                  : MaterialProductList(
                      products: filteredProducts,
                      selectedProductIds: _stateService.selectedProductIds,
                      onProductTap: (product) {
                        setState(() {
                          if (_stateService.isProductSelected(product.id)) {
                            // 如果已选中，则取消选择
                            _stateService.removeProductId(product.id);
                          } else {
                            // 如果未选中，则添加选择
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
                            // 如果已选中，则取消选择
                            _stateService.removeProductId(product.id);
                          } else {
                            // 如果未选中，则添加选择
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
  List<models.Product> _getFilteredProducts() {
    final filterKey =
        '${_stateService.comparisonMode}_${_filterSelection.toString()}';

    // 如果过滤条件没有变化，返回缓存结果
    if (_lastFilterKey == filterKey && _cachedFilteredProducts != null) {
      return _cachedFilteredProducts!;
    }

    List<models.Product> filtered = _products;

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
    // 使用AppStateManager来管理对比状态
    final appStateManager = Provider.of<AppStateManager>(
      context,
      listen: false,
    );

    // 直接设置选中的产品ID列表，这样会清除旧的选择并使用新的选择
    appStateManager.setSelectedProducts(_stateService.selectedProductIds);

    // 显示对比页面
    appStateManager.showComparisonPage();
  }

  // 显示产品详情
  void _showProductDetails(models.Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductDetailsDialog(product: product),
    );
  }

  /// 骨架屏
  Widget _buildSkeletonScreen() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }

  /// 骨架卡片
  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmer(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmer(
                    child: Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildShimmer(
                    child: Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildShimmer(
                        child: Container(
                          height: 14,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildShimmer(
                        child: Container(
                          height: 14,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildShimmer(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 闪烁动画
  Widget _buildShimmer({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, _child) {
        return Opacity(opacity: value, child: _child);
      },
      onEnd: () {
        if (mounted && _isLoading) {
          setState(() {});
        }
      },
      child: child,
    );
  }
}

// 产品详情对话框
class ProductDetailsDialog extends StatelessWidget {
  final models.Product product;

  const ProductDetailsDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '公司: ${product.company}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '类别: ${product.category}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '价格: ¥${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '产品规格:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...product.specifications.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                '${entry.key}:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 这里可以添加选择产品的逻辑
                  },
                  child: const Text('选择此产品'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
