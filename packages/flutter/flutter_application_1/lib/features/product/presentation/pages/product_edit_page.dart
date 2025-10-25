import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/product.dart';
import '../../../../config/app_config.dart';
import '../../data/services/data_service.dart';

/// 产品编辑页面
class ProductEditPage extends StatefulWidget {
  final Product? product; // 如果为null则是新建，否则是编辑

  const ProductEditPage({super.key, this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  bool _isSaving = false;

  // 基本信息
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String _selectedCompany = 'Apple';
  String _selectedCategory = '手机';
  DateTime _releaseDate = DateTime.now();

  // 规格参数（specs）
  final Map<String, dynamic> _specs = {};
  final List<String> _colors = [];
  final TextEditingController _colorInputController = TextEditingController();

  // 详细规格（specifications）
  final Map<String, String> _specifications = {};
  final List<MapEntry<TextEditingController, TextEditingController>>
  _specificationControllers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    if (widget.product != null) {
      final product = widget.product!;
      _idController.text = product.id;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _imageUrlController.text = product.imageUrl;
      _selectedCompany = product.company;
      _selectedCategory = product.category;
      _releaseDate = product.releaseDate;

      // 加载specs
      _specs.addAll(product.specs);
      if (product.specs['colors'] != null) {
        _colors.addAll((product.specs['colors'] as List).cast<String>());
      }

      // 加载specifications
      _specifications.addAll(product.specifications);
      product.specifications.forEach((key, value) {
        _addSpecificationField(key, value);
      });
    } else {
      // 新建产品，添加一些默认的规格字段
      _addSpecificationField('', '');
    }
  }

  void _addSpecificationField([String key = '', String value = '']) {
    setState(() {
      _specificationControllers.add(
        MapEntry(
          TextEditingController(text: key),
          TextEditingController(text: value),
        ),
      );
    });
  }

  void _removeSpecificationField(int index) {
    setState(() {
      _specificationControllers[index].key.dispose();
      _specificationControllers[index].value.dispose();
      _specificationControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _colorInputController.dispose();
    for (var entry in _specificationControllers) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _releaseDate = picked;
      });
    }
  }

  void _addColor() {
    if (_colorInputController.text.isNotEmpty) {
      setState(() {
        _colors.add(_colorInputController.text);
        _colorInputController.clear();
      });
    }
  }

  void _removeColor(int index) {
    setState(() {
      _colors.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 收集所有specifications
      _specifications.clear();
      for (var entry in _specificationControllers) {
        final key = entry.key.text.trim();
        final value = entry.value.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          _specifications[key] = value;
        }
      }

      // 构建specs
      _specs['colors'] = _colors;
      // 这里可以添加更多specs字段的处理

      final product = Product(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        company: _selectedCompany,
        category: _selectedCategory,
        imageUrl: _imageUrlController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        releaseDate: _releaseDate,
        specs: _specs,
        description: _descriptionController.text.trim(),
        specifications: _specifications,
      );

      // 调用API保存产品数据（会自动路由到后端或Mock）
      if (widget.product == null) {
        // 创建新产品
        await DataService.createProduct(product);
      } else {
        // 更新现有产品
        await DataService.updateProduct(widget.product!.id, product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? '✅ 产品创建成功' : '✅ 产品更新成功'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(product);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    // 确认删除
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除产品 "${widget.product?.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await DataService.deleteProduct(widget.product!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 产品删除成功'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // 返回true表示已删除
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 删除失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? '新建产品' : '编辑产品'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.8),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: '基本信息'),
            Tab(icon: Icon(Icons.palette), text: '外观规格'),
            Tab(icon: Icon(Icons.settings), text: '详细规格'),
          ],
        ),
        actions: [
          // 删除按钮（仅编辑模式）
          if (widget.product != null && !_isSaving)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteProduct,
              tooltip: '删除',
            ),
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProduct,
              tooltip: '保存',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildSpecsTab(),
            _buildSpecificationsTab(),
          ],
        ),
      ),
    );
  }

  // 基本信息Tab
  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ID（新建时可编辑，编辑时不可修改）
        TextFormField(
          controller: _idController,
          decoration: const InputDecoration(
            labelText: '产品ID *',
            hintText: '例如: iphone_15_pro',
            prefixIcon: Icon(Icons.tag),
            border: OutlineInputBorder(),
          ),
          enabled: widget.product == null,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入产品ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 名称
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '产品名称 *',
            hintText: '例如: iPhone 15 Pro',
            prefixIcon: Icon(Icons.title),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入产品名称';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 公司
        DropdownButtonFormField<String>(
          value: _selectedCompany,
          decoration: const InputDecoration(
            labelText: '品牌 *',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          items: AppConfig.supportedCompanies
              .map(
                (company) => DropdownMenuItem(
                  value: company,
                  child: Text('${AppConfig.getCompanyLogo(company)} $company'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCompany = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // 类别
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: '类别 *',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          items: AppConfig.productCategories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    '${AppConfig.getCategoryLogo(category)} $category',
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // 价格
        TextFormField(
          controller: _priceController,
          decoration: const InputDecoration(
            labelText: '价格 *',
            hintText: '例如: 7999',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
            suffix: Text('元'),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入价格';
            }
            if (double.tryParse(value) == null) {
              return '请输入有效的价格';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 发布日期
        ListTile(
          title: const Text('发布日期 *'),
          subtitle: Text(_releaseDate.toString().substring(0, 10)),
          leading: const Icon(Icons.calendar_today),
          trailing: const Icon(Icons.edit),
          onTap: _selectDate,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(height: 16),

        // 图片URL
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: '图片URL',
            hintText: 'https://example.com/image.jpg',
            prefixIcon: Icon(Icons.image),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // 描述
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '产品描述',
            hintText: '简要描述产品特点...',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // 外观规格Tab
  Widget _buildSpecsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '颜色配置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _colorInputController,
                        decoration: const InputDecoration(
                          labelText: '添加颜色',
                          hintText: '例如: 黑色',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addColor(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _addColor,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colors.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      onDeleted: () => _removeColor(entry.key),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 提示',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• 颜色将在产品筛选中使用'),
                Text('• 可以添加多个颜色选项'),
                Text('• 详细的规格参数请在"详细规格"标签页中配置'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 详细规格Tab
  Widget _buildSpecificationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📋 规格参数说明',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• 这些参数将显示在产品对比表中'),
                Text('• 参数名称请使用标准格式（如：屏幕尺寸、处理器、内存）'),
                Text('• 参数值请包含单位（如：6.1英寸、8GB、256GB）'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._specificationControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controllers = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: controllers.key,
                      decoration: const InputDecoration(
                        labelText: '参数名称',
                        hintText: '例如: 屏幕尺寸',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controllers.value,
                      decoration: const InputDecoration(
                        labelText: '参数值',
                        hintText: '例如: 6.1英寸',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeSpecificationField(index),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _addSpecificationField(),
          icon: const Icon(Icons.add),
          label: const Text('添加规格参数'),
        ),
      ],
    );
  }
}
