import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../config/app_config.dart';
import '../widgets/advanced_charts.dart';

class ProductComparisonScreen extends StatefulWidget {
  final List<String> selectedProductIds;

  const ProductComparisonScreen({super.key, required this.selectedProductIds});

  @override
  State<ProductComparisonScreen> createState() =>
      _ProductComparisonScreenState();
}

class _ProductComparisonScreenState extends State<ProductComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Product> _selectedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadSelectedProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await DataService.getAllProducts();
      setState(() {
        _selectedProducts = products
            .where((product) => widget.selectedProductIds.contains(product.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载产品数据失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('产品对比'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final tabCount = 6; // 标签数量

              // 计算每个标签的宽度
              final tabWidth = screenWidth / tabCount;
              final isScrollable = tabWidth < 120; // 如果标签宽度小于120px，则启用滚动

              return TabBar(
                controller: _tabController,
                isScrollable: isScrollable,
                tabAlignment: isScrollable
                    ? TabAlignment.start
                    : TabAlignment.fill,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  fontSize: isScrollable ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: isScrollable ? 11 : 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    text: isScrollable ? '规格' : '规格对比',
                    icon: Icon(Icons.table_chart, size: isScrollable ? 16 : 20),
                  ),
                  Tab(
                    text: isScrollable ? '价格' : '价格对比',
                    icon: Icon(
                      Icons.attach_money,
                      size: isScrollable ? 16 : 20,
                    ),
                  ),
                  Tab(
                    text: isScrollable ? '性能' : '性能分析',
                    icon: Icon(Icons.radar, size: isScrollable ? 16 : 20),
                  ),
                  Tab(
                    text: isScrollable ? '散点' : '散点分析',
                    icon: Icon(
                      Icons.scatter_plot,
                      size: isScrollable ? 16 : 20,
                    ),
                  ),
                  Tab(
                    text: isScrollable ? '份额' : '市场份额',
                    icon: Icon(Icons.pie_chart, size: isScrollable ? 16 : 20),
                  ),
                  Tab(
                    text: isScrollable ? '趋势' : '趋势分析',
                    icon: Icon(Icons.trending_up, size: isScrollable ? 16 : 20),
                  ),
                ],
              );
            },
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
    // 使用异步加载获取对比数据
    return FutureBuilder<List<SpecComparison>>(
      future: DataService.getProductComparison(widget.selectedProductIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('加载失败: ${snapshot.error}'));
        }

        final comparisons = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 产品概览卡片
              _buildProductOverviewCards(),
              const SizedBox(height: 24),

              // 规格对比表格
              Text('详细规格对比', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),

              if (comparisons.isEmpty)
                const Center(child: Text('暂无对比数据'))
              else
                _buildSpecComparisonTable(comparisons),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductOverviewCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕宽度和产品数量计算卡片尺寸
        final screenWidth = constraints.maxWidth;
        final productCount = _selectedProducts.length;

        // 智能布局策略
        Widget layoutWidget;

        if (productCount <= 2 && screenWidth > 600) {
          // 2个产品且屏幕足够大：使用网格布局
          layoutWidget = Row(
            children: _selectedProducts.map((product) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildProductCard(product, screenWidth * 0.4, 280.0),
                ),
              );
            }).toList(),
          );
        } else if (productCount <= 3 && screenWidth > 800) {
          // 3个产品且屏幕足够大：使用网格布局
          layoutWidget = Row(
            children: _selectedProducts.map((product) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildProductCard(product, screenWidth * 0.3, 260.0),
                ),
              );
            }).toList(),
          );
        } else if (productCount <= 4 && screenWidth > 1200) {
          // 4个产品且大屏幕：使用网格布局
          layoutWidget = Row(
            children: _selectedProducts.map((product) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildProductCard(product, screenWidth * 0.22, 240.0),
                ),
              );
            }).toList(),
          );
        } else {
          // 其他情况：使用水平滚动布局
          final cardWidth = screenWidth > 600 ? 200.0 : screenWidth * 0.7;
          final cardHeight = screenWidth > 600 ? 280.0 : 240.0;

          layoutWidget = ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _selectedProducts.length,
            itemBuilder: (context, index) {
              final product = _selectedProducts[index];
              return Container(
                width: cardWidth,
                margin: const EdgeInsets.only(right: 16),
                child: _buildProductCard(product, cardWidth, cardHeight),
              );
            },
          );
        }

        return layoutWidget;
      },
    );
  }

  // 构建单个产品卡片
  Widget _buildProductCard(Product product, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
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
                _getCompanyColor(product.company).withOpacity(0.1),
                _getCompanyColor(product.company).withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 产品图片占位符
                Container(
                  height: height * 0.4,
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
                        fontSize: height * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 产品名称
                Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: height * 0.06,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // 公司
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCompanyColor(product.company).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.company,
                    style: TextStyle(
                      color: _getCompanyColor(product.company),
                      fontSize: height * 0.05,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),

                // 价格
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SettingsService.showPrices
                      ? Text(
                          SettingsService.formatPrice(product.price),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: height * 0.07,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecComparisonTable(List<SpecComparison> comparisons) {
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
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final productCount = _selectedProducts.length;

            // 计算列宽：根据屏幕宽度和产品数量
            double columnWidth;
            if (screenWidth > 1200) {
              // 大屏幕：可以显示更多列
              columnWidth = (screenWidth - 200) / (productCount + 1);
            } else if (screenWidth > 800) {
              // 中等屏幕
              columnWidth = (screenWidth - 150) / (productCount + 1);
            } else {
              // 小屏幕：固定最小宽度
              columnWidth = 120.0;
            }

            // 确保列宽在合理范围内
            columnWidth = columnWidth.clamp(100.0, 200.0);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: 200,
                ),
                child: DataTable(
                  columnSpacing: 8,
                  horizontalMargin: 16,
                  headingRowColor: MaterialStateProperty.all(
                    Colors.blue.withOpacity(0.1),
                  ),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '规格参数',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    ..._selectedProducts.map(
                      (product) => DataColumn(
                        label: SizedBox(
                          width: columnWidth,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getCompanyColor(
                                product.company,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _getCompanyColor(product.company),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: comparisons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final comparison = entry.value;
                    return DataRow(
                      color: MaterialStateProperty.all(
                        index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                      ),
                      cells: [
                        DataCell(
                          SizedBox(
                            width: columnWidth,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                comparison.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        ...comparison.values.map(
                          (value) => DataCell(
                            SizedBox(
                              width: columnWidth,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCompanyColor(
                                    value.productName,
                                  ).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getCompanyColor(
                                      value.productName,
                                    ).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${value.displayValue}${comparison.unit}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                    color: _getCompanyColor(value.productName),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
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
