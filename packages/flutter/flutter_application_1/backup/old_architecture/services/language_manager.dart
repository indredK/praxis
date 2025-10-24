import 'package:flutter/material.dart';
import 'language_service.dart';

class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  Locale _currentLocale = const Locale('zh', 'CN');

  Locale get currentLocale => _currentLocale;

  // 初始化语言管理器
  Future<void> init() async {
    try {
      _currentLocale = LanguageService.currentLocale;
      notifyListeners();
    } catch (e) {
      _currentLocale = const Locale('zh', 'CN');
    }
  }

  // 更新语言
  Future<void> updateLanguage(String languageCode) async {
    try {
      await LanguageService.setLanguage(languageCode);
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
    return LanguageService.getLanguageName(languageCode);
  }

  // 获取所有支持的语言
  List<Map<String, String>> getAllLanguages() {
    return LanguageService.getAllLanguages();
  }
}
