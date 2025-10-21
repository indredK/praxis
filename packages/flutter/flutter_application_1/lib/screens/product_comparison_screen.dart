import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../services/global_data_cache.dart';
import '../config/app_config.dart';
import '../widgets/advanced_charts.dart';

// 产品卡片配置常量
class ProductCardConfig {
  // 高度配置
  static const double maxCardHeight = 270.0; // 最高高度限制（微调：260→270）
  static const double minCardHeight = 150.0; // 最低高度限制（微调：140→150）

  // 基础高度配置
  static const double cardPadding = 32.0; // Card padding (16px * 2)
  static const double logoHeight = 80.0; // Logo区域高度
  static const double logoSpacing = 10.0; // Logo后间距（微调）

  // 内容区域高度配置
  static const double nameHeight = 50.0; // 产品名称区域高度（微调：45→50）
  static const double nameSpacing = 12.0; // 名称后间距（微调：10→12）
  static const double companyHeight = 40.0; // 公司标签区域高度（微调：35→40）
  static const double companySpacing = 12.0; // 标签后间距（微调：10→12）
  static const double priceHeight = 50.0; // 价格区域高度（微调：45→50）

  // 压缩阈值配置
  static const double nameThreshold = 0.2; // 产品名称显示阈值（微调：0.25→0.2）
  static const double companyThreshold = 0.1; // 公司标签显示阈值（微调：0.15→0.1）
  static const double priceThreshold = 0.15; // 价格显示阈值（微调：0.2→0.15）
}

// 表格配置类
class TableConfig {
  final double columnWidth;
  final double specColumnWidth;
  final double totalTableWidth;
  final bool needsScrolling;
  final bool shouldUseVirtualizedTable;
  final double minColumnWidth;
  final double maxColumnWidth;

  TableConfig({
    required this.columnWidth,
    required this.specColumnWidth,
    required this.totalTableWidth,
    required this.needsScrolling,
    required this.shouldUseVirtualizedTable,
    required this.minColumnWidth,
    required this.maxColumnWidth,
  });
}

class ProductComparisonScreen extends StatefulWidget {
  final List<String> selectedProductIds;
  final VoidCallback? onBackPressed;

  const ProductComparisonScreen({
    super.key,
    required this.selectedProductIds,
    this.onBackPressed,
  });

  @override
  State<ProductComparisonScreen> createState() =>
      _ProductComparisonScreenState();
}

