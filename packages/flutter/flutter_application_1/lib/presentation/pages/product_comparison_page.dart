import 'package:flutter/material.dart';
import '../../models/product.dart' as models;
import '../../services/data_service.dart';
import '../../features/settings/data/services/settings_service.dart';
import '../../services/global_data_cache.dart';
import '../../config/app_config.dart';
import '../../widgets/advanced_charts.dart';

// 产品卡片配置常量
class ProductCardConfig {
  // 高度配置
  static const double maxCardHeight = 270.0; // 最高高度限制
  static const double minCardHeight = 150.0; // 最低高度限制

  // 基础高度配置
  static const double cardPadding = 32.0; // Card padding (16px * 2)
  static const double logoHeight = 80.0; // Logo区域高度
  static const double logoSpacing = 10.0; // Logo后间距

  // 内容区域高度配置
  static const double nameHeight = 50.0; // 产品名称区域高度
  static const double nameSpacing = 12.0; // 名称后间距
  static const double companyHeight = 40.0; // 公司标签区域高度
  static const double companySpacing = 12.0; // 标签后间距
  static const double priceHeight = 50.0; // 价格区域高度

  // 压缩阈值配置
  static const double nameThreshold = 0.2; // 产品名称显示阈值
  static const double companyThreshold = 0.1; // 公司标签显示阈值
  static const double priceThreshold = 0.15; // 价格显示阈值
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

class ProductComparisonPage extends StatefulWidget {
  final List<String> productIds;
  final VoidCallback onBackPressed;

  const ProductComparisonPage({
    super.key,
    required this.productIds,
    required this.onBackPressed,
  });

  @override
  State<ProductComparisonPage> createState() => _ProductComparisonPageState();
}

class _ProductComparisonPageState extends State<ProductComparisonPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<models.Product> _selectedProducts = [];
  bool _isLoading = true;

  // 基准对比功能：第一个产品作为基准
  int _baselineIndex = 0;

  // 智能对比提示显示状态
  bool _showSmartComparisonTip = false;

