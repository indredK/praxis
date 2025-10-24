import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications';
  static const String _autoRefreshKey = 'auto_refresh';
  static const String _defaultCurrencyKey = 'default_currency';
  static const String _defaultLanguageKey = 'default_language';
  static const String _maxProductsKey = 'max_products';
  static const String _showPricesKey = 'show_prices';
  static const String _showSpecsKey = 'show_specs';
  static const String _showChartsKey = 'show_charts';
  static const String _themeColorKey = 'theme_color';

  static SharedPreferences? _prefs;

  // 初始化设置服务
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 深色模式
  static bool get darkMode => _prefs?.getBool(_darkModeKey) ?? false;
  static Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool(_darkModeKey, value);
  }

  // 通知设置
  static bool get notifications => _prefs?.getBool(_notificationsKey) ?? true;
  static Future<void> setNotifications(bool value) async {
    await _prefs?.setBool(_notificationsKey, value);
  }

  // 自动刷新
  static bool get autoRefresh => _prefs?.getBool(_autoRefreshKey) ?? false;
  static Future<void> setAutoRefresh(bool value) async {
    await _prefs?.setBool(_autoRefreshKey, value);
  }

  // 默认货币
  static String get defaultCurrency =>
      _prefs?.getString(_defaultCurrencyKey) ?? 'USD';
  static Future<void> setDefaultCurrency(String value) async {
    await _prefs?.setString(_defaultCurrencyKey, value);
  }

  // 默认语言
  static String get defaultLanguage =>
      _prefs?.getString(_defaultLanguageKey) ?? 'zh-CN';
  static Future<void> setDefaultLanguage(String value) async {
    await _prefs?.setString(_defaultLanguageKey, value);
  }

  // 最大产品数量
  static int get maxProducts => _prefs?.getInt(_maxProductsKey) ?? 5;
  static Future<void> setMaxProducts(int value) async {
    await _prefs?.setInt(_maxProductsKey, value);
  }

  // 显示价格
  static bool get showPrices => _prefs?.getBool(_showPricesKey) ?? true;
  static Future<void> setShowPrices(bool value) async {
    await _prefs?.setBool(_showPricesKey, value);
  }

  // 显示规格
  static bool get showSpecs => _prefs?.getBool(_showSpecsKey) ?? true;
  static Future<void> setShowSpecs(bool value) async {
    await _prefs?.setBool(_showSpecsKey, value);
  }

  // 显示图表
  static bool get showCharts => _prefs?.getBool(_showChartsKey) ?? true;
  static Future<void> setShowCharts(bool value) async {
    await _prefs?.setBool(_showChartsKey, value);
  }

  // 主题颜色
  static String get themeColor => _prefs?.getString(_themeColorKey) ?? 'blue';
  static Future<void> setThemeColor(String value) async {
    await _prefs?.setString(_themeColorKey, value);
  }

  // 获取主题颜色
  static Color getThemeColor() {
    final colorName = themeColor;
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  // 获取货币符号
  static String getCurrencySymbol() {
    switch (defaultCurrency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'CNY':
        return '¥';
      case 'JPY':
        return '¥';
      default:
        return '\$';
    }
  }

  // 格式化价格
  static String formatPrice(double price) {
    final symbol = getCurrencySymbol();
    return '$symbol${price.toStringAsFixed(2)}';
  }

  // 重置所有设置
  static Future<void> resetAllSettings() async {
    await _prefs?.clear();
  }

  // 获取所有设置
  static Map<String, dynamic> getAllSettings() {
    return {
      'darkMode': darkMode,
      'notifications': notifications,
      'autoRefresh': autoRefresh,
      'defaultCurrency': defaultCurrency,
      'defaultLanguage': defaultLanguage,
      'maxProducts': maxProducts,
      'showPrices': showPrices,
      'showSpecs': showSpecs,
      'showCharts': showCharts,
      'themeColor': themeColor,
    };
  }

  // 批量设置
  static Future<void> setAllSettings(Map<String, dynamic> settings) async {
    await setDarkMode(settings['darkMode'] ?? false);
    await setNotifications(settings['notifications'] ?? true);
    await setAutoRefresh(settings['autoRefresh'] ?? false);
    await setDefaultCurrency(settings['defaultCurrency'] ?? 'USD');
    await setDefaultLanguage(settings['defaultLanguage'] ?? 'zh-CN');
    await setMaxProducts(settings['maxProducts'] ?? 5);
    await setShowPrices(settings['showPrices'] ?? true);
    await setShowSpecs(settings['showSpecs'] ?? true);
    await setShowCharts(settings['showCharts'] ?? true);
    await setThemeColor(settings['themeColor'] ?? 'blue');
  }
}
