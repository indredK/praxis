/// API配置
class ApiConfig {
  // 后端API基础URL
  static const String baseUrl = 'http://localhost:3001/api/v1';

  // API端点
  static const String productsEndpoint = '/products';
  static const String filtersEndpoint = '/filters/config';
  static const String healthEndpoint = '/health';

  // 请求超时
  static const Duration timeout = Duration(seconds: 10);

  // 是否启用Mock数据（开发时可切换）
  static const bool useMockData = false; // 设为false使用真实数据（可看到🔧标识）
  // static const bool useMockData = true; // 设为true使用Mock数据（可看到🔧标识）

  // 完整URL
  static String get productsUrl => '$baseUrl$productsEndpoint';
  static String get filtersUrl => '$baseUrl$filtersEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';
}