  // 预加载的对比数据缓存
  List<models.SpecComparison>? _cachedComparisons;

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
      return Colors.red.withValues(alpha: 0.1);
    } else if (percentage.startsWith('-')) {
      return Colors.blue.withValues(alpha: 0.1);
    } else {
      return Colors.grey.withValues(alpha: 0.1);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
      List<models.Product> products;
      if (GlobalDataCache.getProducts() != null) {
        products = GlobalDataCache.getProducts()!;
      } else {
        final dataServiceProducts = await DataService.getAllProducts();
        products = dataServiceProducts.cast<models.Product>();
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
      final limitedProductIds = widget.productIds.take(15).toList();

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
      }
    } catch (e) {}
  }

  // 无缝切换基准
  void _switchBaseline(int newBaselineIndex) {
    if (newBaselineIndex == _baselineIndex) return;

    setState(() {
      _baselineIndex = newBaselineIndex;
      // 对比数据相同，只是显示方式不同，无需重新加载
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
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 8,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.9),
                Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
          ),
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
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.3),
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
                        ? Colors.blue.shade900.withValues(alpha: 0.3)
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
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
              Theme.of(context).scaffoldBackgroundColor.withValues(
                alpha: 0.95 + opacity * 0.05,
              ),
              Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.85 + opacity * 0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                                  Colors.green.withValues(alpha: 0.2),
                                  Colors.green.withValues(alpha: 0.1),
                                ]
                              : [
                                  _getCompanyColor(
                                    product.company,
                                  ).withValues(alpha: 0.2),
                                  _getCompanyColor(
                                    product.company,
                                  ).withValues(alpha: 0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: isBaseline
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(
                                color: _getCompanyColor(
                                  product.company,
                                ).withValues(alpha: 0.3),
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
                                        ).withValues(alpha: 0.7),
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
                                    : Colors.grey.withValues(alpha: 0.3),
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
                                  Colors.green.withValues(alpha: 0.2),
                                  Colors.green.withValues(alpha: 0.1),
                                ]
                              : [
                                  _getCompanyColor(
                                    product.company,
                                  ).withValues(alpha: 0.2),
                                  _getCompanyColor(
                                    product.company,
                                  ).withValues(alpha: 0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: isBaseline
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(
                                color: _getCompanyColor(
                                  product.company,
                                ).withValues(alpha: 0.3),
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
                                        ).withValues(alpha: 0.7),
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
                                    : Colors.grey.withValues(alpha: 0.3),
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
        final compressionRatio = cardWidth / maxCardWidth;
        final cardHeight =
            (minCardHeight + (maxCardHeight - minCardHeight) * compressionRatio)
                .clamp(minCardHeight, maxCardHeight);

        // 判断是否需要滚动
        final totalRequiredWidth = (cardWidth * productCount) + totalSpacing;
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
                  height: cardHeight,
                  margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
                  child: _buildProductCard(product, isBaseline, cardHeight),
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
                  height: cardHeight,
                  margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
                  child: _buildProductCard(product, isBaseline, cardHeight),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildProductCard(
    models.Product product,
    bool isBaseline,
    double cardHeight,
  ) {
    return Card(
      elevation: isBaseline ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isBaseline
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide(
                color: _getCompanyColor(product.company).withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isBaseline
                ? [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ]
                : [
                    _getCompanyColor(product.company).withValues(alpha: 0.1),
                    _getCompanyColor(product.company).withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 产品头像和名称
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                                ).withValues(alpha: 0.7),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        product.company[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isBaseline
                                ? Colors.green.shade700
                                : _getCompanyColor(product.company),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.company,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 基准按钮
                  GestureDetector(
                    onTap: () =>
                        _switchBaseline(_selectedProducts.indexOf(product)),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isBaseline
                            ? Colors.green
                            : Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isBaseline
                              ? Colors.green.shade700
                              : Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isBaseline ? Icons.check : Icons.radio_button_unchecked,
                        color: isBaseline ? Colors.white : Colors.grey.shade600,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 价格信息
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBaseline
                      ? Colors.green.withValues(alpha: 0.1)
                      : _getCompanyColor(
                          product.company,
                        ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '¥${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isBaseline
                        ? Colors.green.shade700
                        : _getCompanyColor(product.company),
                  ),
                ),
              ),
              const Spacer(),
              // 基准标签
              if (isBaseline)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '基准产品',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecComparisonTable(List<models.SpecComparison> comparisons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final productCount = _selectedProducts.length;

        // 计算表格配置
        final config = _calculateTableConfig(screenWidth, productCount);

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
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              width: 1,
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
        );
      },
    );
  }

  // 计算表格配置
  TableConfig _calculateTableConfig(double screenWidth, int productCount) {
    const double specColumnWidth = 150.0;
    const double minProductColumnWidth = 120.0;
    const double columnSpacing = 8.0;
    const double tablePadding = 32.0;

    // 计算最小表格宽度
    final totalTableWidth =
        specColumnWidth +
        (productCount * minProductColumnWidth) +
        (productCount + 1) * columnSpacing +
        tablePadding;

    // 判断是否需要滚动
    final needsScrolling = totalTableWidth > screenWidth;

    return TableConfig(
      columnWidth: minProductColumnWidth,
      specColumnWidth: specColumnWidth,
      totalTableWidth: totalTableWidth,
      needsScrolling: needsScrolling,
      shouldUseVirtualizedTable: productCount > 8,
      minColumnWidth: minProductColumnWidth,
      maxColumnWidth: 200.0,
    );
  }

  // 构建DataTable内容
  Widget _buildDataTableContent(
    List<models.SpecComparison> comparisons,
    TableConfig config,
  ) {
    return DataTable(
      columnSpacing: 8,
      horizontalMargin: 8,
      headingRowColor: MaterialStateProperty.all(
        Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                      ? Colors.green.withValues(alpha: 0.2)
                      : _getCompanyColor(
                          product.company,
                        ).withValues(alpha: 0.1),
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
                orElse: () => _selectedProducts.first, // 如果找不到，使用第一个产品
              );
              final companyColor = _getCompanyColor(product.company);

              // 计算显示值和颜色
              String displayValue = '${value.displayValue}${comparison.unit}';
              Color cellColor = companyColor.withValues(alpha: 0.05);

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
                            color: companyColor.withValues(alpha: 0.2),
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
                    child: FutureBuilder<models.ChartData>(
                      future: DataService.getChartData(
                        'price_comparison',
                        widget.productIds,
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
                    child: FutureBuilder<models.ChartData>(
                      future: DataService.getChartData(
                        'performance_analysis',
                        widget.productIds,
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

                return FutureBuilder<models.ChartData>(
                  future: DataService.getChartData(
                    'price_vs_performance',
                    widget.productIds,
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

                return FutureBuilder<models.ChartData>(
                  future: DataService.getChartData(
                    'market_share',
                    widget.productIds,
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

                return FutureBuilder<models.ChartData>(
                  future: DataService.getChartData(
                    'price_trend',
                    widget.productIds,
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
