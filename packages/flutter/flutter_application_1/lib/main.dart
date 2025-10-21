import 'package:flutter/material.dart';
import 'screens/product_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 该部件是应用程序的根部件。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '产品对比应用',
      theme: ThemeData(
        // 这是应用程序的主题配置。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
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

  final List<Widget> _pages = [
    const ProductSelectionScreen(),
    const CalculatorPage(title: '计算器'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.compare_arrows, size: 28),
              label: '产品对比',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate, size: 28),
              label: '计算器',
            ),
          ],
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
