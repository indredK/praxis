import 'package:flutter/material.dart';
import '../services/advanced_filter_service.dart';

/// 筛选器测试组件 - 用于调试配置加载
class FilterTestWidget extends StatefulWidget {
  const FilterTestWidget({super.key});

  @override
  State<FilterTestWidget> createState() => _FilterTestWidgetState();
}

class _FilterTestWidgetState extends State<FilterTestWidget> {
  final AdvancedFilterService _filterService = AdvancedFilterService.instance;
  bool _isLoading = true;
  String _status = '正在加载配置...';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      await _filterService.loadConfig();
      final enabledFilters = await _filterService.getEnabledFiltersAsync(
        'same_brand',
      );
      setState(() {
        _isLoading = false;
        _status = '配置加载成功！筛选器数量: ${enabledFilters.length}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '配置加载失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('筛选器配置测试')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '状态: $_status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              Text('配置信息:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_filterService.config != null) ...[
                Text('根节点: ${_filterService.config!.root.title}'),
                Text('子筛选器数量: ${_filterService.config!.root.children.length}'),
                const SizedBox(height: 8),
                Text(
                  '对比模式数量: ${_filterService.config!.comparisonModes.length}',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filterService.config!.root.children.length,
                    itemBuilder: (context, index) {
                      final filter =
                          _filterService.config!.root.children[index];
                      return Card(
                        child: ListTile(
                          title: Text(filter.title),
                          subtitle: Text(
                            '类型: ${filter.type.name}, 选项数量: ${filter.children.length}',
                          ),
                          trailing: Text('ID: ${filter.id}'),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                const Text('配置为空'),
            ],
          ],
        ),
      ),
    );
  }
}
