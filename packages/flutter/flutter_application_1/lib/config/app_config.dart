// 应用配置 - 前端固定配置
class AppConfig {
  // 应用基本信息
  static const String appName = '产品对比分析';
  static const String appVersion = '1.0.0';

  // 支持的厂商列表 - 前端固定
  static const List<String> supportedCompanies = [
    'Apple',
    'Samsung',
    'Google',
    'Tesla',
    'Microsoft',
    'Huawei',
    'Xiaomi',
    'Oppo',
    'Vivo',
    'OnePlus',
  ];

  // 产品类别 - 前端固定
  static const List<String> productCategories = [
    '手机',
    '笔记本',
    '平板电脑',
    '智能手表',
    '耳机',
    '汽车',
    '家电',
    '游戏设备',
    '游戏本',
  ];

  // 产品类别logo配置 - 前端固定
  static const Map<String, String> categoryLogos = {
    '手机': '📱',
    '笔记本': '💻',
    '笔记本电脑': '💻',
    '平板电脑': '📱',
    '智能手表': '⌚',
    '耳机': '🎧',
    '汽车': '🚗',
    '家电': '🏠',
    '游戏设备': '🎮',
    '游戏本': '🎮',
  };

  // 规格参数配置 - 前端固定，定义所有可能的参数类型
  static const Map<String, SpecConfig> specConfigs = {
    // 手机相关参数
    '屏幕尺寸': SpecConfig(unit: '英寸', type: SpecType.text, category: '手机'),
    '分辨率': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '处理器': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '内存': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '存储': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '主摄像头': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '超广角': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '长焦': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '前置摄像头': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '电池容量': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '重量': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '厚度': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '防水等级': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '操作系统': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '屏幕刷新率': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '峰值亮度': SpecConfig(unit: '', type: SpecType.text, category: '手机'),
    '充电功率': SpecConfig(unit: '', type: SpecType.text, category: '手机'),

    // 汽车相关参数
    '续航里程': SpecConfig(unit: 'km', type: SpecType.number, category: '汽车'),
    '加速时间': SpecConfig(unit: '秒', type: SpecType.number, category: '汽车'),
    '最高时速': SpecConfig(unit: 'km/h', type: SpecType.number, category: '汽车'),
    '汽车电池容量': SpecConfig(unit: 'kWh', type: SpecType.number, category: '汽车'),
    '充电时间': SpecConfig(unit: '分钟', type: SpecType.number, category: '汽车'),
    '座位数': SpecConfig(unit: '座', type: SpecType.number, category: '汽车'),
    '行李箱容积': SpecConfig(unit: 'L', type: SpecType.number, category: '汽车'),
    '自动驾驶': SpecConfig(unit: '', type: SpecType.text, category: '汽车'),
    '车身长度': SpecConfig(unit: 'mm', type: SpecType.number, category: '汽车'),

    // 笔记本电脑相关参数 (支持"笔记本"和"笔记本电脑"两种类别)
    '显卡': SpecConfig(unit: '', type: SpecType.text, category: '笔记本'),
    '电池续航': SpecConfig(unit: '', type: SpecType.text, category: '笔记本'),
    '接口': SpecConfig(unit: '', type: SpecType.text, category: '笔记本'),
    '音频': SpecConfig(unit: '', type: SpecType.text, category: '笔记本'),
    '摄像头': SpecConfig(unit: '', type: SpecType.text, category: '笔记本'),

    // 平板电脑相关参数
    '显示技术': SpecConfig(unit: '', type: SpecType.text, category: '平板电脑'),

    // 智能手表相关参数
    '传感器': SpecConfig(unit: '', type: SpecType.text, category: '智能手表'),
    '连接': SpecConfig(unit: '', type: SpecType.text, category: '智能手表'),

    // 耳机相关参数
    '芯片': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '降噪': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '通透模式': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '空间音频': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '自适应音频': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '续航时间': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '充电盒续航': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '充电接口': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '充电盒重量': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '特殊功能': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '驱动单元': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
    '材质': SpecConfig(unit: '', type: SpecType.text, category: '耳机'),
  };

  // 图表配置
  static const Map<String, ChartConfig> chartConfigs = {
    'price_comparison': ChartConfig(
      title: '价格对比',
      type: 'bar',
      xAxis: '产品名称',
      yAxis: '价格 (\$)',
    ),
    'performance_analysis': ChartConfig(
      title: '性能分析',
      type: 'radar',
      xAxis: '性能指标',
      yAxis: '评分',
    ),
    'price_vs_performance': ChartConfig(
      title: '价格 vs 性能分析',
      type: 'scatter',
      xAxis: '价格 (\$)',
      yAxis: '性能评分',
    ),
    'market_share': ChartConfig(
      title: '市场份额分布',
      type: 'pie',
      xAxis: '公司',
      yAxis: '产品数量',
    ),
    'price_trend': ChartConfig(
      title: '价格趋势分析',
      type: 'line',
      xAxis: '产品',
      yAxis: '价格 (\$)',
    ),
  };

  // 公司品牌色配置 - 前端固定
  static const Map<String, String> companyColors = {
    'Apple': '#007AFF',
    'Samsung': '#1F2937',
    'Google': '#4285F4',
    'Tesla': '#CC0000',
    'Microsoft': '#00BCF2',
    'Huawei': '#FF6B35',
    'Xiaomi': '#FF6900',
    'Oppo': '#00C853',
    'Vivo': '#1E88E5',
    'OnePlus': '#F50057',
  };

  // 公司logo配置 - 前端固定
  static const Map<String, String> companyLogos = {
    'Apple': '🍎',
    'Samsung': '📱',
    'Google': '🔍',
    'Tesla': '⚡',
    'Microsoft': '🪟',
    'Huawei': '🌸',
    'Xiaomi': '📦',
    'Oppo': '📷',
    'Vivo': '🎵',
    'OnePlus': '➕',
  };

  // 获取公司颜色
  static String getCompanyColor(String company) {
    return companyColors[company] ?? '#6B7280';
  }

  // 获取公司logo
  static String getCompanyLogo(String company) {
    return companyLogos[company] ?? '🏢';
  }

  // 获取类别logo
  static String getCategoryLogo(String category) {
    return categoryLogos[category] ?? '📦';
  }

  // 获取规格配置
  static SpecConfig? getSpecConfig(String specName) {
    return specConfigs[specName];
  }

  // 根据类别获取相关规格
  static List<String> getSpecsByCategory(String category) {
    return specConfigs.entries
        .where((entry) => entry.value.category == category)
        .map((entry) => entry.key)
        .toList();
  }
}

// 规格配置类
class SpecConfig {
  final String unit;
  final SpecType type;
  final String category;

  const SpecConfig({
    required this.unit,
    required this.type,
    required this.category,
  });
}

// 规格类型枚举
enum SpecType { number, text, date, boolean }

// 图表配置类
class ChartConfig {
  final String title;
  final String type;
  final String xAxis;
  final String yAxis;

  const ChartConfig({
    required this.title,
    required this.type,
    required this.xAxis,
    required this.yAxis,
  });
}
