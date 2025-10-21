import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../services/global_data_cache.dart';
import '../config/app_config.dart';
import 'product_comparison_screen.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final Set<String> _selectedProductIds = {};

  // 当前选中的产品（用于图钉显示）
  Product? _currentSelectedProduct;

  // 对比模式：'same_brand' 自家对比, 'same_category' 同类对比
  String _comparisonMode = 'same_brand';

  // 自家对比模式的选择
  String _selectedCompany = '全部';
  String _selectedCategory = '全部';
  String _selectedProduct = '全部';

  // 同类对比模式的选择
  String _selectedCategoryForComparison = '全部';
  String _selectedProductForComparison = '全部';

  List<Product> _products = [];
  List<String> _categories = [];
  List<String> _companies = [];
  List<String> _productsForCompany = [];
  List<String> _productsForCategory = [];
  bool _isLoading = true;

  // 缓存过滤结果，避免重复计算
  List<Product>? _cachedFilteredProducts;
  String? _lastFilterKey;

  // 缓存产品列表，避免重复创建（现在使用全局缓存）
  // List<Product>? _cachedProducts;

  @override
  void initState() {
    super.initState();
    // 数据已在app启动时预加载，直接加载
    _loadData();
  }

  @override
  void dispose() {
    // 清理缓存，避免内存泄漏
    _cachedFilteredProducts = null;
    _lastFilterKey = null;
    super.dispose();
  }

  Future<void> _loadData() async {
    print('🚀 开始加载数据');

    // 立即设置静态数据，无需等待
    _categories = ['全部', ...DataService.getAllCategories()];
    _companies = ['全部', ...DataService.getAllCompanies()];
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
    if (_comparisonMode == 'same_brand') {
      // 自家对比模式：根据选择的公司和类别更新产品列表
      if (_selectedCompany != '全部' && _selectedCategory != '全部') {
        _productsForCompany = _products
            .where(
              (p) =>
                  p.company == _selectedCompany &&
                  p.category == _selectedCategory,
            )
            .map((p) => p.name)
            .toList();
        _productsForCompany.insert(0, '全部');
      } else {
        _productsForCompany = ['全部'];
      }
    } else {
      // 同类对比模式：根据选择的类别更新产品列表
      if (_selectedCategoryForComparison != '全部') {
        _productsForCategory = _products
            .where((p) => p.category == _selectedCategoryForComparison)
            .map((p) => p.name)
            .toList();
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
          if (_selectedProductIds.isNotEmpty)
            TextButton(
              onPressed: _selectedProductIds.length >= 2
                  ? () => _navigateToComparison()
                  : null,
              child: Text(
                '对比 (${_selectedProductIds.length})',
                style: TextStyle(
                  color: _selectedProductIds.length >= 2
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 对比模式选择
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'same_brand',
                        label: Text('自家产品对比'),
                        icon: Icon(Icons.business),
                      ),
                      ButtonSegment<String>(
                        value: 'same_category',
                        label: Text('同类产品对比'),
                        icon: Icon(Icons.category),
                      ),
                    ],
                    selected: {_comparisonMode},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _comparisonMode = selection.first;
                        _selectedProductIds.clear();
                        _updateProductLists();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 筛选器
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildFilterSection(),
          ),

          const Divider(height: 1),

          // 产品列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemExtent: 132, // 固定高度：120 + 12(margin)
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final isSelected = _selectedProductIds.contains(product.id);
                final companyColor = _getCompanyColor(product.company);

                return Card(
                  elevation: isSelected ? 12 : 4,
                  shadowColor: isSelected
                      ? companyColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? companyColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    height: 120, // 固定高度，让一页显示5个产品
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? companyColor.withOpacity(0.1)
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.white,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          // 更新当前选中的产品（用于图钉显示）
                          _currentSelectedProduct = product;

                          if (isSelected) {
                            _selectedProductIds.remove(product.id);
                          } else {
                            // 检查是否超过最大选择数量
                            if (_selectedProductIds.length < 5) {
                              _selectedProductIds.add(product.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('最多只能选择5个产品进行对比'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // 左侧：公司logo
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: companyColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: companyColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  AppConfig.getCompanyLogo(product.company),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 中间：产品信息
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 产品名称
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? _getCompanyColor(product.company)
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // 公司名称
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: companyColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      product.company,
                                      style: TextStyle(
                                        color: companyColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // 类别和更新时间
                                  Row(
                                    children: [
                                      Text(
                                        product.category,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.color,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.color,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatUpdateTime(product.releaseDate),
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.color,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // 价格
                                  if (SettingsService.showPrices)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        SettingsService.formatPrice(
                                          product.price,
                                        ),
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.green.shade300
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 右侧：选择框
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getCompanyColor(product.company)
                                    : Theme.of(context).brightness ==
                                          Brightness.dark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
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
                                      _selectedProductIds.add(product.id);
                                    } else {
                                      _selectedProductIds.remove(product.id);
                                    }
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 底部操作栏
      bottomNavigationBar: _selectedProductIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade200, Colors.grey.shade300],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedProductIds.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          '清空选择',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: _selectedProductIds.length >= 2
                            ? LinearGradient(
                                colors: [Colors.blue, Colors.blue.shade700],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade400,
                                  Colors.grey.shade500,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: _selectedProductIds.length >= 2
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: _selectedProductIds.length >= 2
                            ? () => _navigateToComparison()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          _selectedProductIds.length >= 2
                              ? '开始${_comparisonMode == 'same_brand' ? '自家' : '同类'}对比 (${_selectedProductIds.length}个产品)'
                              : '至少选择2个产品',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // 构建筛选器界面
  Widget _buildFilterSection() {
    if (_comparisonMode == 'same_brand') {
      // 自家对比模式：公司 → 类别 → 产品
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择公司',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedCompany,
                      isExpanded: true,
                      items: _companies.map((company) {
                        return DropdownMenuItem(
                          value: company,
                          child: Row(
                            children: [
                              Text(
                                company == '全部'
                                    ? '🏢'
                                    : AppConfig.getCompanyLogo(company),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  company,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCompany = value!;
                          _selectedCategory = '全部';
                          _selectedProduct = '全部';
                          _selectedProductIds.clear();
                          _updateProductLists();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择类别',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Text(
                                category == '全部'
                                    ? '📦'
                                    : AppConfig.getCategoryLogo(category),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _selectedCompany != '全部'
                          ? (value) {
                              setState(() {
                                _selectedCategory = value!;
                                _selectedProduct = '全部';
                                _selectedProductIds.clear();
                                _updateProductLists();
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedCompany != '全部' && _selectedCategory != '全部') ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择产品',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedProduct,
                  isExpanded: true,
                  items: _productsForCompany.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Row(
                        children: [
                          Text(
                            product == '全部' ? '📦' : '🛍️',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProduct = value!;
                      _selectedProductIds.clear();
                      if (value != '全部') {
                        final product = _products.firstWhere(
                          (p) =>
                              p.name == value &&
                              p.company == _selectedCompany &&
                              p.category == _selectedCategory,
                        );
                        _selectedProductIds.add(product.id);
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ],
      );
    } else {
      // 同类对比模式：类别 → 产品
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择类别',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedCategoryForComparison,
                      isExpanded: true,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Text(
                                category == '全部'
                                    ? '📦'
                                    : AppConfig.getCategoryLogo(category),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryForComparison = value!;
                          _selectedProductForComparison = '全部';
                          _selectedProductIds.clear();
                          _updateProductLists();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择产品',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedProductForComparison,
                      isExpanded: true,
                      items: _productsForCategory.map((product) {
                        return DropdownMenuItem(
                          value: product,
                          child: Row(
                            children: [
                              Text(
                                product == '全部' ? '📦' : '🛍️',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _selectedCategoryForComparison != '全部'
                          ? (value) {
                              setState(() {
                                _selectedProductForComparison = value!;
                                _selectedProductIds.clear();
                                if (value != '全部') {
                                  final product = _products.firstWhere(
                                    (p) =>
                                        p.name == value &&
                                        p.category ==
                                            _selectedCategoryForComparison,
                                  );
                                  _selectedProductIds.add(product.id);
                                }
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  List<Product> _getFilteredProducts() {
    // 生成缓存键
    final filterKey =
        '${_comparisonMode}_${_selectedCompany}_${_selectedCategoryForComparison}';

    // 如果过滤条件没有变化，返回缓存结果
    if (_cachedFilteredProducts != null && _lastFilterKey == filterKey) {
      return _cachedFilteredProducts!;
    }

    List<Product> result;
    if (_comparisonMode == 'same_brand') {
      // 自家对比模式：显示选中公司的所有产品
      if (_selectedCompany != '全部') {
        result = _products.where((p) => p.company == _selectedCompany).toList();
      } else {
        result = [];
      }
    } else {
      // 同类对比模式：显示选中类别的所有产品
      if (_selectedCategoryForComparison != '全部') {
        result = _products
            .where((p) => p.category == _selectedCategoryForComparison)
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductComparisonScreen(
          selectedProductIds: _selectedProductIds.toList(),
        ),
      ),
    );
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
    return FloatingActionButton(
      onPressed: _showProductInfo,
      backgroundColor: _currentSelectedProduct != null
          ? _getCompanyColor(_currentSelectedProduct!.company)
          : Theme.of(context).primaryColor,
      child: Icon(
        _currentSelectedProduct != null ? Icons.info : Icons.help,
        color: Colors.white,
      ),
    );
  }

  // 显示产品信息或操作提示
  void _showProductInfo() {
    if (_currentSelectedProduct != null) {
      _showProductDetails(_currentSelectedProduct!);
    } else {
      _showOperationTips();
    }
  }

  // 显示产品详细信息
  void _showProductDetails(Product product) {
    final companyColor = _getCompanyColor(product.company);
    final isSelected = _selectedProductIds.contains(product.id);

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
                          const SizedBox(height: 4),
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
                      const SizedBox(height: 16),
                      // 规格信息卡片
                      _buildInfoCard(
                        '主要规格',
                        product.specs.entries
                            .take(5)
                            .map(
                              (entry) => _buildInfoRow(
                                entry.key,
                                entry.value.toString(),
                              ),
                            )
                            .toList(),
                      ),
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
                      const SizedBox(width: 12),
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
                      const SizedBox(height: 12),
                      _buildTipCard('🔍', '筛选产品', '使用筛选器快速找到目标产品'),
                      const SizedBox(height: 12),
                      _buildTipCard('⚡', '开始对比', '选择2-5个产品后点击"对比"按钮'),
                      const SizedBox(height: 12),
                      _buildTipCard('💡', '产品信息', '点击产品后，图钉会显示该产品信息'),
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
                const SizedBox(height: 4),
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
          const SizedBox(height: 12),
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
}
