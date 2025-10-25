import 'package:flutter/material.dart';
import '../../domain/models/product.dart' as models;
import 'comparison_table_config.dart';
import '../../../../config/app_config.dart';

/// 产品对比数据表格组件
/// 使用自定义 Row + ListView 实现，提供更好的性能和自定义能力
class ComparisonDataTable extends StatelessWidget {
  final List<models.Product> products;
  final List<models.SpecComparison> comparisons;
  final int baselineIndex;
  final String? Function(dynamic, dynamic)? onCalculatePercentage;

  const ComparisonDataTable({
    super.key,
    required this.products,
    required this.comparisons,
    required this.baselineIndex,
    this.onCalculatePercentage,
  });

  @override
  Widget build(BuildContext context) {
    if (comparisons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '暂无对比数据',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final productCount = products.length;

        // 计算表格配置
        final config = ComparisonTableConfig.calculate(
          screenWidth,
          screenHeight,
          productCount,
          rowCount: comparisons.length,
        );

        // 获取主题颜色
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final colorScheme = theme.colorScheme;

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? colorScheme.surface : Colors.white,
                isDark
                    ? colorScheme.surface.withValues(alpha: 0.8)
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: config.tableHeight,
              child: config.needsScrolling
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: config.totalTableWidth,
                        child: _buildTableContent(context, config),
                      ),
                    )
                  : _buildTableContent(context, config),
            ),
          ),
        );
      },
    );
  }

  /// 构建表格内容
  Widget _buildTableContent(
    BuildContext context,
    ComparisonTableConfig config,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // 表头（固定）
        _buildTableHeader(context, config, colorScheme, isDark),
        SizedBox(height: config.cellPadding * 0.5),

        // 表格内容（可滚动）
        Expanded(
          child: ListView.separated(
            itemCount: comparisons.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: config.cellPadding * 0.5),
            itemBuilder: (context, index) {
              return _buildTableRow(
                context,
                config,
                colorScheme,
                isDark,
                index,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建表头
  Widget _buildTableHeader(
    BuildContext context,
    ComparisonTableConfig config,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(
          alpha: isDark ? 0.3 : 0.5,
        ),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 规格列标题
            _buildHeaderCell(
              config.specColumnWidth,
              '规格参数',
              config,
              colorScheme,
              isDark,
              isSpec: true,
            ),
            SizedBox(width: config.cellPadding),

            // 产品列标题
            ...products.asMap().entries.expand((entry) {
              final index = entry.key;
              final product = entry.value;
              final isBaseline = index == baselineIndex;
              final companyColor = _getCompanyColor(product.company);

              return [
                _buildHeaderCell(
                  config.columnWidth,
                  product.name,
                  config,
                  colorScheme,
                  isDark,
                  isBaseline: isBaseline,
                  companyColor: companyColor,
                ),
                if (index < products.length - 1)
                  SizedBox(width: config.cellPadding),
              ];
            }),
          ],
        ),
      ),
    );
  }

  /// 构建表头单元格
  Widget _buildHeaderCell(
    double width,
    String text,
    ComparisonTableConfig config,
    ColorScheme colorScheme,
    bool isDark, {
    bool isSpec = false,
    bool isBaseline = false,
    Color? companyColor,
  }) {
    // 减去 border 宽度以避免溢出
    final effectiveWidth = isBaseline ? width - 4 : width;

    return Container(
      width: effectiveWidth,
      padding: EdgeInsets.symmetric(
        vertical: config.cellPadding * 1.5,
        horizontal: config.cellPadding,
      ),
      decoration: BoxDecoration(
        color: isSpec
            ? colorScheme.primaryContainer.withValues(alpha: isDark ? 0.4 : 0.6)
            : isBaseline
            ? (isDark
                  ? Colors.green.shade800.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.2))
            : companyColor?.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isBaseline
            ? Border.all(
                color: isDark ? Colors.green.shade400 : Colors.green,
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSpec ? config.headingFontSize : config.fontSize,
            color: isSpec
                ? colorScheme.onPrimaryContainer
                : isBaseline
                ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                : companyColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// 构建表格行
  Widget _buildTableRow(
    BuildContext context,
    ComparisonTableConfig config,
    ColorScheme colorScheme,
    bool isDark,
    int rowIndex,
  ) {
    final comparison = comparisons[rowIndex];

    return Container(
      decoration: BoxDecoration(
        color: rowIndex % 2 == 0
            ? (isDark ? colorScheme.surface : Colors.white)
            : (isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 规格名称列
            _buildSpecCell(comparison.name, config, colorScheme, isDark),
            SizedBox(width: config.cellPadding),

            // 产品值列
            ...comparison.values.asMap().entries.expand((entry) {
              final index = entry.key;
              final value = entry.value;
              final isBaseline = index == baselineIndex;

              final product = products.firstWhere(
                (p) => p.id == value.productId,
                orElse: () => products.first,
              );
              final companyColor = _getCompanyColor(product.company);

              // 计算显示值和颜色
              String displayValue = '${value.displayValue}${comparison.unit}';
              Color cellColor = companyColor.withValues(
                alpha: isDark ? 0.1 : 0.05,
              );

              if (!isBaseline && baselineIndex < comparison.values.length) {
                final baselineValue = comparison.values[baselineIndex];
                if (baselineValue.value != null &&
                    value.value != null &&
                    onCalculatePercentage != null) {
                  final percentage = onCalculatePercentage!(
                    baselineValue.value!,
                    value.value!,
                  );
                  if (percentage != null) {
                    displayValue =
                        '${value.displayValue}${comparison.unit}\n$percentage';
                    cellColor = _getPercentageColor(percentage, isDark);
                  }
                }
              }

              return [
                _buildValueCell(
                  displayValue,
                  config,
                  colorScheme,
                  isDark,
                  isBaseline: isBaseline,
                  companyColor: companyColor,
                  cellColor: cellColor,
                ),
                if (index < comparison.values.length - 1)
                  SizedBox(width: config.cellPadding),
              ];
            }),
          ],
        ),
      ),
    );
  }

  /// 构建规格单元格
  Widget _buildSpecCell(
    String text,
    ComparisonTableConfig config,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // 稍微减小宽度以避免溢出
    final effectiveWidth = config.specColumnWidth - 1;

    return Container(
      width: effectiveWidth,
      constraints: BoxConstraints(minHeight: config.cellPadding * 6),
      padding: EdgeInsets.symmetric(
        vertical: config.cellPadding,
        horizontal: config.cellPadding,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: config.fontSize,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// 构建值单元格
  Widget _buildValueCell(
    String text,
    ComparisonTableConfig config,
    ColorScheme colorScheme,
    bool isDark, {
    required bool isBaseline,
    required Color companyColor,
    required Color cellColor,
  }) {
    // 减去 border 宽度以避免溢出
    final effectiveWidth = config.columnWidth - 2;

    return Container(
      width: effectiveWidth,
      constraints: BoxConstraints(minHeight: config.cellPadding * 6),
      padding: EdgeInsets.symmetric(
        vertical: config.cellPadding,
        horizontal: config.cellPadding,
      ),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(8),
        border: isBaseline
            ? Border.all(
                color: isDark ? Colors.green.shade400 : Colors.green,
                width: 1,
              )
            : Border.all(
                color: companyColor.withValues(alpha: isDark ? 0.3 : 0.2),
                width: 1,
              ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: config.fontSize * 0.9,
            color: isBaseline
                ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                : companyColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// 根据百分比获取颜色
  Color _getPercentageColor(String percentage, bool isDark) {
    final alpha = isDark ? 0.2 : 0.1;

    if (percentage.startsWith('+')) {
      return Colors.red.withValues(alpha: alpha);
    } else if (percentage.startsWith('-')) {
      return Colors.blue.withValues(alpha: alpha);
    } else {
      return Colors.grey.withValues(alpha: alpha);
    }
  }

  /// 获取公司颜色
  Color _getCompanyColor(String company) {
    final colorString = AppConfig.getCompanyColor(company);
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }
}
