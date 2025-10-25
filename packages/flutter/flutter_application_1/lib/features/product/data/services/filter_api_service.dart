import '../../domain/models/advanced_filter_models.dart';
import '../mock/filter_mock_data.dart';
import '../../../../config/api_config.dart';
import '../../../../core/services/http_client.dart';

/// 筛选器API服务 - 支持真实后端和Mock数据
class FilterApiService {
  static FilterApiService? _instance;
  static FilterApiService get instance => _instance ??= FilterApiService._();

  FilterApiService._();

  // 延迟获取HttpClient实例，避免在Web环境初始化问题
  HttpClient get _httpClient => HttpClient.instance;

  /// 获取筛选器配置
  Future<FilterTreeConfig> getFilterConfig() async {
    try {
      // 如果启用Mock数据，使用本地数据
      if (ApiConfig.useMockData) {
        await FilterMockData.simulateNetworkDelay();
        final mockConfig = FilterMockData.getFilterConfig();
        return _addMockLabel(mockConfig);
      }

      // 调用真实后端API
      print('📡 正在请求后端API: ${ApiConfig.filtersUrl}');
      final response = await _httpClient.get(ApiConfig.filtersUrl);
      print('✅ 后端响应成功');

      // 后端返回格式: { filterTree: {...}, comparisonModes: {...} }
      return FilterTreeConfig.fromJson(response);
    } catch (e, stackTrace) {
      // 失败时fallback到Mock数据
      print('⚠️ 后端请求失败，使用Mock数据: $e');
      print('堆栈: $stackTrace');
      final mockConfig = FilterMockData.getFilterConfig();
      return _addMockLabel(mockConfig);
    }
  }

  /// 给筛选配置添加Mock标识
  FilterTreeConfig _addMockLabel(FilterTreeConfig config) {
    return FilterTreeConfig(
      root: _addMockLabelToNode(config.root),
      comparisonModes: config.comparisonModes.map(
        (key, value) => MapEntry(
          key,
          FilterModeConfig(
            title: '🔧 [Mock] ${value.title}',
            enabledFilters: value.enabledFilters,
          ),
        ),
      ),
    );
  }

  /// 递归给筛选节点添加Mock标识
  FilterNode _addMockLabelToNode(FilterNode node) {
    return FilterNode(
      id: node.id,
      title: '🔧 [Mock] ${node.title}',
      value: node.value,
      icon: node.icon,
      type: node.type,
      enabled: node.enabled,
      children: node.children.map(_addMockLabelToNode).toList(),
      metadata: node.metadata,
    );
  }

  /// 获取指定对比模式的筛选器配置
  Future<List<FilterNode>> getEnabledFilters(String comparisonMode) async {
    try {
      // 使用主方法获取配置（会根据useMockData自动选择后端或Mock）
      final config = await getFilterConfig();
      final modeConfig = config.comparisonModes[comparisonMode];

      if (modeConfig == null) {
        return [];
      }

      return config.root.children
          .where((filter) => modeConfig.enabledFilters.contains(filter.id))
          .toList();
    } catch (e) {
      throw Exception('获取筛选器列表失败: $e');
    }
  }

  /// 获取筛选器节点详情
  Future<FilterNode?> getFilterNode(String filterId) async {
    try {
      // 使用主方法获取配置（会根据useMockData自动选择后端或Mock）
      final config = await getFilterConfig();
      return _findFilterNode(config.root, filterId);
    } catch (e) {
      throw Exception('获取筛选器节点失败: $e');
    }
  }

  /// 递归查找筛选器节点
  FilterNode? _findFilterNode(FilterNode node, String filterId) {
    if (node.id == filterId) return node;

    for (final child in node.children) {
      final found = _findFilterNode(child, filterId);
      if (found != null) return found;
    }
    return null;
  }

  /// 获取所有对比模式
  Future<Map<String, FilterModeConfig>> getComparisonModes() async {
    try {
      // 使用主方法获取配置（会根据useMockData自动选择后端或Mock）
      final config = await getFilterConfig();
      return config.comparisonModes;
    } catch (e) {
      throw Exception('获取对比模式失败: $e');
    }
  }

  /// 检查筛选器是否支持多选
  Future<bool> isMultiSelect(String filterId) async {
    try {
      // getFilterNode已经会根据配置选择后端或Mock
      final node = await getFilterNode(filterId);
      return node?.type == FilterType.multiSelect;
    } catch (e) {
      throw Exception('检查筛选器类型失败: $e');
    }
  }

  /// 获取筛选器选项
  Future<List<FilterNode>> getFilterOptions(String filterId) async {
    try {
      // getFilterNode已经会根据配置选择后端或Mock
      final node = await getFilterNode(filterId);
      return node?.children ?? [];
    } catch (e) {
      throw Exception('获取筛选器选项失败: $e');
    }
  }

  /// 搜索筛选器选项
  Future<List<FilterNode>> searchFilterOptions(
    String filterId,
    String query,
  ) async {
    try {
      // getFilterOptions已经会根据配置选择后端或Mock
      final options = await getFilterOptions(filterId);
      return options
          .where(
            (option) =>
                option.title.toLowerCase().contains(query.toLowerCase()) ||
                (option.value?.toLowerCase().contains(query.toLowerCase()) ??
                    false),
          )
          .toList();
    } catch (e) {
      throw Exception('搜索筛选器选项失败: $e');
    }
  }
}
