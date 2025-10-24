import 'package:flutter/material.dart';

/// 应用常量配置
class AppConstants {
  // 应用信息
  static const String appName = '产品对比分析';
  static const String appVersion = '1.0.0';
  static const String appDescription = '一款强大的产品对比分析工具';

  // API配置
  static const String apiBaseUrl = 'https://api.productcompare.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // 缓存配置
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB

  // 界面配置
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // 动画配置
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 产品选择限制
  static const int maxSelectedProducts = 5;
  static const int minSelectedProducts = 2;

  // 支持的语言
  static const List<String> supportedLanguages = ['zh-CN', 'en-US', 'ja-JP'];

  // 支持的主题颜色
  static const List<Color> supportedThemeColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
  ];

  // 路由名称
  static const String routeHome = '/';
  static const String routeProductSelection = '/product-selection';
  static const String routeProductComparison = '/comparison';
  static const String routeProductDetail = '/product-detail';
  static const String routeCalculator = '/calculator';
  static const String routeExchangeRate = '/exchange-rate';
  static const String routeSettings = '/settings';

  // 存储键名
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  static const String keyThemeColor = 'theme_color';
  static const String keySelectedProducts = 'selected_products';
  static const String keyUserPreferences = 'user_preferences';

  // 错误消息
  static const String errorNetworkConnection = '网络连接失败，请检查网络设置';
  static const String errorServerError = '服务器错误，请稍后重试';
  static const String errorDataNotFound = '数据未找到';
  static const String errorInvalidInput = '输入数据无效';
  static const String errorPermissionDenied = '权限不足';
  static const String errorUnknown = '未知错误';

  // 成功消息
  static const String successDataLoaded = '数据加载成功';
  static const String successSettingsSaved = '设置已保存';
  static const String successProductAdded = '产品已添加';
  static const String successProductRemoved = '产品已移除';

  // 默认值
  static const String defaultLanguage = 'zh-CN';
  static const Color defaultThemeColor = Colors.blue;
  static const bool defaultDarkMode = false;
  static const bool defaultNotifications = true;
  static const bool defaultAutoRefresh = false;
  static const String defaultCurrency = 'USD';

  // 正则表达式
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phoneRegex = r'^\+?[\d\s\-\(\)]+$';
  static const String urlRegex =
      r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$';

  // 文件配置
  static const String imageCacheDir = 'image_cache';
  static const String dataCacheDir = 'data_cache';
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const int maxImageSize = 5; // MB

  // 性能配置
  static const int maxConcurrentRequests = 5;
  static const Duration requestInterval = Duration(milliseconds: 100);
  static const int maxHistoryItems = 50;

  // 调试配置
  static const bool enableLogging = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableCrashReporting = true;
}
