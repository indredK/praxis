import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/product.dart' as models;
import '../../data/services/data_service.dart';
import '../../../../features/settings/data/services/settings_service.dart';
import '../widgets/advanced_charts.dart';
import '../viewmodels/product_comparison_viewmodel.dart';
import '../widgets/comparison_data_table.dart';
import '../widgets/sticky_product_cards.dart';

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
  late ProductComparisonViewModel _viewModel;

  // 智能对比提示显示状态
  bool _showSmartComparisonTip = false;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _viewModel = ProductComparisonViewModel();

    // 初始化并加载产品数据
    _viewModel.initialize(widget.productIds);

    // 监听滚动事件
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // 滚动监听方法
  void _onScroll() {
    final offset = _scrollController.offset;
    _viewModel.updateScrollOffset(offset);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductComparisonViewModel>.value(
      value: _viewModel,
      child: Consumer<ProductComparisonViewModel>(
        builder: (context, viewModel, child) {
          // 显示错误信息
          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              viewModel.clearError();
            });
          }

          // 限制产品数量
          final displayProducts = viewModel.displayedProducts.take(10).toList();
          if (viewModel.displayedProducts.length > 10) {
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

          return _buildScaffold(
            context,
            viewModel,
            displayProducts,
            isLoading: viewModel.isLoading,
            hasProducts: viewModel.hasProducts,
          );
        },
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ProductComparisonViewModel viewModel,
    List<models.Product> displayProducts, {
    required bool isLoading,
    required bool hasProducts,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text('产品对比 (${displayProducts.length})'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.8),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 8,
        surfaceTintColor: Colors.transparent,
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
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                // 估算5个标签的最小宽度（每个约80px + padding）
                final minRequiredWidth = 5 * 100.0;
                final needsScrolling = screenWidth < minRequiredWidth;

                return TabBar(
                  controller: _tabController,
                  isScrollable: needsScrolling,
                  tabAlignment: needsScrolling
                      ? TabAlignment.start
                      : TabAlignment.fill,
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  tabs: const [
                    Tab(text: '规格对比'),
                    Tab(text: '性能分析'),
                    Tab(text: '性价比分析'),
                    Tab(text: '价格趋势'),
                    Tab(text: '市场份额'),
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
          _buildPerformanceTab(),
          _buildValueAnalysisTab(),
          _buildTrendAnalysisTab(),
          _buildMarketShareTab(),
        ],
      ),
    );
  }

  Widget _buildSpecComparisonTab() {
    return Consumer<ProductComparisonViewModel>(
      builder: (context, viewModel, child) {
        final comparisons = viewModel.cachedComparisons ?? [];
        final isLoading = viewModel.isLoading;
        final hasProducts = viewModel.hasProducts;
        // 使用实际选中的产品数量，而不是已加载的产品数量
        final productCount = widget.productIds.length;

        return Stack(
          children: [
            // 主要内容区域
            isLoading || !hasProducts
                ? _buildComparisonSkeleton(productCount)
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 产品概览卡片 - 使用新组件
                        ProductOverviewCards(
                          products: viewModel.displayedProducts,
                          baselineIndex: viewModel.baselineIndex,
                          onSetBaseline: (index) =>
                              viewModel.switchBaseline(index),
                        ),
                        const SizedBox(height: 24),

                        // 规格对比标题
                        _buildComparisonHeader(context),
                        const SizedBox(height: 8),

                        // 智能对比提示
                        if (_showSmartComparisonTip)
                          _buildSmartComparisonTip(context),
                        const SizedBox(height: 16),

                        // 规格对比表格 - 使用优化后的组件
                        if (comparisons.isEmpty)
                          const Center(child: Text('暂无对比数据'))
                        else
                          ComparisonDataTable(
                            products: viewModel.displayedProducts,
                            comparisons: comparisons,
                            baselineIndex: viewModel.baselineIndex,
                            onCalculatePercentage:
                                viewModel.calculatePercentage,
                          ),
                      ],
                    ),
                  ),
            // 吸顶的产品卡片 - 使用新组件
            StickyProductCards(
              products: viewModel.displayedProducts,
              baselineIndex: viewModel.baselineIndex,
              isVisible: viewModel.isSticky,
              scrollOffset: viewModel.scrollOffset,
              onSetBaseline: (index) => viewModel.switchBaseline(index),
            ),
          ],
        );
      },
    );
  }

  /// 构建对比标题
  Widget _buildComparisonHeader(BuildContext context) {
    return Row(
      children: [
        Text('详细规格对比', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _showSmartComparisonTip = !_showSmartComparisonTip;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
    );
  }

  /// 构建智能对比提示
  Widget _buildSmartComparisonTip(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade900.withValues(alpha: 0.3)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueAnalysisTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Consumer<ProductComparisonViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('性价比分析', style: Theme.of(context).textTheme.headlineSmall),
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
                            'price_vs_performance',
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
                              return Center(
                                child: Text('加载失败: ${snapshot.error}'),
                              );
                            }

                            return SizedBox(
                              width: screenWidth,
                              height: screenHeight > 400 ? 400 : screenHeight,
                              child:
                                  AdvancedCharts.buildPriceVsPerformanceChart(
                                    viewModel.displayedProducts,
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
      },
    );
  }

  Widget _buildPerformanceTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Consumer<ProductComparisonViewModel>(
      builder: (context, viewModel, child) {
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
                              return Center(
                                child: Text('加载失败: ${snapshot.error}'),
                              );
                            }

                            return SizedBox(
                              width: screenWidth,
                              height: screenHeight > 400 ? 400 : screenHeight,
                              child: AdvancedCharts.buildPerformanceRadarChart(
                                viewModel.displayedProducts,
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
      },
    );
  }

  Widget _buildMarketShareTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Consumer<ProductComparisonViewModel>(
      builder: (context, viewModel, child) {
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('加载失败: ${snapshot.error}'));
                        }

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
                                viewModel.displayedProducts,
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
      },
    );
  }

  Widget _buildTrendAnalysisTab() {
    if (!SettingsService.showCharts) {
      return const Center(
        child: Text('图表显示已关闭', style: TextStyle(fontSize: 16)),
      );
    }

    return Consumer<ProductComparisonViewModel>(
      builder: (context, viewModel, child) {
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('加载失败: ${snapshot.error}'));
                        }

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
                                viewModel.displayedProducts,
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
      },
    );
  }

  /// 对比页面骨架屏
  Widget _buildComparisonSkeleton(int productCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 产品卡片骨架 - 自适应布局
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              const cardSpacing = 16.0;
              final totalSpacing = (productCount - 1) * cardSpacing;
              final availableWidth = screenWidth;

              final adaptiveCardWidth =
                  (availableWidth - totalSpacing) / productCount;
              const minCardWidth = 150.0;
              const maxCardWidth = 300.0;
              final cardWidth = adaptiveCardWidth.clamp(
                minCardWidth,
                maxCardWidth,
              );

              // 判断是否需要滚动
              final totalWidth = (cardWidth * productCount) + totalSpacing;
              final needsScrolling = totalWidth > availableWidth;

              if (needsScrolling) {
                // 需要滚动
                return SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productCount,
                    itemBuilder: (context, index) {
                      return Container(
                        width: cardWidth,
                        margin: EdgeInsets.only(
                          right: index < productCount - 1 ? cardSpacing : 0,
                        ),
                        child: _buildProductCardSkeleton(),
                      );
                    },
                  ),
                );
              } else {
                // 不需要滚动，自适应
                return SizedBox(
                  height: 160,
                  child: Row(
                    children: List.generate(productCount, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: cardSpacing / 2,
                          ),
                          child: _buildProductCardSkeleton(),
                        ),
                      );
                    }),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // 规格对比标题骨架
          _buildShimmer(
            child: Container(
              height: 28,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 表格骨架 - 模拟真实表格结构
          _buildTableSkeleton(productCount),
        ],
      ),
    );
  }

  /// 产品卡片骨架
  Widget _buildProductCardSkeleton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 头像骨架
              _buildShimmer(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 产品名和公司骨架
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 6),
                    _buildShimmer(
                      child: Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 复选框骨架
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
          const SizedBox(height: 16),
          // 价格骨架
          _buildShimmer(
            child: Container(
              height: 18,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 标签骨架
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildShimmer(
                child: Container(
                  height: 24,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              _buildShimmer(
                child: Container(
                  height: 24,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 表格骨架
  Widget _buildTableSkeleton(int productCount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头骨架 - 根据产品数量生成列
          Row(
            children: [
              // 规格列
              _buildShimmer(
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // 产品列
              ...List.generate(productCount, (index) {
                return [
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildShimmer(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ];
              }).expand((e) => e).toList(),
            ],
          ),
          const SizedBox(height: 12),
          // 表格行骨架 - 根据产品数量生成列
          ...List.generate(5, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // 规格名称列
                  _buildShimmer(
                    child: Container(
                      width: 100,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  // 产品值列
                  ...List.generate(productCount, (colIndex) {
                    return [
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildShimmer(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ];
                  }).expand((e) => e).toList(),
                ],
              ),
            );
          }),
        ],
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
        if (mounted) {
          setState(() {});
        }
      },
      child: child,
    );
  }
}
