import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../services/global_data_cache.dart';
import '../services/product_selection_state_service.dart';
import '../config/app_config.dart';
import '../widgets/dynamic_filter_widget.dart';
import '../models/product_filter_models.dart' as filter_models;
import 'product_comparison_screen.dart';

// 图钉信息类
class PinInfo {
  final String icon;
  final Color color;
  final PinType type;
  final dynamic content;

  PinInfo({
    required this.icon,
    required this.color,
    required this.type,
    required this.content,
  });
}

// 图钉类型枚举
enum PinType {
  product, // 产品
  company, // 公司
  category, // 类别
  help, // 帮助
}

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

  // 当前选中的产品（用于图钉显示）
  Product? _currentSelectedProduct;

  // 动态筛选器选择状态
  late filter_models.FilterSelectionState _filterSelection;

  List<Product> _products = [];
  List<String> _productsForCompany = [];
  List<String> _productsForCategory = [];
  bool _isLoading = true;

  // 缓存过滤结果，避免重复计算
  List<Product>? _cachedFilteredProducts;
  String? _lastFilterKey;

  @override
  void initState() {
    super.initState();

    // 初始化筛选器状态
    _filterSelection = const filter_models.FilterSelectionState();

    // 数据已在app启动时预加载，直接加载
    _loadData();

    // 监听状态变化
    _stateService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _stateService.removeListener(_onStateChanged);
    // 清理缓存，避免内存泄漏
    _cachedFilteredProducts = null;
    _lastFilterKey = null;
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {
        // 状态变化时更新UI
      });
    }
  }

  Future<void> _loadData() async {
    print('🚀 开始加载数据');

    print('✅ 静态数据设置完成');

    setState(() {
      _isLoading = true;
    });
    print('✅ 加载状态设置完成');

    try {
      print('⏳ 开始加载产品数据...');
      final startTime = DateTime.now();

      // 优先使用全局缓存，避免重复加载
      List<Product> products;
      if (GlobalDataCache.getProducts() != null) {
        products = GlobalDataCache.getProducts()!;
        print('✅ 使用全局缓存的产品数据');
      } else {
        products = await DataService.getAllProducts();
        print('全局缓存为空，重新加载数据');
      }

      final endTime = DateTime.now();
      print('✅ 产品数据加载完成，耗时: ${endTime.difference(startTime).inMilliseconds}ms');

      // 产品数据已缓存到全局缓存中

      setState(() {
        _products = products;
        _isLoading = false;
      });
      print('✅ 产品数据设置完成');

      // 初始化产品列表
      _updateProductLists();
      print('✅ 产品列表更新完成');
    } catch (e) {
      print('❌ 加载失败: $e');
      setState(() {
        _isLoading = false;
      });
      // 显示错误信息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 更新产品列表
  void _updateProductLists() {
    if (_stateService.comparisonMode == 'same_brand') {
      // 自家对比模式：根据选择的公司和类别更新产品列表
      if (_stateService.selectedCompany != '全部' &&
          _stateService.selectedCategory != '全部') {
        _productsForCompany =
            _products
                .where(
                  (p) =>
                      p.company == _stateService.selectedCompany &&
                      p.category == _stateService.selectedCategory,
                )
                .map((p) => p.name)
                .toSet() // 去重
                .toList()
                .cast<String>()
              ..sort(); // 排序
        _productsForCompany.insert(0, '全部');
      } else {
        _productsForCompany = ['全部'];
      }
    } else {
      // 同类对比模式：根据选择的类别更新产品列表
      if (_stateService.selectedCategoryForComparison != '全部') {
        _productsForCategory =
            _products
                .where(
                  (p) =>
                      p.category == _stateService.selectedCategoryForComparison,
                )
                .map((p) => p.name)
                .toSet() // 去重
                .toList()
                .cast<String>()
              ..sort(); // 排序
        _productsForCategory.insert(0, '全部');
      } else {
        _productsForCategory = ['全部'];
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
        title: const Text('产品对比'),
        actions: [
          if (_stateService.selectedProductIds.isNotEmpty)
            TextButton(
              onPressed: _stateService.canStartComparison
                  ? () => _navigateToComparison()
                  : null,
              child: Text(
                '对比 (${_stateService.selectedCount})',
                style: TextStyle(
                  color: _stateService.canStartComparison
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // 左侧筛选器
          Container(
            width: 200, // 固定宽度
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade50,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // 对比模式选择
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SegmentedButton<String>(
                            segments: const [
                              ButtonSegment<String>(
                                value: 'same_brand',
                                label: SizedBox(width: 60, child: Text('自家对比')),
                              ),
                              ButtonSegment<String>(
                                value: 'same_category',
                                label: SizedBox(width: 60, child: Text('同类对比')),
                              ),
                            ],
                            selected: {_stateService.comparisonMode},
                            onSelectionChanged: (Set<String> selection) {
                              setState(() {
                                _stateService.setComparisonMode(
                                  selection.first,
                                );
                                _stateService.clearAll();
                                _updateProductLists();
                              });
                            },
                            showSelectedIcon: false,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 筛选器
                Expanded(
                  child: ProductSelectionDynamicFilterWidget(
                    comparisonMode: _stateService.comparisonMode,
                    initialSelection: _filterSelection,
                    onSelectionChanged: (nodeId, value) {
                      // 更新筛选器选择状态
                      setState(() {
                        if (nodeId.startsWith('brand_')) {
                          _filterSelection = _filterSelection.copyWith(
                            selectedBrand: value,
                          );
                          // 清空后续选择
                          _filterSelection = _filterSelection.copyWith(
                            selectedCategory: null,
                            selectedProductLine: null,
                          );
                        } else if (nodeId.startsWith('category_')) {
                          _filterSelection = _filterSelection.copyWith(
                            selectedCategory: value,
                          );
                          // 清空后续选择
                          _filterSelection = _filterSelection.copyWith(
                            selectedProductLine: null,
                          );
                        } else if (nodeId.startsWith('product_line_')) {
                          _filterSelection = _filterSelection.copyWith(
                            selectedProductLine: value,
                          );
                          // 产品线是筛选器的最后一级，选择后会在右边产品列表中显示具体产品
                        }
                      });

                      // 根据选择更新产品列表
                      // _updateProductListsBasedOnFilter();
                    },
                  ),
                ),
              ],
            ),
          ),
          // 右侧产品列表
          Expanded(
            child: Column(
              children: [
                // 顶部工具栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '产品列表 (${filteredProducts.length}个)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      if (_getCurrentFilterText().isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getCurrentFilterText(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ] else ...[
                        const Spacer(),
                      ],
                      const Spacer(),
                      if (_stateService.selectedCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '已选择 ${_stateService.selectedCount} 个',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // 产品列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isSelected = _stateService.isProductSelected(
                        product.id,
                      );
                      final companyColor = _getCompanyColor(product.company);

                      return Slidable(
                            key: ValueKey(product.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) =>
                                      _showProductDetails(product),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.info_outline,
                                  label: '详情',
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    setState(() {
                                      _currentSelectedProduct = product;
                                      if (!isSelected &&
                                          _stateService.selectedCount <
                                              SettingsService.maxProducts) {
                                        _stateService.addProductId(product.id);
                                      }
                                    });
                                  },
                                  backgroundColor: isSelected
                                      ? Colors.grey
                                      : Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: isSelected ? Icons.check : Icons.add,
                                  label: isSelected ? '已选' : '选择',
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: isSelected ? 12 : 4,
                              shadowColor: isSelected
                                  ? companyColor.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? companyColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Container(
                                height: 80.h, // 减少高度避免溢出
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isSelected
                                      ? companyColor.withOpacity(0.1)
                                      : Theme.of(context).brightness ==
                                            Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      // 更新当前选中的产品（用于图钉显示）
                                      _currentSelectedProduct = product;

                                      if (!isSelected) {
                                        // 检查是否超过最大选择数量
                                        if (_stateService.selectedCount <
                                            SettingsService.maxProducts) {
                                          _stateService.addProductId(
                                            product.id,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
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
                                  onLongPress: () {
                                    // 长按显示产品详情，同时更新当前选中产品
                                    setState(() {
                                      _currentSelectedProduct = product;
                                    });
                                    _showProductDetails(product);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        // 左侧：公司logo
                                        Container(
                                          width: 28.w,
                                          height: 28.w,
                                          decoration: BoxDecoration(
                                            color: companyColor,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: companyColor.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppConfig.getCompanyLogo(
                                                product.company,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // 中间：产品信息 - 均匀分布
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // 产品名称
                                              Text(
                                                product.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10.sp,
                                                  color: isSelected
                                                      ? _getCompanyColor(
                                                          product.company,
                                                        )
                                                      : Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 0),
                                              // 次要信息 - 均匀分布在一行
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // 公司标签
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 3,
                                                          vertical: 1,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: companyColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            3,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      product.company,
                                                      style: TextStyle(
                                                        color: companyColor,
                                                        fontSize: 8.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  // 类别
                                                  Text(
                                                    product.category,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color,
                                                      fontSize: 8.sp,
                                                    ),
                                                  ),
                                                  // 价格
                                                  if (SettingsService
                                                      .showPrices)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 3,
                                                            vertical: 1,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.green
                                                                  .withOpacity(
                                                                    0.2,
                                                                  )
                                                            : Colors.green
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              3,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '¥${product.price.toStringAsFixed(0)}',
                                                        style: const TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 7,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  // 更新时间
                                                  Text(
                                                    _formatUpdateTime(
                                                      product.releaseDate,
                                                    ),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color,
                                                      fontSize: 7.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // 右侧：选择框
                                        Container(
                                          width: 16.w,
                                          height: 16.w,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? _getCompanyColor(
                                                    product.company,
                                                  )
                                                : Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                ? Colors.grey.shade600
                                                : Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: Checkbox(
                                            value: isSelected,
                                            activeColor:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : companyColor,
                                            checkColor:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? companyColor
                                                : Colors.white,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value == true) {
                                                  _stateService.addProductId(
                                                    product.id,
                                                  );
                                                }
                                              });
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate(delay: Duration(milliseconds: index * 50))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0)
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.0, 1.0),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 底部操作栏 - 优化版本
      bottomNavigationBar: _stateService.selectedProductIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // 清空选择按钮
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _stateService.clearAll();
                            });
                          },
                          icon: Icon(
                            Icons.clear_all,
                            size: 18,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                          label: Text(
                            '清空选择',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 开始对比按钮
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _stateService.canStartComparison
                              ? () => _navigateToComparison()
                              : null,
                          icon: Icon(
                            Icons.compare_arrows,
                            size: 18,
                            color: _stateService.canStartComparison
                                ? Colors.white
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                          label: Text(
                            _stateService.canStartComparison
                                ? '开始对比 (${_stateService.selectedCount})'
                                : '至少选择2个产品',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _stateService.canStartComparison
                                  ? Colors.white
                                  : Theme.of(context).brightness ==
                                        Brightness.dark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _stateService.canStartComparison
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                            shadowColor: _stateService.canStartComparison
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3)
                                : Colors.transparent,
                            elevation: _stateService.canStartComparison ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 获取当前筛选条件文本
  String _getCurrentFilterText() {
    // 如果筛选器状态无效，返回空字符串
    try {
      List<String> filters = [];

      if (_stateService.comparisonMode == 'same_brand') {
        // 自家对比模式 - 使用动态筛选器的选择状态
        if (_filterSelection.selectedBrand != null &&
            _filterSelection.selectedBrand != '全部') {
          filters.add('品牌: ${_filterSelection.selectedBrand}');
        }
        if (_filterSelection.selectedCategory != null &&
            _filterSelection.selectedCategory != '全部') {
          filters.add('类别: ${_filterSelection.selectedCategory}');
        }
        if (_filterSelection.selectedProductLine != null &&
            _filterSelection.selectedProductLine != '全部') {
          filters.add('产品线: ${_filterSelection.selectedProductLine}');
        }
      } else {
        // 同类对比模式 - 使用动态筛选器的选择状态
        if (_filterSelection.selectedCategory != null &&
            _filterSelection.selectedCategory != '全部') {
          filters.add('类别: ${_filterSelection.selectedCategory}');
        }
        if (_filterSelection.selectedProductLine != null &&
            _filterSelection.selectedProductLine != '全部') {
          filters.add('产品线: ${_filterSelection.selectedProductLine}');
        }
      }

      return filters.join(' | ');
    } catch (e) {
      // 如果出现任何错误，返回空字符串
      print('Error in _getCurrentFilterText: $e');
      return '';
    }
  }

  List<Product> _getFilteredProducts() {
    // 生成缓存键
    final filterKey =
        '${_stateService.comparisonMode}_${_stateService.selectedCompany}_${_stateService.selectedCategoryForComparison}';

    // 如果过滤条件没有变化，返回缓存结果
    if (_cachedFilteredProducts != null && _lastFilterKey == filterKey) {
      return _cachedFilteredProducts!;
    }

    List<Product> result;
    if (_stateService.comparisonMode == 'same_brand') {
      // 自家对比模式：显示选中公司的所有产品
      if (_stateService.selectedCompany != '全部') {
        result = _products
            .where((p) => p.company == _stateService.selectedCompany)
            .toList();
      } else {
        result = [];
      }
    } else {
      // 同类对比模式：显示选中类别的所有产品
      if (_stateService.selectedCategoryForComparison != '全部') {
        result = _products
            .where(
              (p) => p.category == _stateService.selectedCategoryForComparison,
            )
            .toList();
      } else {
        result = [];
      }
    }

    // 缓存结果
    _cachedFilteredProducts = result;
    _lastFilterKey = filterKey;

    return result;
  }

  void _navigateToComparison() {
    if (widget.onNavigateToComparison != null) {
      widget.onNavigateToComparison!(_stateService.selectedProductIds);
    } else {
      // 备用方案：使用原来的Navigator.push
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductComparisonScreen(
            selectedProductIds: _stateService.selectedProductIds,
          ),
        ),
      );
    }
  }

  // 缓存颜色计算结果 - 使用更高效的缓存
  static final Map<String, Color> _colorCache = {};

  // 预计算常用颜色，避免运行时计算
  static final Map<String, Color> _precomputedColors = {
    'Apple': const Color(0xFF007AFF),
    'Samsung': const Color(0xFF1F2937),
    'Google': const Color(0xFF4285F4),
    'Tesla': const Color(0xFFCC0000),
    'Microsoft': const Color(0xFF00BCF2),
    'Huawei': const Color(0xFFFF6B35),
    'Xiaomi': const Color(0xFFFF6900),
    'Oppo': const Color(0xFF00C853),
    'Vivo': const Color(0xFF1E88E5),
    'OnePlus': const Color(0xFFF50057),
  };

  Color _getCompanyColor(String company) {
    // 首先检查预计算的颜色
    if (_precomputedColors.containsKey(company)) {
      return _precomputedColors[company]!;
    }

    // 然后检查缓存
    if (_colorCache.containsKey(company)) {
      return _colorCache[company]!;
    }

    // 最后才进行字符串解析
    final colorString = AppConfig.getCompanyColor(company);
    final color = Color(int.parse(colorString.replaceAll('#', '0xFF')));
    _colorCache[company] = color;
    return color;
  }

  // 缓存时间格式化结果
  static final Map<String, String> _timeFormatCache = {};

  // 格式化更新时间 - 使用缓存避免重复计算
  String _formatUpdateTime(DateTime dateTime) {
    final cacheKey = dateTime.toIso8601String();

    if (_timeFormatCache.containsKey(cacheKey)) {
      return _timeFormatCache[cacheKey]!;
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String result;
    if (difference.inDays > 365) {
      result = '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      result = '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      result = '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      result = '${difference.inHours}小时前';
    } else {
      result = '刚刚';
    }

    _timeFormatCache[cacheKey] = result;
    return result;
  }

  // 构建右下角固定图钉
  Widget _buildFloatingActionButton() {
    // 获取当前应该显示的图标和颜色
    final pinInfo = _getCurrentPinInfo();
    final selectedCount = _stateService.selectedCount;

    return Stack(
      children: [
        FloatingActionButton(
          onPressed: _showProductInfo,
          backgroundColor: pinInfo.color,
          child: Text(pinInfo.icon, style: const TextStyle(fontSize: 24)),
        ),
        // 上标显示选中产品数量
        if (selectedCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                selectedCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // 获取当前图钉应该显示的信息
  PinInfo _getCurrentPinInfo() {
    // 优先级：当前点击的产品 > 选中的公司 > 选中的类别 > 默认帮助
    if (_currentSelectedProduct != null) {
      // 显示当前点击产品的公司logo
      return PinInfo(
        icon: AppConfig.getCompanyLogo(_currentSelectedProduct!.company),
        color: _getCompanyColor(_currentSelectedProduct!.company),
        type: PinType.product,
        content: _currentSelectedProduct!,
      );
    }

    if (_stateService.comparisonMode == 'same_brand' &&
        _stateService.selectedCompany != '全部') {
      // 显示选中公司的logo
      return PinInfo(
        icon: AppConfig.getCompanyLogo(_stateService.selectedCompany),
        color: _getCompanyColor(_stateService.selectedCompany),
        type: PinType.company,
        content: _stateService.selectedCompany,
      );
    }

    if (_stateService.comparisonMode == 'same_category' &&
        _stateService.selectedCategoryForComparison != '全部') {
      // 显示选中类别的logo
      return PinInfo(
        icon: AppConfig.getCategoryLogo(
          _stateService.selectedCategoryForComparison,
        ),
        color: Theme.of(context).primaryColor,
        type: PinType.category,
        content: _stateService.selectedCategoryForComparison,
      );
    }

    // 默认状态
    return PinInfo(
      icon: '❓',
      color: Theme.of(context).primaryColor,
      type: PinType.help,
      content: '帮助',
    );
  }

  // 显示产品信息或操作提示
  void _showProductInfo() {
    final pinInfo = _getCurrentPinInfo();

    switch (pinInfo.type) {
      case PinType.product:
        _showProductDetails(pinInfo.content as Product);
        break;
      case PinType.company:
        _showCompanyInfo(pinInfo.content as String);
        break;
      case PinType.category:
        _showCategoryInfo(pinInfo.content as String);
        break;
      case PinType.help:
        _showOperationTips();
        break;
    }
  }

  // 显示产品详细信息
  void _showProductDetails(Product product) {
    final companyColor = _getCompanyColor(product.company);
    final isSelected = _stateService.isProductSelected(product.id);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 20,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部 - 带渐变背景
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [companyColor, companyColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // 公司logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppConfig.getCompanyLogo(product.company),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 产品信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.company,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 选中状态指示器
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '已选中',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // 内容区域
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 基本信息卡片
                      _buildInfoCard('基本信息', [
                        _buildInfoRow('类别', product.category),
                        _buildInfoRow(
                          '价格',
                          '¥${product.price.toStringAsFixed(0)}',
                        ),
                        _buildInfoRow(
                          '发布时间',
                          _formatUpdateTime(product.releaseDate),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      // 规格信息卡片 - 显示所有规格
                      _buildInfoCard(
                        '详细规格',
                        product.specs.entries
                            .map(
                              (entry) => _buildInfoRow(
                                entry.key,
                                entry.value.toString(),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 6),
                      // 产品统计信息
                      _buildInfoCard('产品统计', [
                        _buildInfoRow('规格参数数量', '${product.specs.length}个'),
                        _buildInfoRow('产品ID', product.id),
                        _buildInfoRow('公司', product.company),
                        _buildInfoRow('类别', product.category),
                      ]),
                      const SizedBox(height: 6),
                      // 性能指标（如果有数值型规格）
                      _buildPerformanceCard(product),
                    ],
                  ),
                ),
              ),
              // 底部按钮
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('关闭'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _navigateToComparison();
                          },
                          icon: const Icon(Icons.compare_arrows),
                          label: const Text('查看对比'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: companyColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示公司信息
  void _showCompanyInfo(String company) {
    final companyColor = _getCompanyColor(company);
    final companyLogo = AppConfig.getCompanyLogo(company);

    // 获取该公司的所有产品
    final companyProducts = _products
        .where((p) => p.company == company)
        .toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 20,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部 - 带渐变背景
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [companyColor, companyColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // 公司logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          companyLogo,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 公司信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${companyProducts.length}个产品',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 产品列表
                      _buildInfoCard('产品列表', [
                        ...companyProducts
                            .take(10)
                            .map(
                              (product) => ListTile(
                                leading: Text(
                                  AppConfig.getCategoryLogo(product.category),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                title: Text(product.name),
                                subtitle: Text(
                                  '${product.category} • ¥${product.price.toStringAsFixed(0)}',
                                ),
                                trailing:
                                    _stateService.isProductSelected(product.id)
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _currentSelectedProduct = product;
                                  });
                                },
                              ),
                            )
                            .toList(),
                        if (companyProducts.length > 10)
                          const ListTile(
                            title: Text('...'),
                            subtitle: Text('更多产品请使用筛选器查看'),
                          ),
                      ]),
                    ],
                  ),
                ),
              ),
              // 底部按钮
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('关闭'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示类别信息
  void _showCategoryInfo(String category) {
    final categoryLogo = AppConfig.getCategoryLogo(category);

    // 获取该类别的所有产品
    final categoryProducts = _products
        .where((p) => p.category == category)
        .toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 20,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部 - 带渐变背景
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // 类别logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          categoryLogo,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 类别信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${categoryProducts.length}个产品',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 产品列表
                      _buildInfoCard('产品列表', [
                        ...categoryProducts
                            .take(10)
                            .map(
                              (product) => ListTile(
                                leading: Text(
                                  AppConfig.getCompanyLogo(product.company),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                title: Text(product.name),
                                subtitle: Text(
                                  '${product.company} • ¥${product.price.toStringAsFixed(0)}',
                                ),
                                trailing:
                                    _stateService.isProductSelected(product.id)
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _currentSelectedProduct = product;
                                  });
                                },
                              ),
                            )
                            .toList(),
                        if (categoryProducts.length > 10)
                          const ListTile(
                            title: Text('...'),
                            subtitle: Text('更多产品请使用筛选器查看'),
                          ),
                      ]),
                    ],
                  ),
                ),
              ),
              // 底部按钮
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('关闭'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示操作提示
  void _showOperationTips() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 20,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      '操作提示',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // 内容
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTipCard('📱', '选择产品', '点击产品卡片选择产品进行对比'),
                      const SizedBox(height: 6),
                      _buildTipCard('👆', '查看详情', '长按产品卡片查看详细规格参数'),
                      const SizedBox(height: 6),
                      _buildTipCard('🔍', '筛选产品', '使用筛选器快速找到目标产品'),
                      const SizedBox(height: 6),
                      _buildTipCard('⚡', '开始对比', '选择2-5个产品后点击"对比"按钮'),
                      const SizedBox(height: 6),
                      _buildTipCard('💡', '智能图钉', '点击图钉查看当前选择状态，图标会根据选择内容变化'),
                    ],
                  ),
                ),
              ),
              // 底部按钮
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check),
                    label: const Text('知道了'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建提示卡片
  Widget _buildTipCard(String emoji, String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建信息卡片
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建性能指标卡片
  Widget _buildPerformanceCard(Product product) {
    // 提取数值型规格参数
    final numericSpecs = <String, double>{};
    final textSpecs = <String, String>{};

    for (final entry in product.specs.entries) {
      final value = entry.value;
      if (value is num) {
        numericSpecs[entry.key] = value.toDouble();
      } else {
        textSpecs[entry.key] = value.toString();
      }
    }

    if (numericSpecs.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildInfoCard('性能指标', [
      ...numericSpecs.entries
          .map(
            (entry) => _buildInfoRow(
              entry.key,
              '${entry.value.toStringAsFixed(entry.value % 1 == 0 ? 0 : 2)}',
            ),
          )
          .toList(),
    ]);
  }
}
