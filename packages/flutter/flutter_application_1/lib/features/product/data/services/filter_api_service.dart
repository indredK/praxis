import '../../domain/models/advanced_filter_models.dart';
import '../mock/filter_mock_data.dart';

/// 筛选器API服务 - 模拟后端数据获取
class FilterApiService {
  static FilterApiService? _instance;
  static FilterApiService get instance => _instance ??= FilterApiService._();

  FilterApiService._();

  /// 获取筛选器配置
  Future<FilterTreeConfig> getFilterConfig() async {
    try {
      // 模拟网络延迟
      await FilterMockData.simulateNetworkDelay();

      // 模拟偶尔的网络错误（用于测试错误处理）
      // await FilterMockData.simulateNetworkError();

      // 返回模拟数据
      return FilterMockData.getFilterConfig();
    } catch (e) {
      throw Exception('获取筛选器配置失败: $e');
    }
  }

  /// 获取指定对比模式的筛选器配置
  Future<List<FilterNode>> getEnabledFilters(String comparisonMode) async {
    try {
      await FilterMockData.simulateNetworkDelay();

      final config = FilterMockData.getFilterConfig();
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
      await FilterMockData.simulateNetworkDelay();

      final config = FilterMockData.getFilterConfig();
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
      await FilterMockData.simulateNetworkDelay();

      final config = FilterMockData.getFilterConfig();
      return config.comparisonModes;
    } catch (e) {
      throw Exception('获取对比模式失败: $e');
    }
  }

  /// 检查筛选器是否支持多选
  Future<bool> isMultiSelect(String filterId) async {
    try {
      await FilterMockData.simulateNetworkDelay();

      final node = await getFilterNode(filterId);
      return node?.type == FilterType.multiSelect;
    } catch (e) {
      throw Exception('检查筛选器类型失败: $e');
    }
  }

  /// 获取筛选器选项
  Future<List<FilterNode>> getFilterOptions(String filterId) async {
    try {
      await FilterMockData.simulateNetworkDelay();

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
      await FilterMockData.simulateNetworkDelay();

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
