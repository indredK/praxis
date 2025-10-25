import 'package:flutter/material.dart';
import '../../data/services/filter_api_service.dart';
import '../../domain/models/advanced_filter_models.dart';

/// API测试页面 - 测试后端对接
class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final FilterApiService _filterService = FilterApiService.instance;
  FilterTreeConfig? _filterConfig;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFilterConfig();
  }

  Future<void> _loadFilterConfig() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final config = await _filterService.getFilterConfig();
      setState(() {
        _filterConfig = config;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('后端API测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFilterConfig,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在从后端加载筛选配置...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('错误: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFilterConfig,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_filterConfig == null) {
      return const Center(child: Text('未加载数据'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 状态卡片
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      '✅ 后端对接成功',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '成功从后端 API 获取筛选配置',
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 筛选树信息
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '筛选树配置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.filter_list),
                  title: Text('根节点: ${_filterConfig!.root.title}'),
                  subtitle: Text(
                    '子节点数量: ${_filterConfig!.root.children.length}',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 筛选器列表
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '可用筛选器',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ..._filterConfig!.root.children.map((filter) {
                  return ListTile(
                    leading: Text(
                      filter.icon ?? '🔹',
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(filter.title),
                    subtitle: Text(
                      '${filter.children.length} 个选项 • ${filter.type.name}',
                    ),
                    trailing: filter.enabled
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.grey),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 对比模式
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '对比模式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ..._filterConfig!.comparisonModes.entries.map((entry) {
                  return ListTile(
                    leading: const Icon(Icons.compare_arrows),
                    title: Text(entry.value.title),
                    subtitle: Text('${entry.value.enabledFilters.length} 个筛选器'),
                    trailing: Text(entry.key),
                  );
                }),
              ],
            ),
          ),
        ),

        // API信息
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'API 信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.link),
                  title: Text('后端地址'),
                  subtitle: Text('http://localhost:3001/api/v1'),
                ),
                const ListTile(
                  leading: Icon(Icons.api),
                  title: Text('筛选配置端点'),
                  subtitle: Text('GET /filters/config'),
                ),
                ListTile(
                  leading: const Icon(Icons.data_object),
                  title: const Text('响应字段数'),
                  subtitle: Text(
                    '${_filterConfig!.root.children.length} 个筛选器, '
                    '${_filterConfig!.comparisonModes.length} 个对比模式',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
