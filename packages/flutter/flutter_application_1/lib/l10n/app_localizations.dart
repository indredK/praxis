import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // 获取本地化字符串
  String get appTitle => _getString('appTitle');
  String get productComparison => _getString('productComparison');
  String get calculator => _getString('calculator');
  String get settings => _getString('settings');
  String get appearanceSettings => _getString('appearanceSettings');
  String get displaySettings => _getString('displaySettings');
  String get comparisonSettings => _getString('comparisonSettings');
  String get notificationSettings => _getString('notificationSettings');
  String get languageSettings => _getString('languageSettings');
  String get about => _getString('about');
  String get darkMode => _getString('darkMode');
  String get darkModeSubtitle => _getString('darkModeSubtitle');
  String get themeColor => _getString('themeColor');
  String get themeColorSubtitle => _getString('themeColorSubtitle');
  String get showPrices => _getString('showPrices');
  String get showPricesSubtitle => _getString('showPricesSubtitle');
  String get showSpecs => _getString('showSpecs');
  String get showSpecsSubtitle => _getString('showSpecsSubtitle');
  String get showCharts => _getString('showCharts');
  String get showChartsSubtitle => _getString('showChartsSubtitle');
  String get maxProducts => _getString('maxProducts');
  String get defaultCurrency => _getString('defaultCurrency');
  String get defaultCurrencySubtitle => _getString('defaultCurrencySubtitle');
  String get notifications => _getString('notifications');
  String get notificationsSubtitle => _getString('notificationsSubtitle');
  String get autoRefresh => _getString('autoRefresh');
  String get autoRefreshSubtitle => _getString('autoRefreshSubtitle');
  String get appLanguage => _getString('appLanguage');
  String get appLanguageSubtitle => _getString('appLanguageSubtitle');
  String get appVersion => _getString('appVersion');
  String get privacyPolicy => _getString('privacyPolicy');
  String get privacyPolicySubtitle => _getString('privacyPolicySubtitle');
  String get userFeedback => _getString('userFeedback');
  String get userFeedbackSubtitle => _getString('userFeedbackSubtitle');
  String get resetSettings => _getString('resetSettings');
  String get confirmReset => _getString('confirmReset');
  String get cancel => _getString('cancel');
  String get confirm => _getString('confirm');
  String get languageChangeTitle => _getString('languageChangeTitle');
  String get languageChangeMessage => _getString('languageChangeMessage');
  String get languageChanged => _getString('languageChanged');
  String get settingsReset => _getString('settingsReset');
  String get feedbackSubmitted => _getString('feedbackSubmitted');
  String get dataLoadFailed => _getString('dataLoadFailed');
  String get productComparisonLimit => _getString('productComparisonLimit');
  String get noProductsSelected => _getString('noProductsSelected');
  String get priceComparison => _getString('priceComparison');
  String get performanceAnalysis => _getString('performanceAnalysis');
  String get scatterAnalysis => _getString('scatterAnalysis');
  String get marketShare => _getString('marketShare');
  String get trendAnalysis => _getString('trendAnalysis');
  String get specComparison => _getString('specComparison');
  String get chartsDisabled => _getString('chartsDisabled');
  String get selectProducts => _getString('selectProducts');
  String get compareProducts => _getString('compareProducts');
  String get selectCategory => _getString('selectCategory');
  String get selectCompany => _getString('selectCompany');
  String get sameBrand => _getString('sameBrand');
  String get sameCategory => _getString('sameCategory');
  String get blue => _getString('blue');
  String get green => _getString('green');
  String get purple => _getString('purple');
  String get orange => _getString('orange');
  String get red => _getString('red');
  String get teal => _getString('teal');

  // Settings specific
  String get language => _getString('language');
  String get currentLanguage => _getString('currentLanguage');
  String get selectLanguage => _getString('selectLanguage');
  String get chinese => _getString('chinese');
  String get english => _getString('english');
  String get japanese => _getString('japanese');
  String get selectThemeColor => _getString('selectThemeColor');
  String get aboutApp => _getString('aboutApp');
  String get aboutDescription => _getString('aboutDescription');
  String get features => _getString('features');
  String get featureMultiDimension => _getString('featureMultiDimension');
  String get featureSmartAnalysis => _getString('featureSmartAnalysis');
  String get featureVisualization => _getString('featureVisualization');
  String get featurePersonalization => _getString('featurePersonalization');

  // Exchange Rate specific
  String get exchangeRate => _getString('exchangeRate');
  String get refreshRate => _getString('refreshRate');
  String get rateInfo => _getString('rateInfo');
  String get supportedCurrencies => _getString('supportedCurrencies');
  String get lastUpdate => _getString('lastUpdate');
  String get inputAmount => _getString('inputAmount');
  String get inputAmountHint => _getString('inputAmountHint');
  String get from => _getString('from');
  String get to => _getString('to');
  String get conversionResult => _getString('conversionResult');
  String get copyResult => _getString('copyResult');
  String get recalculate => _getString('recalculate');
  String get copiedToClipboard => _getString('copiedToClipboard');
  String get conversionFailed => _getString('conversionFailed');
  String get commonRates => _getString('commonRates');
  String get loadFailed => _getString('loadFailed');
  String get swapCurrencies => _getString('swapCurrencies');

  // 带参数的字符串
  String maxProductsSubtitle(int count) =>
      _getString('maxProductsSubtitle').replaceAll('{count}', count.toString());
  String themeChanged(String theme) =>
      _getString('themeChanged').replaceAll('{theme}', theme);

  // 获取本地化字符串的私有方法
  String _getString(String key) {
    final Map<String, String> strings = _getLocalizedStrings();
    return strings[key] ?? key;
  }

  // 获取本地化字符串映射
  Map<String, String> _getLocalizedStrings() {
    switch (locale.languageCode) {
      case 'zh':
        return _zhStrings;
      case 'en':
        return _enStrings;
      case 'ja':
        return _jaStrings;
      default:
        return _zhStrings;
    }
  }

  // 中文字符串
  static const Map<String, String> _zhStrings = {
    'appTitle': '产品对比应用',
    'productComparison': '产品对比',
    'calculator': '计算器',
    'settings': '设置',
    'appearanceSettings': '外观设置',
    'displaySettings': '显示设置',
    'comparisonSettings': '对比设置',
    'notificationSettings': '通知设置',
    'languageSettings': '语言设置',
    'about': '关于',
    'darkMode': '深色模式',
    'darkModeSubtitle': '切换到深色主题',
    'themeColor': '主题颜色',
    'themeColorSubtitle': '选择应用主题色',
    'showPrices': '显示价格',
    'showPricesSubtitle': '在产品列表中显示价格信息',
    'showSpecs': '显示规格',
    'showSpecsSubtitle': '在对比表格中显示详细规格',
    'showCharts': '显示图表',
    'showChartsSubtitle': '在对比页面中显示图表分析',
    'maxProducts': '最大产品数量',
    'maxProductsSubtitle': '最多选择 {count} 个产品进行对比',
    'defaultCurrency': '默认货币',
    'defaultCurrencySubtitle': '价格显示货币单位',
    'notifications': '推送通知',
    'notificationsSubtitle': '接收产品更新和价格变动通知',
    'autoRefresh': '自动刷新',
    'autoRefreshSubtitle': '自动刷新产品数据和价格信息',
    'appLanguage': '应用语言',
    'appLanguageSubtitle': '选择应用显示语言',
    'appVersion': '应用版本',
    'privacyPolicy': '隐私政策',
    'privacyPolicySubtitle': '查看隐私政策和使用条款',
    'userFeedback': '用户反馈',
    'userFeedbackSubtitle': '提交问题或建议',
    'resetSettings': '重置所有设置',
    'confirmReset': '确定要重置所有设置吗？此操作不可撤销。',
    'cancel': '取消',
    'confirm': '确定',
    'languageChangeTitle': '切换语言',
    'languageChangeMessage': '确定要切换语言吗？界面将立即更新为新语言。',
    'languageChanged': '语言已切换',
    'settingsReset': '设置已重置',
    'themeChanged': '已选择 {theme} 主题',
    'feedbackSubmitted': '感谢您的反馈！',
    'dataLoadFailed': '加载数据失败',
    'productComparisonLimit': '最多只能选择5个产品进行对比',
    'noProductsSelected': '请先选择要对比的产品',
    'priceComparison': '价格对比',
    'performanceAnalysis': '性能分析',
    'scatterAnalysis': '散点分析',
    'marketShare': '市场份额',
    'trendAnalysis': '趋势分析',
    'specComparison': '规格对比',
    'chartsDisabled': '图表显示已关闭',
    'selectProducts': '选择产品',
    'compareProducts': '对比产品',
    'selectCategory': '选择类别',
    'selectCompany': '选择公司',
    'sameBrand': '同品牌对比',
    'sameCategory': '同类别对比',
    'blue': '蓝色',
    'green': '绿色',
    'purple': '紫色',
    'orange': '橙色',
    'red': '红色',
    'teal': '青色',
    // Settings
    'language': '语言',
    'currentLanguage': '当前语言',
    'selectLanguage': '选择语言',
    'chinese': '中文',
    'english': 'English',
    'japanese': '日本語',
    'selectThemeColor': '选择主题颜色',
    'aboutApp': '产品对比分析',
    'aboutDescription': '一款强大的产品对比分析工具，帮助您做出明智的购买决策。',
    'features': '功能特点：',
    'featureMultiDimension': '• 多维度产品对比',
    'featureSmartAnalysis': '• 智能数据分析',
    'featureVisualization': '• 可视化图表展示',
    'featurePersonalization': '• 个性化设置',
    // Exchange Rate
    'exchangeRate': '汇率换算',
    'refreshRate': '刷新汇率',
    'rateInfo': '汇率信息',
    'supportedCurrencies': '支持货币',
    'lastUpdate': '更新时间',
    'inputAmount': '输入金额',
    'inputAmountHint': '请输入要换算的金额',
    'from': '从',
    'to': '到',
    'conversionResult': '换算结果',
    'copyResult': '复制结果',
    'recalculate': '重新换算',
    'copiedToClipboard': '已复制到剪贴板',
    'conversionFailed': '换算失败',
    'commonRates': '常用汇率',
    'loadFailed': '加载失败',
    'swapCurrencies': '交换货币',
  };

  // 英文字符串
  static const Map<String, String> _enStrings = {
    'appTitle': 'Product Comparison App',
    'productComparison': 'Product Comparison',
    'calculator': 'Calculator',
    'settings': 'Settings',
    'appearanceSettings': 'Appearance Settings',
    'displaySettings': 'Display Settings',
    'comparisonSettings': 'Comparison Settings',
    'notificationSettings': 'Notification Settings',
    'languageSettings': 'Language Settings',
    'about': 'About',
    'darkMode': 'Dark Mode',
    'darkModeSubtitle': 'Switch to dark theme',
    'themeColor': 'Theme Color',
    'themeColorSubtitle': 'Choose app theme color',
    'showPrices': 'Show Prices',
    'showPricesSubtitle': 'Display price information in product list',
    'showSpecs': 'Show Specifications',
    'showSpecsSubtitle': 'Display detailed specifications in comparison table',
    'showCharts': 'Show Charts',
    'showChartsSubtitle': 'Display chart analysis in comparison page',
    'maxProducts': 'Maximum Products',
    'maxProductsSubtitle': 'Select up to {count} products for comparison',
    'defaultCurrency': 'Default Currency',
    'defaultCurrencySubtitle': 'Price display currency unit',
    'notifications': 'Push Notifications',
    'notificationsSubtitle':
        'Receive product updates and price change notifications',
    'autoRefresh': 'Auto Refresh',
    'autoRefreshSubtitle':
        'Automatically refresh product data and price information',
    'appLanguage': 'App Language',
    'appLanguageSubtitle': 'Choose app display language',
    'appVersion': 'App Version',
    'privacyPolicy': 'Privacy Policy',
    'privacyPolicySubtitle': 'View privacy policy and terms of use',
    'userFeedback': 'User Feedback',
    'userFeedbackSubtitle': 'Submit issues or suggestions',
    'resetSettings': 'Reset All Settings',
    'confirmReset':
        'Are you sure you want to reset all settings? This action cannot be undone.',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'languageChangeTitle': 'Change Language',
    'languageChangeMessage':
        'Are you sure you want to change the language? The interface will update immediately.',
    'languageChanged': 'Language changed',
    'settingsReset': 'Settings reset',
    'themeChanged': 'Selected {theme} theme',
    'feedbackSubmitted': 'Thank you for your feedback!',
    'dataLoadFailed': 'Failed to load data',
    'productComparisonLimit':
        'You can only select up to 5 products for comparison',
    'noProductsSelected': 'Please select products to compare first',
    'priceComparison': 'Price Comparison',
    'performanceAnalysis': 'Performance Analysis',
    'scatterAnalysis': 'Scatter Analysis',
    'marketShare': 'Market Share',
    'trendAnalysis': 'Trend Analysis',
    'specComparison': 'Specification Comparison',
    'chartsDisabled': 'Charts display disabled',
    'selectProducts': 'Select Products',
    'compareProducts': 'Compare Products',
    'selectCategory': 'Select Category',
    'selectCompany': 'Select Company',
    'sameBrand': 'Same Brand Comparison',
    'sameCategory': 'Same Category Comparison',
    'blue': 'Blue',
    'green': 'Green',
    'purple': 'Purple',
    'orange': 'Orange',
    'red': 'Red',
    'teal': 'Teal',
    // Settings
    'language': 'Language',
    'currentLanguage': 'Current Language',
    'selectLanguage': 'Select Language',
    'chinese': '中文',
    'english': 'English',
    'japanese': '日本語',
    'selectThemeColor': 'Select Theme Color',
    'aboutApp': 'Product Comparison Analysis',
    'aboutDescription':
        'A powerful product comparison tool to help you make informed purchasing decisions.',
    'features': 'Features:',
    'featureMultiDimension': '• Multi-dimensional product comparison',
    'featureSmartAnalysis': '• Smart data analysis',
    'featureVisualization': '• Visual chart display',
    'featurePersonalization': '• Personalized settings',
    // Exchange Rate
    'exchangeRate': 'Exchange Rate',
    'refreshRate': 'Refresh Rate',
    'rateInfo': 'Rate Information',
    'supportedCurrencies': 'Supported Currencies',
    'lastUpdate': 'Last Update',
    'inputAmount': 'Input Amount',
    'inputAmountHint': 'Please enter the amount to convert',
    'from': 'From',
    'to': 'To',
    'conversionResult': 'Conversion Result',
    'copyResult': 'Copy Result',
    'recalculate': 'Recalculate',
    'copiedToClipboard': 'Copied to clipboard',
    'conversionFailed': 'Conversion failed',
    'commonRates': 'Common Rates',
    'loadFailed': 'Load failed',
    'swapCurrencies': 'Swap currencies',
  };

  // 日文字符串
  static const Map<String, String> _jaStrings = {
    'appTitle': '製品比較アプリ',
    'productComparison': '製品比較',
    'calculator': '計算機',
    'settings': '設定',
    'appearanceSettings': '外観設定',
    'displaySettings': '表示設定',
    'comparisonSettings': '比較設定',
    'notificationSettings': '通知設定',
    'languageSettings': '言語設定',
    'about': 'について',
    'darkMode': 'ダークモード',
    'darkModeSubtitle': 'ダークテーマに切り替え',
    'themeColor': 'テーマカラー',
    'themeColorSubtitle': 'アプリのテーマカラーを選択',
    'showPrices': '価格表示',
    'showPricesSubtitle': '製品リストで価格情報を表示',
    'showSpecs': '仕様表示',
    'showSpecsSubtitle': '比較テーブルで詳細仕様を表示',
    'showCharts': 'チャート表示',
    'showChartsSubtitle': '比較ページでチャート分析を表示',
    'maxProducts': '最大製品数',
    'maxProductsSubtitle': '最大{count}個の製品を比較選択',
    'defaultCurrency': 'デフォルト通貨',
    'defaultCurrencySubtitle': '価格表示通貨単位',
    'notifications': 'プッシュ通知',
    'notificationsSubtitle': '製品更新と価格変動通知を受信',
    'autoRefresh': '自動更新',
    'autoRefreshSubtitle': '製品データと価格情報を自動更新',
    'appLanguage': 'アプリ言語',
    'appLanguageSubtitle': 'アプリ表示言語を選択',
    'appVersion': 'アプリバージョン',
    'privacyPolicy': 'プライバシーポリシー',
    'privacyPolicySubtitle': 'プライバシーポリシーと利用規約を表示',
    'userFeedback': 'ユーザーフィードバック',
    'userFeedbackSubtitle': '問題や提案を送信',
    'resetSettings': 'すべての設定をリセット',
    'confirmReset': 'すべての設定をリセットしますか？この操作は元に戻せません。',
    'cancel': 'キャンセル',
    'confirm': '確認',
    'languageChangeTitle': '言語変更',
    'languageChangeMessage': '言語を変更してもよろしいですか？インターフェースがすぐに更新されます。',
    'languageChanged': '言語が変更されました',
    'settingsReset': '設定がリセットされました',
    'themeChanged': '{theme}テーマを選択しました',
    'feedbackSubmitted': 'フィードバックありがとうございます！',
    'dataLoadFailed': 'データの読み込みに失敗しました',
    'productComparisonLimit': '比較用に最大5個の製品しか選択できません',
    'noProductsSelected': '比較する製品を先に選択してください',
    'priceComparison': '価格比較',
    'performanceAnalysis': '性能分析',
    'scatterAnalysis': '散布分析',
    'marketShare': '市場シェア',
    'trendAnalysis': 'トレンド分析',
    'specComparison': '仕様比較',
    'chartsDisabled': 'チャート表示が無効',
    'selectProducts': '製品選択',
    'compareProducts': '製品比較',
    'selectCategory': 'カテゴリ選択',
    'selectCompany': '会社選択',
    'sameBrand': '同ブランド比較',
    'sameCategory': '同カテゴリ比較',
    'blue': '青',
    'green': '緑',
    'purple': '紫',
    'orange': 'オレンジ',
    'red': '赤',
    'teal': 'ティール',
    // Settings
    'language': '言語',
    'currentLanguage': '現在の言語',
    'selectLanguage': '言語選択',
    'chinese': '中文',
    'english': 'English',
    'japanese': '日本語',
    'selectThemeColor': 'テーマカラーを選択',
    'aboutApp': '製品比較分析',
    'aboutDescription': '賢明な購入決定を支援する強力な製品比較ツール。',
    'features': '機能：',
    'featureMultiDimension': '• 多次元製品比較',
    'featureSmartAnalysis': '• スマートデータ分析',
    'featureVisualization': '• ビジュアルチャート表示',
    'featurePersonalization': '• パーソナライズ設定',
    // Exchange Rate
    'exchangeRate': '為替レート',
    'refreshRate': 'レート更新',
    'rateInfo': 'レート情報',
    'supportedCurrencies': '対応通貨',
    'lastUpdate': '最終更新',
    'inputAmount': '金額入力',
    'inputAmountHint': '換算する金額を入力してください',
    'from': 'から',
    'to': 'へ',
    'conversionResult': '換算結果',
    'copyResult': '結果をコピー',
    'recalculate': '再計算',
    'copiedToClipboard': 'クリップボードにコピーしました',
    'conversionFailed': '換算失敗',
    'commonRates': 'よく使う為替レート',
    'loadFailed': '読み込み失敗',
    'swapCurrencies': '通貨を入れ替え',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en', 'ja'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
