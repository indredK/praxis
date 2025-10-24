import 'package:flutter/material.dart';
import '../services/filter_api_service.dart';
import '../models/advanced_filter_models.dart';

/// API测试组件 - 用于测试后端数据获取
class ApiTestWidget extends StatefulWidget {
  const ApiTestWidget({super.key});

  @override
  State<ApiTestWidget> createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  final FilterApiService _apiService = FilterApiService.instance;
  bool _isLoading = false;
  String _status = '准备测试API...';
  List<String> _testResults = [];

  Future<void> _testGetFilterConfig() async {
    setState(() {
      _isLoading = true;
      _status = '正在获取筛选器配置...';
    });

    try {
      final config = await _apiService.getFilterConfig();
      setState(() {
        _isLoading = false;
        _status = '获取配置成功！';
        _testResults.add('✅ 获取筛选器配置成功');
        _testResults.add('   - 根节点: ${config.root.title}');
        _testResults.add('   - 筛选器数量: ${config.root.children.length}');
        _testResults.add('   - 对比模式数量: ${config.comparisonModes.length}');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '获取配置失败: $e';
        _testResults.add('❌ 获取筛选器配置失败: $e');
      });
    }
  }

  Future<void> _testGetEnabledFilters() async {
    setState(() {
      _isLoading = true;
      _status = '正在获取启用的筛选器...';
    });

    try {
      final filters = await _apiService.getEnabledFilters('same_brand');
      setState(() {
        _isLoading = false;
        _status = '获取启用筛选器成功！';
        _testResults.add('✅ 获取启用筛选器成功');
        _testResults.add('   - 筛选器数量: ${filters.length}');
        for (final filter in filters) {
          _testResults.add('   - ${filter.title} (${filter.type.name})');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '获取启用筛选器失败: $e';
        _testResults.add('❌ 获取启用筛选器失败: $e');
      });
    }
  }

  Future<void> _testGetFilterNode() async {
    setState(() {
      _isLoading = true;
      _status = '正在获取筛选器节点...';
    });

    try {
      final node = await _apiService.getFilterNode('brand_filter');
      setState(() {
        _isLoading = false;
        _status = '获取筛选器节点成功！';
        _testResults.add('✅ 获取筛选器节点成功');
        _testResults.add('   - 节点: ${node?.title}');
        _testResults.add('   - 类型: ${node?.type.name}');
        _testResults.add('   - 选项数量: ${node?.children.length}');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '获取筛选器节点失败: $e';
        _testResults.add('❌ 获取筛选器节点失败: $e');
      });
    }
  }

  Future<void> _testSearchOptions() async {
    setState(() {
      _isLoading = true;
      _status = '正在搜索筛选器选项...';
    });

    try {
      final options = await _apiService.searchFilterOptions(
        'brand_filter',
        'Apple',
      );
      setState(() {
        _isLoading = false;
        _status = '搜索筛选器选项成功！';
        _testResults.add('✅ 搜索筛选器选项成功');
        _testResults.add('   - 搜索结果数量: ${options.length}');
        for (final option in options) {
          _testResults.add('   - ${option.title}');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '搜索筛选器选项失败: $e';
        _testResults.add('❌ 搜索筛选器选项失败: $e');
      });
    }
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
      _status = '准备测试API...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API测试'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _clearResults),
        ],
      ),
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
              const Center(child: CircularProgressIndicator())
            else ...[
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _testGetFilterConfig,
                    child: const Text('测试获取配置'),
                  ),
                  ElevatedButton(
                    onPressed: _testGetEnabledFilters,
                    child: const Text('测试获取启用筛选器'),
                  ),
                  ElevatedButton(
                    onPressed: _testGetFilterNode,
                    child: const Text('测试获取节点'),
                  ),
                  ElevatedButton(
                    onPressed: _testSearchOptions,
                    child: const Text('测试搜索选项'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('测试结果:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _testResults[index],
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
