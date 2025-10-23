import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/settings_service.dart';
import '../config/app_config.dart';

/// 基于Material Design 3的产品卡片组件
class MaterialProductCard extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelect;
  final VoidCallback? onShowDetails;

  const MaterialProductCard({
    super.key,
    required this.product,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onSelect,
    this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final companyColor = _getCompanyColor(product.company);
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 8 : 2,
      shadowColor: isSelected
          ? companyColor.withOpacity(0.3)
          : theme.shadowColor,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: companyColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? companyColor.withOpacity(0.1) : theme.cardColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：公司Logo
                _buildCompanyLogo(companyColor),
                const SizedBox(width: 12),

                // 中间：产品信息
                Expanded(child: _buildProductInfo(context, companyColor)),

                // 右侧：操作按钮
                _buildActionButtons(context, companyColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建公司Logo
  Widget _buildCompanyLogo(Color companyColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: companyColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: companyColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          AppConfig.getCompanyLogo(product.company),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 构建产品信息
  Widget _buildProductInfo(BuildContext context, Color companyColor) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 产品名称
        Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? companyColor : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // 公司标签
        _buildCompanyChip(theme, companyColor),
        const SizedBox(height: 4),

        // 类别和价格
        Row(
          children: [
            // 类别标签
            _buildCategoryChip(theme),
            const SizedBox(width: 8),

            // 价格（如果设置显示）
            if (SettingsService.showPrices) _buildPriceChip(theme),
          ],
        ),
      ],
    );
  }

  /// 构建公司标签
  Widget _buildCompanyChip(ThemeData theme, Color companyColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: companyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: companyColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        product.company,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: companyColor,
        ),
      ),
    );
  }

  /// 构建类别标签
  Widget _buildCategoryChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        product.category,
        style: TextStyle(
          fontSize: 9,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 构建价格标签
  Widget _buildPriceChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Text(
        '¥${product.price.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.green.shade700,
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context, Color companyColor) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 选择按钮
        IconButton(
          onPressed: onSelect,
          icon: Icon(
            isSelected ? Icons.check_circle : Icons.add_circle_outline,
            color: isSelected ? companyColor : theme.colorScheme.primary,
            size: 24,
          ),
          tooltip: isSelected ? '已选择' : '选择产品',
        ),

        // 详情按钮
        IconButton(
          onPressed: onShowDetails,
          icon: Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          tooltip: '查看详情',
        ),
      ],
    );
  }

  /// 获取公司颜色
  Color _getCompanyColor(String company) {
    final colorString = AppConfig.getCompanyColor(company);
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }
}

/// 产品卡片列表组件
class MaterialProductList extends StatelessWidget {
  final List<Product> products;
  final List<String> selectedProductIds;
  final Function(Product) onProductTap;
  final Function(Product) onProductLongPress;
  final Function(Product) onProductSelect;
  final Function(Product) onProductDetails;
  final bool isLoading;

  const MaterialProductList({
    super.key,
    required this.products,
    required this.selectedProductIds,
    required this.onProductTap,
    required this.onProductLongPress,
    required this.onProductSelect,
    required this.onProductDetails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到产品',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请尝试调整筛选条件',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isSelected = selectedProductIds.contains(product.id);

        return MaterialProductCard(
          product: product,
          isSelected: isSelected,
          onTap: () => onProductTap(product),
          onLongPress: () => onProductLongPress(product),
          onSelect: () => onProductSelect(product),
          onShowDetails: () => onProductDetails(product),
        );
      },
    );
  }
}

/// 产品详情对话框
class ProductDetailsDialog extends StatelessWidget {
  final Product product;

  const ProductDetailsDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companyColor = _getCompanyColor(product.company);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: companyColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // 公司Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: companyColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        AppConfig.getCompanyLogo(product.company),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 产品信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.company,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: companyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 关闭按钮
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息
                    _buildInfoSection(theme, '基本信息', [
                      _buildInfoRow('类别', product.category),
                      _buildInfoRow(
                        '价格',
                        '¥${product.price.toStringAsFixed(0)}',
                      ),
                      _buildInfoRow('发布日期', _formatDate(product.releaseDate)),
                    ]),

                    const SizedBox(height: 16),

                    // 规格参数
                    if (product.specs.isNotEmpty) _buildSpecsSection(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSpecsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '规格参数',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...product.specs.entries.map(
          (entry) => _buildInfoRow(entry.key, entry.value.toString()),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 获取公司颜色
  Color _getCompanyColor(String company) {
    final colorString = AppConfig.getCompanyColor(company);
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }
}
