import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/product_selection_screen.dart';
import 'screens/product_comparison_screen.dart';
import 'screens/settings_screen.dart';
import 'services/settings_service.dart';
import 'services/theme_manager.dart';
import 'services/language_service.dart';
import 'services/language_manager.dart';
import 'services/data_service.dart';
import 'services/global_data_cache.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('🚀 开始应用初始化...');

    // 初始化基础服务
    await SettingsService.init();
    await LanguageService.init();
    await LanguageManager().init();
    print('✅ 基础服务初始化完成');

    // 预加载所有数据，避免首次加载延迟
    print('⏳ 开始预加载数据...');
    final startTime = DateTime.now();

    // 预加载产品数据
    final products = await DataService.getAllProducts();

    // 预加载静态数据（同步方法）
    DataService.getAllCategories();
    DataService.getAllCompanies();

    // 设置全局缓存
    GlobalDataCache.setProducts(products);

    final endTime = DateTime.now();
    print('✅ 数据预加载完成，耗时: ${endTime.difference(startTime).inMilliseconds}ms');
  } catch (e) {
    print('❌ 应用初始化失败: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeManager _themeManager = ThemeManager();
  final LanguageManager _languageManager = LanguageManager();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_themeManager, _languageManager]),
      builder: (context, child) {
        return MaterialApp(
          title: '产品对比应用',
          theme: _themeManager.lightTheme,
          darkTheme: _themeManager.darkTheme,
          themeMode: _themeManager.themeMode,
          locale: _languageManager.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageService.supportedLocales,
          home: const MainNavigationPage(),
        );
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // 添加产品对比页面的状态管理
  List<String> _selectedProductIds = [];
  bool _showComparison = false;

  // 延迟初始化页面列表
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ProductSelectionScreen(onNavigateToComparison: showProductComparison),
      const CalculatorPage(title: '计算器'),
      const SettingsScreen(),
    ];
  }

  // 获取当前显示的页面
  Widget get _currentPage {
    if (_showComparison && _selectedProductIds.isNotEmpty) {
      return ProductComparisonScreen(
        selectedProductIds: _selectedProductIds,
        onBackPressed: returnToProductSelection,
      );
    }
    return _pages[_currentIndex];
  }

  // 显示产品对比页面
  void showProductComparison(List<String> selectedProductIds) {
    setState(() {
      _selectedProductIds = selectedProductIds;
      _showComparison = true;
    });
  }

  // 返回产品选择页面
  void returnToProductSelection() {
    setState(() {
      _showComparison = false;
      _selectedProductIds.clear();
    });
  }

  // 获取本地化文本
  String _getLocalizedText(BuildContext context, String key) {
    try {
      final l10n = AppLocalizations.of(context);
      switch (key) {
        case 'productComparison':
          return l10n.productComparison;
        case 'calculator':
          return l10n.calculator;
        case 'settings':
          return l10n.settings;
        default:
          return key;
      }
    } catch (e) {
      // 如果本地化失败，返回默认中文文本
      switch (key) {
        case 'productComparison':
          return '产品对比';
        case 'calculator':
          return '计算器';
        case 'settings':
          return '设置';
        default:
          return key;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [Colors.white, Colors.grey.shade50],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          border: Theme.of(context).brightness == Brightness.dark
              ? Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.transparent,
              selectedItemColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Theme.of(context).primaryColor,
              unselectedItemColor:
                  Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.grey,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.grey,
              ),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _showComparison ? 0 : _currentIndex,
            onTap: (index) {
              setState(() {
                if (_showComparison && index == 0) {
                  // 如果已经在对比页面，点击对比按钮返回产品选择页面
                  _showComparison = false;
                  _selectedProductIds.clear();
                } else {
                  // 切换到其他页面
                  _currentIndex = index;
                  _showComparison = false;
                  _selectedProductIds.clear();
                }
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.compare_arrows, size: 28),
                label: _getLocalizedText(context, 'productComparison'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calculate, size: 28),
                label: _getLocalizedText(context, 'calculator'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings, size: 28),
                label: _getLocalizedText(context, 'settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, required this.title});

  // 简单四则运算计算器首页
  final String title;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _previousValue;
  String? _operator; // '+', '-', '×', '÷'
  bool _shouldClearOnNextDigit = false; // 按下运算符或等号后，下一次输入应清空

  void _onDigit(String digit) {
    setState(() {
      if (_shouldClearOnNextDigit) {
        _display = '0';
        _shouldClearOnNextDigit = false;
      }
      if (digit == '.') {
        if (!_display.contains('.')) {
          _display = _display + '.';
        }
        return;
      }
      if (_display == '0') {
        _display = digit;
      } else {
        _display = _display + digit;
      }
    });
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _previousValue = null;
      _operator = null;
      _shouldClearOnNextDigit = false;
    });
  }

  void _onDelete() {
    setState(() {
      if (_shouldClearOnNextDigit) {
        _display = '0';
        _shouldClearOnNextDigit = false;
        return;
      }
      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _onOperator(String op) {
    final current = double.tryParse(_display) ?? 0.0;
    setState(() {
      if (_previousValue != null &&
          _operator != null &&
          !_shouldClearOnNextDigit) {
        // 连续运算：先结算上一个操作
        _previousValue = _calculate(_previousValue!, current, _operator!);
        _display = _trimNumber(_previousValue!);
      } else {
        _previousValue = current;
      }
      _operator = op;
      _shouldClearOnNextDigit = true;
    });
  }

  void _onEqual() {
    final current = double.tryParse(_display) ?? 0.0;
    setState(() {
      if (_previousValue != null && _operator != null) {
        final result = _calculate(_previousValue!, current, _operator!);
        _display = _trimNumber(result);
        _previousValue = null;
        _operator = null;
        _shouldClearOnNextDigit = true;
      }
    });
  }

  double _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) {
          return double.nan;
        }
        return a / b;
      default:
        return b;
    }
  }

  String _trimNumber(double value) {
    if (value.isNaN) return '错误';
    final str = value.toStringAsFixed(12);
    // 去除多余的 0 和小数点
    var trimmed = str;
    while (trimmed.contains('.') &&
        (trimmed.endsWith('0') || trimmed.endsWith('.'))) {
      trimmed = trimmed.endsWith('.')
          ? trimmed.substring(0, trimmed.length - 1)
          : trimmed.substring(0, trimmed.length - 1);
      if (trimmed.endsWith('.')) {
        trimmed = trimmed.substring(0, trimmed.length - 1);
        break;
      }
    }
    return trimmed.isEmpty ? '0' : trimmed;
  }

  Widget _buildButton(String text, {Color? color, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opColor = Theme.of(context).colorScheme.secondaryContainer;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: FittedBox(
                alignment: Alignment.bottomRight,
                fit: BoxFit.scaleDown,
                child: Text(
                  _display,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        'AC',
                        color: opColor,
                        onTap: _onClear,
                      ),
                    ),
                    Expanded(
                      child: _buildButton(
                        'DEL',
                        color: opColor,
                        onTap: _onDelete,
                      ),
                    ),
                    Expanded(
                      child: _buildButton(
                        '÷',
                        color: opColor,
                        onTap: () => _onOperator('÷'),
                      ),
                    ),
                    Expanded(
                      child: _buildButton(
                        '×',
                        color: opColor,
                        onTap: () => _onOperator('×'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton('7', onTap: () => _onDigit('7')),
                    ),
                    Expanded(
                      child: _buildButton('8', onTap: () => _onDigit('8')),
                    ),
                    Expanded(
                      child: _buildButton('9', onTap: () => _onDigit('9')),
                    ),
                    Expanded(
                      child: _buildButton(
                        '-',
                        color: opColor,
                        onTap: () => _onOperator('-'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton('4', onTap: () => _onDigit('4')),
                    ),
                    Expanded(
                      child: _buildButton('5', onTap: () => _onDigit('5')),
                    ),
                    Expanded(
                      child: _buildButton('6', onTap: () => _onDigit('6')),
                    ),
                    Expanded(
                      child: _buildButton(
                        '+',
                        color: opColor,
                        onTap: () => _onOperator('+'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildButton('1', onTap: () => _onDigit('1')),
                    ),
                    Expanded(
                      child: _buildButton('2', onTap: () => _onDigit('2')),
                    ),
                    Expanded(
                      child: _buildButton('3', onTap: () => _onDigit('3')),
                    ),
                    Expanded(
                      child: _buildButton('=', color: opColor, onTap: _onEqual),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildButton('0', onTap: () => _onDigit('0')),
                    ),
                    Expanded(
                      child: _buildButton('.', onTap: () => _onDigit('.')),
                    ),
                    Expanded(child: const SizedBox.shrink()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
