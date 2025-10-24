import 'package:flutter/material.dart';
import '../models/product_filter_models.dart';

/// 动态筛选器组件
class DynamicFilterWidget extends StatelessWidget {
  final String comparisonMode;
  final FilterSelectionState initialSelection;
  final Function(String nodeId, String? value) onSelectionChanged;

  const DynamicFilterWidget({
    super.key,
    required this.comparisonMode,
    required this.initialSelection,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280, // 固定宽度
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 品牌筛选
              if (comparisonMode == 'same_brand') ...[
                _buildFilterSection(
                  context,
                  title: '选择品牌',
                  options: ['Apple', 'Samsung', 'Dell', 'HP'],
                  selectedValue: initialSelection.selectedBrand,
                  onChanged: (value) =>
                      onSelectionChanged('brand_$value', value),
                ),
                const SizedBox(height: 8),
              ],

              // 类别筛选
              if (comparisonMode == 'same_category') ...[
                _buildFilterSection(
                  context,
                  title: '选择类别',
                  options: ['手机', '笔记本', '平板', '台式机'],
                  selectedValue: initialSelection.selectedCategory,
                  onChanged: (value) =>
                      onSelectionChanged('category_$value', value),
                ),
                const SizedBox(height: 8),
              ],

              // 产品线筛选
              _buildFilterSection(
                context,
                title: '产品线',
                options: ['旗舰', '中端', '入门'],
                selectedValue: initialSelection.selectedProductLine,
                onChanged: (value) =>
                    onSelectionChanged('product_line_$value', value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context, {
    required String title,
    required List<String> options,
    String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: FilterChip(
                label: Text(
                  option,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  onChanged(selected ? option : null);
                },
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                selectedColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.15),
                checkmarkColor: Theme.of(context).primaryColor,
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                elevation: isSelected ? 2 : 0,
                shadowColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
