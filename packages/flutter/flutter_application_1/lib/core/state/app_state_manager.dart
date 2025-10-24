import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../features/settings/data/services/settings_service.dart';
import '../services/language_manager.dart';

/// 应用全局状态管理器
/// 统一管理应用的所有状态，包括主题、语言、产品选择等
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // 主题相关状态
  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;

  // 语言相关状态
  String _currentLanguage = 'zh-CN';
  Locale _currentLocale = const Locale('zh', 'CN');

  // 产品选择状态
  List<String> _selectedProductIds = [];
  bool _showComparison = false;

  // 导航状态
  int _currentTabIndex = 0;

  // 加载状态
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  String get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLocale;
  List<String> get selectedProductIds => List.unmodifiable(_selectedProductIds);
  bool get showComparison => _showComparison;
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 初始化状态管理器
  Future<void> initialize() async {
    try {
      await SettingsService.init();
      await LanguageManager().init();

      // 加载保存的设置
      _isDarkMode = SettingsService.darkMode;
      _primaryColor = SettingsService.getThemeColor();
      _currentLanguage = SettingsService.defaultLanguage;

      // 设置语言
      final languageParts = _currentLanguage.split('-');
      if (languageParts.length == 2) {
        _currentLocale = Locale(languageParts[0], languageParts[1]);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = '初始化失败: $e';
      notifyListeners();
    }
  }

  /// 切换暗黑模式
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await SettingsService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// 设置主题颜色
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    // 这里可以添加保存颜色的逻辑
    notifyListeners();
  }

  /// 切换语言
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      await SettingsService.setDefaultLanguage(languageCode);

      // 更新Locale
      final languageParts = languageCode.split('-');
      if (languageParts.length == 2) {
        _currentLocale = Locale(languageParts[0], languageParts[1]);
      }

      notifyListeners();
    }
  }

  /// 添加选中的产品
  void addSelectedProduct(String productId) {
    if (!_selectedProductIds.contains(productId)) {
      _selectedProductIds.add(productId);
      notifyListeners();
    }
  }

  /// 移除选中的产品
  void removeSelectedProduct(String productId) {
    _selectedProductIds.remove(productId);
    notifyListeners();
  }

  /// 设置选中的产品列表
  void setSelectedProducts(List<String> productIds) {
    _selectedProductIds = List.from(productIds);
    notifyListeners();
  }

  /// 清空选中的产品
  void clearSelectedProducts() {
    _selectedProductIds.clear();
    notifyListeners();
  }

  /// 显示对比页面
  void showComparisonPage() {
    if (_selectedProductIds.isNotEmpty) {
      _showComparison = true;
      notifyListeners();
    }
  }

  /// 隐藏对比页面
  void hideComparison() {
    _showComparison = false;
    notifyListeners();
  }

  /// 设置当前标签页
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    _showComparison = false; // 切换标签时隐藏对比页面
    notifyListeners();
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null; // 开始加载时清除错误信息
    }
    notifyListeners();
  }

  /// 设置错误信息
  void setError(String? error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 重置所有状态
  void reset() {
    _isDarkMode = false;
    _primaryColor = Colors.blue;
    _currentLanguage = 'zh-CN';
    _currentLocale = const Locale('zh', 'CN');
    _selectedProductIds.clear();
    _showComparison = false;
    _currentTabIndex = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
