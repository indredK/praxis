import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  Locale _currentLocale = const Locale('zh', 'CN');

  Locale get currentLocale => _currentLocale;

  // 初始化语言管理器
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language') ?? 'zh-CN';
      final parts = languageCode.split('-');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      } else {
        _currentLocale = const Locale('zh', 'CN');
      }
      notifyListeners();
    } catch (e) {
      _currentLocale = const Locale('zh', 'CN');
    }
  }

  // 更新语言
  Future<void> updateLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      final parts = languageCode.split('-');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      } else {
        _currentLocale = Locale(parts[0]);
      }
      notifyListeners();
    } catch (e) {}
  }

  // 获取语言显示名称
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'zh-CN':
        return '中文';
      case 'en-US':
        return 'English';
      case 'ja-JP':
        return '日本語';
      default:
        return '中文';
    }
  }

  // 获取所有支持的语言
  List<Map<String, String>> getAllLanguages() {
    return [
      {'code': 'zh-CN', 'name': '中文'},
      {'code': 'en-US', 'name': 'English'},
      {'code': 'ja-JP', 'name': '日本語'},
    ];
  }
}
