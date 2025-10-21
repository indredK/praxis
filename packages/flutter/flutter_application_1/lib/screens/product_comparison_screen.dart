import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../services/global_data_cache.dart';
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

  // 基准对比功能：第一个产品作为基准
  int _baselineIndex = 0;

  // 智能对比提示显示状态
  bool _showSmartComparisonTip = false;

  // 预加载的对比数据缓存
  List<SpecComparison>? _cachedComparisons;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0), // TabBar的标准高度
          child: Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // 强制启用滚动，确保显示
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: '规格', icon: Icon(Icons.table_chart)),
                Tab(text: '价格', icon: Icon(Icons.attach_money)),
                Tab(text: '性能', icon: Icon(Icons.radar)),
                Tab(text: '散点', icon: Icon(Icons.scatter_plot)),
                Tab(text: '份额', icon: Icon(Icons.pie_chart)),
                Tab(text: '趋势', icon: Icon(Icons.trending_up)),
              ],
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

    return SingleChildScrollView(
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
              Text('详细规格对比', style: Theme.of(context).textTheme.headlineSmall),
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
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
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
                        color: Theme.of(context).textTheme.bodyMedium?.color,
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
    );
  }

  Widget _buildProductOverviewCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕宽度和产品数量计算卡片尺寸
        final screenWidth = constraints.maxWidth;
        final productCount = _selectedProducts.length;

        // 优化布局策略：避免列数过多导致的渲染问题
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
        } else {
          // 超过3个产品或屏幕不够大：强制使用水平滚动布局
          // 这样可以避免列数过多导致的渲染问题
          final cardWidth = screenWidth > 600 ? 200.0 : screenWidth * 0.7;
          final cardHeight = screenWidth > 600 ? 280.0 : 240.0;

          layoutWidget = SizedBox(
            height: cardHeight + 32, // 添加额外高度给滚动条
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
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildProductCard(product, cardWidth, cardHeight),
                  ),
                );
              },
            ),
          );
        }

        return layoutWidget;
      },
    );
  }

  // 构建单个产品卡片
  Widget _buildProductCard(Product product, double width, double height) {
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
          width: width, // 明确指定宽度
          height: height, // 明确指定高度
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
            border: isBaseline
                ? Border.all(color: Colors.green, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              Positioned.fill(
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
                              _getCompanyColor(
                                product.company,
                              ).withOpacity(0.7),
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
                      Flexible(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: height * 0.06,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 公司
                      Container(
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
              // 基准选择按钮 - 右下角
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    _switchBaseline(productIndex);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isBaseline
                          ? Colors.green
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isBaseline
                            ? Colors.green.shade700
                            : Colors.grey.shade400,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isBaseline ? Icons.check : Icons.radio_button_unchecked,
                        key: ValueKey(isBaseline),
                        color: isBaseline ? Colors.white : Colors.grey.shade600,
                        size: 16,
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

  Widget _buildSpecComparisonTable(List<SpecComparison> comparisons) {
    // 优化：根据屏幕宽度和产品数量智能选择表格类型
    final productCount = _selectedProducts.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // 智能判断：根据屏幕宽度和产品数量决定使用哪种表格
        bool shouldUseVirtualizedTable = false;

        if (productCount > 4) {
          // 超过4个产品：强制使用虚拟化表格
          shouldUseVirtualizedTable = true;
        } else if (productCount > 3 && screenWidth < 1000) {
          // 4个产品且屏幕不够宽：使用虚拟化表格
          shouldUseVirtualizedTable = true;
        } else if (productCount == 3 && screenWidth < 800) {
          // 3个产品且屏幕很窄：使用虚拟化表格
          shouldUseVirtualizedTable = true;
        }

        if (shouldUseVirtualizedTable) {
          return _buildVirtualizedComparisonTable(comparisons);
        }

        // 使用标准DataTable
        return Card(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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

                // 优化列宽计算：避免列过窄
                double columnWidth = (screenWidth - 200) / (productCount + 1);
                columnWidth = columnWidth.clamp(120.0, 180.0);

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: 400,
                    ),
                    child: DataTable(
                      columnSpacing: 4,
                      horizontalMargin: 8,
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
                        ..._selectedProducts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final product = entry.value;
                          final isBaseline = index == _baselineIndex;

                          return DataColumn(
                            label: SizedBox(
                              width: columnWidth,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isBaseline
                                      ? Colors.green.withOpacity(0.2)
                                      : _getCompanyColor(
                                          product.company,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isBaseline
                                      ? Border.all(
                                          color: Colors.green,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
                            index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                          ),
                          cells: [
                            DataCell(
                              Container(
                                width: columnWidth,
                                constraints: const BoxConstraints(
                                  minHeight: 50,
                                  maxHeight: 80,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
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
                            ...comparison.values.asMap().entries.map((entry) {
                              final index = entry.key;
                              final value = entry.value;
                              final isBaseline = index == _baselineIndex;

                              // 优化：缓存产品查找结果
                              final product = _selectedProducts.firstWhere(
                                (p) => p.id == value.productId,
                              );
                              final companyColor = _getCompanyColor(
                                product.company,
                              );

                              // 计算相对于基准的百分比
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

                              return DataCell(
                                Container(
                                  width: columnWidth,
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
                                        ? Border.all(
                                            color: Colors.green,
                                            width: 1,
                                          )
                                        : Border.all(
                                            color: companyColor.withOpacity(
                                              0.2,
                                            ),
                                            width: 1,
                                          ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      displayValue,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11,
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
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 新增：虚拟化表格，用于处理大量产品对比
  Widget _buildVirtualizedComparisonTable(List<SpecComparison> comparisons) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 400, // 固定高度，避免尺寸约束问题
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
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
                    width: 150,
                    child: const Text(
                      '规格参数',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60, // 明确指定高度
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedProducts.length,
                        itemBuilder: (context, index) {
                          final product = _selectedProducts[index];
                          final isBaseline = index == _baselineIndex;

                          return Container(
                            width: 120,
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
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 规格对比行
            Expanded(
              child: ListView.builder(
                itemCount: comparisons.length,
                itemBuilder: (context, comparisonIndex) {
                  final comparison = comparisons[comparisonIndex];
                  return Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: comparisonIndex % 2 == 0
                          ? Colors.white
                          : Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
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
                        Expanded(
                          child: SizedBox(
                            height: 60, // 明确指定高度
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: comparison.values.length,
                              itemBuilder: (context, valueIndex) {
                                final value = comparison.values[valueIndex];
                                final isBaseline = valueIndex == _baselineIndex;

                                // 优化：缓存产品查找结果
                                final product = _selectedProducts.firstWhere(
                                  (p) => p.id == value.productId,
                                );
                                final companyColor = _getCompanyColor(
                                  product.company,
                                );

                                // 计算显示值
                                String displayValue =
                                    '${value.displayValue}${comparison.unit}';
                                Color cellColor = companyColor.withOpacity(
                                  0.05,
                                );

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
                                      cellColor = _getPercentageColor(
                                        percentage,
                                      );
                                    }
                                  }
                                }

                                return Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isBaseline
                                        ? Border.all(
                                            color: Colors.green,
                                            width: 1,
                                          )
                                        : Border.all(
                                            color: companyColor.withOpacity(
                                              0.2,
                                            ),
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
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
