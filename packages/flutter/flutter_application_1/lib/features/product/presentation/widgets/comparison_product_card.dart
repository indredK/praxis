import 'package:flutter/material.dart';
import '../../domain/models/product.dart' as models;
import '../../../../config/app_config.dart';

/// 产品对比卡片组件
/// 用于在对比页面中显示单个产品的信息
class ComparisonProductCard extends StatelessWidget {
  final models.Product product;
  final bool isBaseline;
  final double cardHeight;
  final VoidCallback? onSetBaseline;
  final List<double> allPrices; // 所有对比产品的价格

  const ComparisonProductCard({
    super.key,
    required this.product,
    required this.isBaseline,
    required this.cardHeight,
    this.onSetBaseline,
    required this.allPrices,
  });

  @override
  Widget build(BuildContext context) {
    final companyColor = _getCompanyColor(product.company);

    return GestureDetector(
      onTap: onSetBaseline,
      child: Card(
        elevation: isBaseline ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isBaseline
              ? const BorderSide(color: Colors.green, width: 2)
              : BorderSide(
                  color: companyColor.withValues(alpha: 0.3),
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
                      companyColor.withValues(alpha: 0.1),
                      companyColor.withValues(alpha: 0.05),
                    ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 产品头像和名称
                Row(
                  children: [
                    _buildProductAvatar(context, companyColor),
                    const SizedBox(width: 10),
                    Expanded(child: _buildProductInfo(context)),
                    // 选中状态指示器
                    _buildSelectionIndicator(),
                  ],
                ),
                const SizedBox(height: 8),
                // 价格和关键指标
                _buildPriceAndMetrics(context, companyColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 产品头像
  Widget _buildProductAvatar(BuildContext context, Color companyColor) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBaseline
              ? [Colors.green, Colors.green.shade700]
              : [companyColor, companyColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          product.company[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 产品信息（名称和公司）
  Widget _buildProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isBaseline
                ? Colors.green.shade700
                : _getCompanyColor(product.company),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          product.company,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 选中状态指示器
  Widget _buildSelectionIndicator() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isBaseline ? Colors.green : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBaseline ? Colors.green.shade700 : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Icon(
        isBaseline ? Icons.check : Icons.radio_button_unchecked,
        color: isBaseline ? Colors.white : Colors.grey.shade600,
        size: 12,
      ),
    );
  }

  /// 价格和关键指标
  Widget _buildPriceAndMetrics(BuildContext context, Color companyColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 产品标签
        _buildProductTags(context, companyColor),
        const SizedBox(height: 6),
        // 价格和指标行
        Row(
          children: [
            // 价格显示
            Expanded(flex: 3, child: _buildPriceDisplay(context, companyColor)),
            const SizedBox(width: 4),
            // 关键指标（如果有的话）
            if (product.specs.isNotEmpty) ...[
              _buildKeyMetric(context, companyColor),
              const SizedBox(width: 3),
            ],
          ],
        ),
      ],
    );
  }

  /// 价格显示
  Widget _buildPriceDisplay(BuildContext context, Color companyColor) {
    final theme = Theme.of(context);

    return Text(
      '¥${product.price.toStringAsFixed(0)}',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: isBaseline
            ? Colors.green.shade600
            : theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.grey.shade800,
        letterSpacing: 0.5,
      ),
    );
  }

  /// 关键指标
  Widget _buildKeyMetric(BuildContext context, Color companyColor) {
    // 取第一个规格作为关键指标
    if (product.specs.isEmpty) return const SizedBox.shrink();

    final firstSpecEntry = product.specs.entries.first;
    final specValue = firstSpecEntry.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$specValue',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  /// 产品标签
  Widget _buildProductTags(BuildContext context, Color companyColor) {
    final tags = _getProductTags();
    if (tags.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // 调整宽度阈值，让标签更容易显示
        if (availableWidth < 80) {
          return const SizedBox.shrink();
        } else if (availableWidth < 120) {
          return _buildCompactTags(context, tags.take(1).toList());
        } else if (availableWidth < 160) {
          return _buildCompactTags(context, tags.take(2).toList());
        } else {
          return Wrap(
            spacing: 5,
            runSpacing: 3,
            children: tags.map((tag) => _buildTag(context, tag)).toList(),
          );
        }
      },
    );
  }

  /// 紧凑标签布局（防止溢出）
  Widget _buildCompactTags(BuildContext context, List<ProductTag> tags) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags
            .map(
              (tag) => Padding(
                padding: const EdgeInsets.only(right: 5),
                child: _buildTag(context, tag),
              ),
            )
            .toList(),
      ),
    );
  }

  /// 获取产品标签（按优先级排序）
  List<ProductTag> _getProductTags() {
    final tags = <ProductTag>[];

    // 优先级1：价格定位标签（最重要）
    if (product.price >= 8000) {
      tags.add(ProductTag('旗舰机', Colors.purple, Icons.star));
    } else if (product.price >= 5000) {
      tags.add(ProductTag('高端机', Colors.blue, Icons.diamond));
    } else if (product.price >= 3000) {
      tags.add(ProductTag('中端机', Colors.green, Icons.check_circle));
    } else {
      tags.add(ProductTag('入门机', Colors.orange, Icons.phone_android));
    }

    // 优先级2：品牌特色标签（次重要）
    switch (product.company.toLowerCase()) {
      case 'apple':
        tags.add(ProductTag('苹果生态', Colors.grey.shade700, Icons.apple));
        break;
      case 'samsung':
        tags.add(ProductTag('三星旗舰', Colors.blue.shade600, Icons.star));
        break;
      case 'huawei':
        tags.add(ProductTag('华为技术', Colors.red.shade600, Icons.engineering));
        break;
      case 'xiaomi':
        tags.add(ProductTag('性价比', Colors.orange.shade600, Icons.savings));
        break;
      case 'oppo':
        tags.add(ProductTag('拍照专家', Colors.pink.shade600, Icons.camera_alt));
        break;
      case 'vivo':
        tags.add(ProductTag('音乐手机', Colors.purple.shade600, Icons.music_note));
        break;
    }

    // 优先级3：功能丰富度标签（最不重要）
    if (product.specs.length >= 15) {
      tags.add(ProductTag('功能丰富', Colors.teal, Icons.apps));
    } else if (product.specs.length >= 10) {
      tags.add(ProductTag('配置均衡', Colors.indigo, Icons.balance));
    }

    return tags;
  }

  /// 构建单个标签
  Widget _buildTag(BuildContext context, ProductTag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tag.color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(tag.icon, size: 11, color: tag.color),
            const SizedBox(width: 3),
            Text(
              tag.text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: tag.color,
                height: 1.0, // 确保文字行高为1.0
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取公司颜色
  Color _getCompanyColor(String company) {
    final colorString = AppConfig.getCompanyColor(company);
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }
}

/// 紧凑版产品卡片（用于吸顶显示）
class CompactProductCard extends StatelessWidget {
  final models.Product product;
  final bool isBaseline;
  final double cardWidth;
  final VoidCallback? onSetBaseline;

  const CompactProductCard({
    super.key,
    required this.product,
    required this.isBaseline,
    required this.cardWidth,
    this.onSetBaseline,
  });

  @override
  Widget build(BuildContext context) {
    final companyColor = _getCompanyColor(product.company);

    return GestureDetector(
      onTap: onSetBaseline,
      child: Container(
        width: cardWidth,
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
                    companyColor.withValues(alpha: 0.2),
                    companyColor.withValues(alpha: 0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: isBaseline
              ? Border.all(color: Colors.green, width: 2)
              : Border.all(
                  color: companyColor.withValues(alpha: 0.3),
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
                      : [companyColor, companyColor.withValues(alpha: 0.7)],
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
                  color: isBaseline ? Colors.green.shade700 : companyColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 选中状态指示器
            Container(
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
                isBaseline ? Icons.check : Icons.radio_button_unchecked,
                color: isBaseline ? Colors.white : Colors.grey.shade600,
                size: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取公司颜色
  Color _getCompanyColor(String company) {
    final colorString = AppConfig.getCompanyColor(company);
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }
}

/// 产品标签数据类
class ProductTag {
  final String text;
  final Color color;
  final IconData icon;

  const ProductTag(this.text, this.color, this.icon);
}
