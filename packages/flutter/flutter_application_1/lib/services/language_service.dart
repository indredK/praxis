import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static SharedPreferences? _prefs;

  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 简体中文
    Locale('en', 'US'), // 英语
    Locale('ja', 'JP'), // 日语
  ];

  // 语言显示名称
  static const Map<String, String> languageNames = {
    'zh-CN': '简体中文',
    'en-US': 'English',
    'ja-JP': '日本語',
  };

  // 初始化语言服务
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 获取当前语言
  static String get currentLanguage =>
      _prefs?.getString(_languageKey) ?? 'zh-CN';

  // 设置语言
  static Future<void> setLanguage(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
  }

  // 获取当前Locale
  static Locale get currentLocale {
    final languageCode = currentLanguage;
    final parts = languageCode.split('-');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  // 获取语言显示名称
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  // 获取所有支持的语言
  static List<Map<String, String>> getAllLanguages() {
    return languageNames.entries
        .map((entry) => {'code': entry.key, 'name': entry.value})
        .toList();
  }

  // 检查是否需要重启应用
  static bool needsRestart(String newLanguage) {
    return currentLanguage != newLanguage;
  }
}
