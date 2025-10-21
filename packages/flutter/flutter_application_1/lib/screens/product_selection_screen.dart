import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../config/app_config.dart';
import 'product_comparison_screen.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final Set<String> _selectedProductIds = {};

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await DataService.getAllProducts();
      final categories = await DataService.getAllCategories();
      final companies = await DataService.getAllCompanies();

      setState(() {
        _products = products;
        _categories = ['全部', ...categories];
        _companies = ['全部', ...companies];
        _isLoading = false;
      });

      // 初始化产品列表
      _updateProductLists();
    } catch (e) {
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
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final isSelected = _selectedProductIds.contains(product.id);

                return Card(
                  elevation: isSelected ? 12 : 4,
                  shadowColor: isSelected
                      ? _getCompanyColor(product.company).withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? _getCompanyColor(product.company)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getCompanyColor(
                                  product.company,
                                ).withOpacity(0.1),
                                _getCompanyColor(
                                  product.company,
                                ).withOpacity(0.05),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Colors.grey.shade50],
                            ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 60,
                        height: 60,
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isSelected
                              ? _getCompanyColor(product.company)
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
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
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.category,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SettingsService.showPrices
                                ? Text(
                                    SettingsService.formatPrice(product.price),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getCompanyColor(product.company)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Checkbox(
                          value: isSelected,
                          activeColor: Colors.white,
                          checkColor: _getCompanyColor(product.company),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedProductIds.add(product.id);
                              } else {
                                _selectedProductIds.remove(product.id);
                              }
                            });
                          },
                        ),
                      ),
                      onTap: () {
                        setState(() {
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
                          child: Text(company),
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
                          child: Text(category),
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
                      child: Text(product),
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
                          child: Text(category),
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
                          child: Text(product),
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
    if (_comparisonMode == 'same_brand') {
      // 自家对比模式：显示选中公司的所有产品
      if (_selectedCompany != '全部') {
        return _products.where((p) => p.company == _selectedCompany).toList();
      }
      return [];
    } else {
      // 同类对比模式：显示选中类别的所有产品
      if (_selectedCategoryForComparison != '全部') {
        return _products
            .where((p) => p.category == _selectedCategoryForComparison)
            .toList();
      }
      return [];
    }
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

  Color _getCompanyColor(String company) {
    final colorString = AppConfig.getCompanyColor(company);
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }
}