class _ProductComparisonScreenState extends State<ProductComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Product> _selectedProducts = [];
  bool _isLoading = true;

  // 基准对比功能：第一个产品作为基准
  int _baselineIndex = 0;

  // 智能对比提示显示状态
  bool _showSmartComparisonTip = false;

  // 预加载的对比数据缓存
  List<SpecComparison>? _cachedComparisons;

  // 吸顶卡片相关状态
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _isSticky = false;

  // 计算百分比差异
  String? _calculatePercentage(dynamic baselineValue, dynamic currentValue) {
    try {
      double baseline = 0;
      double current = 0;

      if (baselineValue is num) {
        baseline = baselineValue.toDouble();
      } else if (baselineValue is String) {
        baseline =
            double.tryParse(baselineValue.replaceAll(RegExp(r'[^\d.]'), '')) ??
            0;
      }

      if (currentValue is num) {
        current = currentValue.toDouble();
      } else if (currentValue is String) {
        current =
            double.tryParse(currentValue.replaceAll(RegExp(r'[^\d.]'), '')) ??
            0;
      }

      if (baseline == 0) return null;

      final percentage = ((current - baseline) / baseline * 100);
      if (percentage > 0) {
        return '+${percentage.toStringAsFixed(1)}%';
      } else if (percentage < 0) {
        return '${percentage.toStringAsFixed(1)}%';
      } else {
        return '0%';
      }
    } catch (e) {
      return null;
    }
  }

  // 根据百分比获取颜色
  Color _getPercentageColor(String percentage) {
    if (percentage.startsWith('+')) {
      return Colors.red.withOpacity(0.1);
    } else if (percentage.startsWith('-')) {
      return Colors.blue.withOpacity(0.1);
    } else {
      return Colors.grey.withOpacity(0.1);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    print('✅ TabController 初始化完成，长度: ${_tabController.length}');
    _loadSelectedProducts();

    // 监听滚动事件
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动监听方法
  void _onScroll() {
    final offset = _scrollController.offset;
    final shouldBeSticky = offset > 200; // 滚动200px后开始吸顶

    if (shouldBeSticky != _isSticky) {
      setState(() {
        _isSticky = shouldBeSticky;
        _scrollOffset = offset;
      });
    } else {
      setState(() {
        _scrollOffset = offset;
      });
    }
  }

  Future<void> _loadSelectedProducts() async {
    // 立即显示产品，无加载状态
    setState(() {
      _isLoading = false;
    });

    try {
      // 优先使用全局缓存，避免重复加载
      List<Product> products;
      if (GlobalDataCache.getProducts() != null) {
        products = GlobalDataCache.getProducts()!;
        print('✅ 使用全局缓存的产品数据');
      } else {
        products = await DataService.getAllProducts();
        print('全局缓存为空，重新加载数据');
      }

      // 添加边界检查
      if (products.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('没有可用的产品数据'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // 限制产品ID数量，防止性能问题
      final limitedProductIds = widget.selectedProductIds.take(15).toList();

      setState(() {
        _selectedProducts = products
            .where((product) => limitedProductIds.contains(product.id))
            .toList();
      });

      // 异步预加载对比数据，不阻塞UI
      _preloadComparisonData();

      // 检查是否找到了选中的产品
      if (_selectedProducts.isEmpty && limitedProductIds.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('未找到选中的产品，请重新选择'),
              backgroundColor: Colors.orange,
            ),
          );
          // 返回上一页
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('❌ 加载产品数据失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载产品数据失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        // 延迟返回，让用户看到错误信息
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  // 智能预加载对比数据
  Future<void> _preloadComparisonData() async {
    if (_selectedProducts.isEmpty || _cachedComparisons != null) return;

    try {
      final comparisons = await DataService.getProductComparison(
        _selectedProducts.map((p) => p.id).toList(),
      );

      if (mounted) {
        setState(() {
          _cachedComparisons = comparisons;
        });
        print('✅ 预加载基础对比数据完成');
      }
    } catch (e) {
      print('❌ 预加载基础对比数据失败: $e');
    }
  }

  // 无缝切换基准
  void _switchBaseline(int newBaselineIndex) {
    if (newBaselineIndex == _baselineIndex) return;

    setState(() {
      _baselineIndex = newBaselineIndex;
      // 对比数据相同，只是显示方式不同，无需重新加载
      print('✅ 切换基准索引到 $newBaselineIndex');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 添加边界检查，防止空数据导致崩溃
    if (_selectedProducts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('产品对比')),
        body: const Center(
          child: Text('没有选择任何产品进行对比', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    // 限制产品数量，防止UI崩溃
    final displayProducts = _selectedProducts.take(10).toList();
    if (_selectedProducts.length > 10) {
      // 显示警告信息
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('产品数量过多，只显示前10个产品'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('产品对比 (${displayProducts.length})'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBackPressed != null) {
              widget.onBackPressed!();
            } else {
              // 备用方案：使用Navigator.pop()
              Navigator.of(context).pop();
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0), // TabBar的标准高度
          child: Container(
            color: Theme.of(context).primaryColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isNarrowScreen = screenWidth < 600;

                return TabBar(
                  controller: _tabController,
                  isScrollable: isNarrowScreen, // 窄屏时启用滚动
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabAlignment: isNarrowScreen
                      ? TabAlignment.start
                      : TabAlignment.fill,
                  tabs: [
                    Tab(
                      text: isNarrowScreen ? '规格' : '规格对比',
                      icon: const Icon(Icons.table_chart, size: 16),
                    ),
                    Tab(
                      text: isNarrowScreen ? '价格' : '价格对比',
                      icon: const Icon(Icons.attach_money, size: 16),
                    ),
                    Tab(
                      text: isNarrowScreen ? '性能' : '性能分析',
                      icon: const Icon(Icons.radar, size: 16),
                    ),
                    Tab(
                      text: isNarrowScreen ? '散点' : '散点图',
                      icon: const Icon(Icons.scatter_plot, size: 16),
                    ),
                    Tab(
                      text: isNarrowScreen ? '份额' : '份额图',
                      icon: const Icon(Icons.pie_chart, size: 16),
                    ),
                    Tab(
                      text: isNarrowScreen ? '趋势' : '趋势图',
                      icon: const Icon(Icons.trending_up, size: 16),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSpecComparisonTab(),
          _buildPriceComparisonTab(),
          _buildPerformanceTab(),
          _buildScatterAnalysisTab(),
          _buildMarketShareTab(),
          _buildTrendAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildSpecComparisonTab() {
    // 使用缓存的数据，无加载状态
    final comparisons = _cachedComparisons ?? [];

    return Stack(
      children: [
        // 主要内容区域
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 产品概览卡片
              _buildProductOverviewCards(),
              const SizedBox(height: 24),

              // 规格对比表格
              Row(
                children: [
                  Text(
                    '详细规格对比',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSmartComparisonTip = !_showSmartComparisonTip;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '智能对比',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_showSmartComparisonTip)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue.shade900.withOpacity(0.3)
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '系统已智能筛选出共有参数和重要参数进行对比，确保对比结果更有意义',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              if (comparisons.isEmpty)
                const Center(child: Text('暂无对比数据'))
              else
                _buildSpecComparisonTable(comparisons),
            ],
          ),
        ),
        // 吸顶的产品卡片
        _buildStickyProductCards(),
      ],
    );
  }

  // 吸顶的产品卡片
  Widget _buildStickyProductCards() {
    if (!_isSticky) return const SizedBox.shrink();

    // 计算透明度，基于滚动偏移量
    final opacity = (_scrollOffset - 200).clamp(0.0, 100.0) / 100.0;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).scaffoldBackgroundColor.withOpacity(0.95 + opacity * 0.05),
              Theme.of(
                context,
              ).scaffoldBackgroundColor.withOpacity(0.85 + opacity * 0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final productCount = _selectedProducts.length;

            // 计算吸顶卡片的自适应宽度（与主卡片保持一致的计算逻辑）
            final minCardWidth = 100.0; // 吸顶卡片最小宽度
            final maxCardWidth = 150.0; // 吸顶卡片最大宽度
            final cardSpacing = 8.0; // 吸顶卡片间距
            final totalSpacing = (productCount - 1) * cardSpacing;
            final availableWidth = screenWidth - 32; // 减去padding

            // 计算自适应宽度
            final adaptiveCardWidth =
                (availableWidth - totalSpacing) / productCount;
            final cardWidth = adaptiveCardWidth.clamp(
              minCardWidth,
              maxCardWidth,
            );

            // 判断是否需要滚动
            final totalRequiredWidth =
                (cardWidth * productCount) + totalSpacing;
            final needsScrolling = totalRequiredWidth > availableWidth;

            if (needsScrolling) {
              // 需要滚动：使用水平滚动布局
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _selectedProducts.map((product) {
                    final productIndex = _selectedProducts.indexOf(product);
                    final isBaseline = productIndex == _baselineIndex;

                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isBaseline
                              ? [
                                  Colors.green.withOpacity(0.2),
                                  Colors.green.withOpacity(0.1),
                                ]
                              : [
                                  _getCompanyColor(
                                    product.company,
                                  ).withOpacity(0.2),
                                  _getCompanyColor(
                                    product.company,
                                  ).withOpacity(0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: isBaseline
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(
                                color: _getCompanyColor(
                                  product.company,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                      ),
                      child: Row(
                        children: [
                          // 产品头像
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isBaseline
                                    ? [Colors.green, Colors.green.shade700]
                                    : [
                                        _getCompanyColor(product.company),
                                        _getCompanyColor(
                                          product.company,
                                        ).withOpacity(0.7),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                product.company[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // 产品名称
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isBaseline
                                    ? Colors.green.shade700
                                    : _getCompanyColor(product.company),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 基准按钮
                          GestureDetector(
                            onTap: () => _switchBaseline(productIndex),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isBaseline
                                    ? Colors.green
                                    : Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isBaseline
                                      ? Colors.green.shade700
                                      : Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isBaseline
                                    ? Icons.check
                                    : Icons.radio_button_unchecked,
                                color: isBaseline
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              // 不需要滚动：使用自适应Row布局
              return Row(
                children: _selectedProducts.map((product) {
                  final productIndex = _selectedProducts.indexOf(product);
                  final isBaseline = productIndex == _baselineIndex;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isBaseline
                              ? [
                                  Colors.green.withOpacity(0.2),
                                  Colors.green.withOpacity(0.1),
                                ]
                              : [
                                  _getCompanyColor(
                                    product.company,
                                  ).withOpacity(0.2),
                                  _getCompanyColor(
                                    product.company,
                                  ).withOpacity(0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: isBaseline
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(
                                color: _getCompanyColor(
                                  product.company,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                      ),
                      child: Row(
                        children: [
                          // 产品头像
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isBaseline
                                    ? [Colors.green, Colors.green.shade700]
                                    : [
                                        _getCompanyColor(product.company),
                                        _getCompanyColor(
                                          product.company,
                                        ).withOpacity(0.7),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                product.company[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // 产品名称
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isBaseline
                                    ? Colors.green.shade700
                                    : _getCompanyColor(product.company),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 基准按钮
                          GestureDetector(
                            onTap: () => _switchBaseline(productIndex),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isBaseline
                                    ? Colors.green
                                    : Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isBaseline
                                      ? Colors.green.shade700
                                      : Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isBaseline
                                    ? Icons.check
                                    : Icons.radio_button_unchecked,
                                color: isBaseline
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductOverviewCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final productCount = _selectedProducts.length;

        final cardSpacing = 16.0; // 卡片间距
        final totalSpacing = (productCount - 1) * cardSpacing; // 总间距
        final availableWidth = screenWidth - 32; // 可用宽度（减去padding）

        // 计算自适应宽度
        final adaptiveCardWidth =
            (availableWidth - totalSpacing) / productCount;
        final minCardWidth = 150.0; // 最小卡片宽度
        final maxCardWidth = 300.0; // 最大卡片宽度
        final cardWidth = adaptiveCardWidth.clamp(minCardWidth, maxCardWidth);

        // 智能高度计算：根据压缩状态动态调整
        final maxCardHeight = ProductCardConfig.maxCardHeight;
        final minCardHeight = ProductCardConfig.minCardHeight;

        // 简化的压缩逻辑：直接根据卡片宽度决定显示内容和高度
        // 避免复杂的压缩比例计算，直接使用宽度阈值

        // 基础高度：Logo + padding + 间距
        double dynamicHeight =
            ProductCardConfig.cardPadding +
            ProductCardConfig.logoHeight +
            ProductCardConfig.logoSpacing;

        // 根据卡片宽度直接决定显示内容，使用更保守的阈值
        bool showName = cardWidth > 190; // 宽度大于190px时显示名称
        bool showCompany = cardWidth > 160; // 宽度大于160px时显示公司
        bool showPrice = cardWidth > 210; // 宽度大于210px时显示价格

        // 根据显示内容累加高度
        if (showName) {
          dynamicHeight +=
              ProductCardConfig.nameHeight + ProductCardConfig.nameSpacing;
        }

        if (showCompany) {
          dynamicHeight +=
              ProductCardConfig.companyHeight +
              ProductCardConfig.companySpacing;
        }

        if (showPrice) {
          dynamicHeight += ProductCardConfig.priceHeight;
        }

        // 添加安全边距
        dynamicHeight += 8.0;

        // 确保高度变化平滑，避免突然变高
        // 当卡片宽度很小时，使用最小高度
        if (cardWidth < 170) {
          dynamicHeight = ProductCardConfig.minCardHeight;
        }

        final cardHeight = dynamicHeight.clamp(minCardHeight, maxCardHeight);

        // 判断是否需要滚动
        final totalRequiredWidth = (cardWidth * productCount) + totalSpacing;
        final needsScrolling = totalRequiredWidth > availableWidth;

        Widget layoutWidget;

        if (needsScrolling) {
          // 需要滚动：使用水平滚动布局
          layoutWidget = SizedBox(
            height: cardHeight + 32, // 固定高度 + 额外空间
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _selectedProducts.length,
              itemBuilder: (context, index) {
                final product = _selectedProducts[index];
                return SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Container(
                    margin: EdgeInsets.only(right: cardSpacing),
                    child: _buildProductCard(
                      product,
                      cardWidth,
                      cardHeight,
                      showName,
                      showCompany,
                      showPrice,
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          // 不需要滚动：使用自适应Row布局
          layoutWidget = SizedBox(
            height: cardHeight + 32, // 固定高度 + 额外空间
            child: Row(
              children: _selectedProducts.map((product) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
                    child: _buildProductCard(
                      product,
                      cardWidth,
                      cardHeight,
                      showName,
                      showCompany,
                      showPrice,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }

        return layoutWidget;
      },
    );
  }

  // 构建单个产品卡片
  Widget _buildProductCard(
    Product product,
    double width,
    double height,
    bool showName,
    bool showCompany,
    bool showPrice,
  ) {
    final productIndex = _selectedProducts.indexOf(product);
    final isBaseline = productIndex == _baselineIndex;

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isBaseline
                  ? [
                      Colors.green.withOpacity(0.15),
                      Colors.green.withOpacity(0.08),
                    ]
                  : [
                      _getCompanyColor(product.company).withOpacity(0.1),
                      _getCompanyColor(product.company).withOpacity(0.05),
                    ],
            ),
            border: isBaseline
                ? Border.all(color: Colors.green, width: 3)
                : Border.all(
                    color: _getCompanyColor(product.company).withOpacity(0.3),
                    width: 1,
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 使用最小尺寸，避免溢出
              children: [
                // Logo区域 - 始终显示
                Container(
                  height: 80.0, // 固定高度，避免溢出
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getCompanyColor(product.company),
                        _getCompanyColor(product.company).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getCompanyColor(
                          product.company,
                        ).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      product.company[0],
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 32.0, // 固定字体大小
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 产品名称 - 简化显示逻辑，避免动画导致的溢出
                if (showName)
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                if (showName) const SizedBox(height: 8),

                // 公司标签 - 简化显示逻辑，避免动画导致的溢出
                if (showCompany)
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCompanyColor(
                          product.company,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.company,
                        style: TextStyle(
                          color: _getCompanyColor(product.company),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // 价格 - 简化显示逻辑，避免动画导致的溢出
                if (showPrice && SettingsService.showPrices)
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        SettingsService.formatPrice(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecComparisonTable(List<SpecComparison> comparisons) {
    final productCount = _selectedProducts.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // 智能表格宽度计算策略
        final tableConfig = _calculateTableConfig(screenWidth, productCount);

        if (tableConfig.shouldUseVirtualizedTable) {
          return _buildVirtualizedComparisonTable(comparisons);
        }

        // 使用优化的DataTable
        return _buildOptimizedDataTable(comparisons, tableConfig);
      },
    );
  }

  // 计算表格配置
  TableConfig _calculateTableConfig(double screenWidth, int productCount) {
    // 基础配置
    final specColumnWidth = 150.0; // 规格列固定宽度
    final minColumnWidth = 120.0; // 最小列宽（确保内容可读）
    final maxColumnWidth = 250.0; // 最大列宽
    final columnSpacing = 8.0; // 列间距
    final tablePadding = 32.0; // 表格内边距

    // 计算最小表格宽度（固定最小宽度）
    final minTableWidth =
        specColumnWidth +
        (productCount * minColumnWidth) +
        (productCount + 1) * columnSpacing;

    // 如果最小宽度超过屏幕宽度，强制使用最小宽度并滚动
    if (minTableWidth > screenWidth) {
      return TableConfig(
        columnWidth: minColumnWidth,
        specColumnWidth: specColumnWidth,
        totalTableWidth: minTableWidth,
        needsScrolling: true, // 强制滚动
        shouldUseVirtualizedTable: productCount > 6,
        minColumnWidth: minColumnWidth,
        maxColumnWidth: maxColumnWidth,
      );
    }

    // 宽度不受限时：计算自适应宽度
    final availableWidth = screenWidth - tablePadding;
    final totalColumnSpacing =
        (productCount + 1) * columnSpacing; // +1 for spec column
    final availableForColumns = availableWidth - totalColumnSpacing;

    // 计算自适应列宽
    final adaptiveColumnWidth =
        availableForColumns / (productCount + 1); // +1 for spec column
    final columnWidth = adaptiveColumnWidth.clamp(
      minColumnWidth,
      maxColumnWidth,
    );

    // 计算总表格宽度
    final totalTableWidth =
        specColumnWidth + (productCount * columnWidth) + totalColumnSpacing;

    // 判断是否需要滚动
    final needsScrolling = totalTableWidth > screenWidth;

    // 判断是否使用虚拟化表格（当列数过多或屏幕太小时）
    final shouldUseVirtualizedTable =
        productCount > 6 ||
        (productCount > 4 && screenWidth < 800) ||
        (productCount > 3 && screenWidth < 600);

    return TableConfig(
      columnWidth: columnWidth,
      specColumnWidth: specColumnWidth,
      totalTableWidth: totalTableWidth,
      needsScrolling: needsScrolling,
      shouldUseVirtualizedTable: shouldUseVirtualizedTable,
      minColumnWidth: minColumnWidth,
      maxColumnWidth: maxColumnWidth,
    );
  }

  // 构建优化的DataTable
  Widget _buildOptimizedDataTable(
    List<SpecComparison> comparisons,
    TableConfig config,
  ) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.grey.shade50,
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 500,
            child: config.needsScrolling
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: config.totalTableWidth,
                      child: _buildDataTableContent(comparisons, config),
                    ),
                  )
                : _buildDataTableContent(comparisons, config),
          ),
        ),
      ),
    );
  }

  // 构建DataTable内容
  Widget _buildDataTableContent(
    List<SpecComparison> comparisons,
    TableConfig config,
  ) {
    return DataTable(
      columnSpacing: 8,
      horizontalMargin: 8,
      headingRowColor: MaterialStateProperty.all(
        Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      dataTextStyle: TextStyle(
        fontSize: 12,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      columns: [
        // 规格列
        DataColumn(
          label: SizedBox(
            width: config.specColumnWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '规格参数',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // 产品列
        ..._selectedProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final isBaseline = index == _baselineIndex;

          return DataColumn(
            label: SizedBox(
              width: config.columnWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: isBaseline
                      ? Colors.green.withOpacity(0.2)
                      : _getCompanyColor(product.company).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isBaseline
                      ? Border.all(color: Colors.green, width: 2)
                      : null,
                ),
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: isBaseline
                        ? Colors.green.shade700
                        : _getCompanyColor(product.company),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }),
      ],
      rows: comparisons.asMap().entries.map((entry) {
        final index = entry.key;
        final comparison = entry.value;
        return DataRow(
          color: MaterialStateProperty.all(
            index % 2 == 0
                ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white)
                : (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey.shade50),
          ),
          cells: [
            // 规格名称
            DataCell(
              Container(
                width: config.specColumnWidth,
                constraints: const BoxConstraints(minHeight: 50, maxHeight: 80),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    comparison.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            // 产品值
            ...comparison.values.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              final isBaseline = index == _baselineIndex;

              final product = _selectedProducts.firstWhere(
                (p) => p.id == value.productId,
              );
              final companyColor = _getCompanyColor(product.company);

              // 计算显示值和颜色
              String displayValue = '${value.displayValue}${comparison.unit}';
              Color cellColor = companyColor.withOpacity(0.05);

              if (!isBaseline && _baselineIndex < comparison.values.length) {
                final baselineValue = comparison.values[_baselineIndex];
                if (baselineValue.value != null && value.value != null) {
                  final percentage = _calculatePercentage(
                    baselineValue.value!,
                    value.value!,
                  );
                  if (percentage != null) {
                    displayValue =
                        '${value.displayValue}${comparison.unit}\n$percentage';
                    cellColor = _getPercentageColor(percentage);
                  }
                }
              }

              return DataCell(
                Container(
                  width: config.columnWidth,
                  constraints: const BoxConstraints(
                    minHeight: 50,
                    maxHeight: 80,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isBaseline
                        ? Border.all(color: Colors.green, width: 1)
                        : Border.all(
                            color: companyColor.withOpacity(0.2),
                            width: 1,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      displayValue,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: isBaseline
                            ? Colors.green.shade700
                            : companyColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  // 新增：虚拟化表格，用于处理大量产品对比
  Widget _buildVirtualizedComparisonTable(List<SpecComparison> comparisons) {
    // 计算表格总宽度 - 使用固定最小宽度
    final specColumnWidth = 150.0;
    final minProductColumnWidth = 120.0; // 最小列宽，确保内容可读
    final columnSpacing = 8.0;
    final tablePadding = 32.0;

    // 计算最小表格宽度
    final totalTableWidth =
        specColumnWidth +
        (_selectedProducts.length * minProductColumnWidth) +
        (_selectedProducts.length + 1) * columnSpacing +
        tablePadding;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 500,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalTableWidth,
              child: Column(
                children: [
                  // 产品标题行
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: specColumnWidth,
                          child: const Text(
                            '规格参数',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ..._selectedProducts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final product = entry.value;
                          final isBaseline = index == _baselineIndex;

                          return Container(
                            width: minProductColumnWidth,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isBaseline
                                  ? Colors.green.withOpacity(0.2)
                                  : _getCompanyColor(
                                      product.company,
                                    ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: isBaseline
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: isBaseline
                                      ? Colors.green.shade700
                                      : _getCompanyColor(product.company),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  // 规格对比行
                  ...comparisons.map((comparison) {
                    final comparisonIndex = comparisons.indexOf(comparison);
                    return Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: comparisonIndex % 2 == 0
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white)
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.grey.shade50),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: specColumnWidth,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  comparison.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          ...comparison.values.asMap().entries.map((entry) {
                            final valueIndex = entry.key;
                            final value = entry.value;
                            final isBaseline = valueIndex == _baselineIndex;

                            final product = _selectedProducts.firstWhere(
                              (p) => p.id == value.productId,
                            );
                            final companyColor = _getCompanyColor(
                              product.company,
                            );

                            String displayValue =
                                '${value.displayValue}${comparison.unit}';
                            Color cellColor = companyColor.withOpacity(0.05);

                            if (!isBaseline &&
                                _baselineIndex < comparison.values.length) {
                              final baselineValue =
                                  comparison.values[_baselineIndex];
                              if (baselineValue.value != null &&
                                  value.value != null) {
                                final percentage = _calculatePercentage(
                                  baselineValue.value!,
                                  value.value!,
                                );
                                if (percentage != null) {
                                  displayValue =
                                      '${value.displayValue}${comparison.unit}\n$percentage';
                                  cellColor = _getPercentageColor(percentage);
                                }
                              }
                            }

                            return Container(
                              width: minProductColumnWidth,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(8),
                                border: isBaseline
                                    ? Border.all(color: Colors.green, width: 1)
                                    : Border.all(
                                        color: companyColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                              ),
                              child: Center(
                                child: Text(
                                  displayValue,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    color: isBaseline
                                        ? Colors.green.shade700
                                        : companyColor,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceComparisonTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('价格对比分析', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FutureBuilder<ChartData>(
                      future: DataService.getChartData(
                        'price_comparison',
                        widget.selectedProductIds,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('加载失败: ${snapshot.error}'));
                        }

                        // 使用新的图表数据，传入屏幕尺寸信息
                        return SizedBox(
                          width: screenWidth,
                          height: screenHeight > 400 ? 400 : screenHeight,
                          child: AdvancedCharts.buildPriceComparisonChart(
                            _selectedProducts,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('性能分析', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FutureBuilder<ChartData>(
                      future: DataService.getChartData(
                        'performance_analysis',
                        widget.selectedProductIds,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('加载失败: ${snapshot.error}'));
                        }

                        // 使用新的图表数据，传入屏幕尺寸信息
                        return SizedBox(
                          width: screenWidth,
                          height: screenHeight > 400 ? 400 : screenHeight,
                          child: AdvancedCharts.buildPerformanceRadarChart(
                            _selectedProducts,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 散点分析页面
  Widget _buildScatterAnalysisTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('价格 vs 性能分析', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return FutureBuilder<ChartData>(
                  future: DataService.getChartData(
                    'price_vs_performance',
                    widget.selectedProductIds,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('加载失败: ${snapshot.error}'));
                    }

                    // 使用新的图表数据，传入屏幕尺寸信息
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: screenWidth,
                          height: screenHeight > 400 ? 400 : screenHeight,
                          child: AdvancedCharts.buildPriceVsPerformanceChart(
                            _selectedProducts,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 市场份额页面
  Widget _buildMarketShareTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('市场份额分布', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return FutureBuilder<ChartData>(
                  future: DataService.getChartData(
                    'market_share',
                    widget.selectedProductIds,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('加载失败: ${snapshot.error}'));
                    }

                    // 使用新的图表数据，传入屏幕尺寸信息
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: screenWidth,
                          height: screenHeight > 400 ? 400 : screenHeight,
                          child: AdvancedCharts.buildMarketShareChart(
                            _selectedProducts,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 趋势分析页面
  Widget _buildTrendAnalysisTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('价格趋势分析', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return FutureBuilder<ChartData>(
                  future: DataService.getChartData(
                    'price_trend',
                    widget.selectedProductIds,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('加载失败: ${snapshot.error}'));
                    }

                    // 使用新的图表数据，传入屏幕尺寸信息
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: screenWidth,
                          height: screenHeight > 400 ? 400 : screenHeight,
                          child: AdvancedCharts.buildPriceTrendChart(
                            _selectedProducts,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
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
