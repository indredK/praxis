import 'package:flutter/material.dart';
import '../services/product_selection_state_service.dart';

/// 测试产品选择状态保持功能
class ProductSelectionStateTest extends StatefulWidget {
  const ProductSelectionStateTest({super.key});

  @override
  State<ProductSelectionStateTest> createState() =>
      _ProductSelectionStateTestState();
}

class _ProductSelectionStateTestState extends State<ProductSelectionStateTest> {
  final ProductSelectionStateService _stateService =
      ProductSelectionStateService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('状态保持测试')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前状态:', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('选中产品数量: ${_stateService.selectedCount}'),
                    Text('对比模式: ${_stateService.comparisonMode}'),
                    Text('选中公司: ${_stateService.selectedCompany}'),
                    Text('选中类别: ${_stateService.selectedCategory}'),
                    Text('选中产品: ${_stateService.selectedProduct}'),
                    Text(
                      '同类对比类别: ${_stateService.selectedCategoryForComparison}',
                    ),
                    Text(
                      '同类对比产品: ${_stateService.selectedProductForComparison}',
                    ),
                    Text('可以开始对比: ${_stateService.canStartComparison}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _stateService.addProductId('test_product_1');
                      setState(() {});
                    },
                    child: const Text('添加产品1'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _stateService.addProductId('test_product_2');
                      setState(() {});
                    },
                    child: const Text('添加产品2'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _stateService.setComparisonMode('same_category');
                      setState(() {});
                    },
                    child: const Text('切换到同类对比'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _stateService.setComparisonMode('same_brand');
                      setState(() {});
                    },
                    child: const Text('切换到自家对比'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _stateService.setSameBrandSelections(company: 'Apple');
                      setState(() {});
                    },
                    child: const Text('选择Apple公司'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _stateService.setSameCategorySelections(category: '手机');
                      setState(() {});
                    },
                    child: const Text('选择手机类别'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _stateService.clearAll();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('清空所有选择'),
              ),
            ),
            const SizedBox(height: 16),
            Text('测试说明:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              '1. 点击"添加产品"按钮添加测试产品\n'
              '2. 切换对比模式\n'
              '3. 选择公司或类别\n'
              '4. 返回产品选择页面，检查图钉图标是否变化\n'
              '5. 点击图钉查看不同状态下的信息\n'
              '6. 长按产品卡片查看详细规格参数\n'
              '7. 重新进入对比页面，检查选择是否还在',
            ),
          ],
        ),
      ),
    );
  }
}
