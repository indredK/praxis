import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../services/exchange_rate_service.dart';

class CalculatorPage extends StatefulWidget {
  final String title;

  const CalculatorPage({super.key, required this.title});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage>
    with TickerProviderStateMixin {
  String _display = '0';
  String _operation = '';
  double _firstNumber = 0;
  double _secondNumber = 0;
  bool _waitingForOperand = false;

  // 汇率换算相关
  late TabController _tabController;
  String _fromCurrency = 'USD';
  String _toCurrency = 'CNY';
  double _exchangeAmount = 0.0;
  double _convertedAmount = 0.0;
  bool _isExchangeLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _display = '0';
        _operation = '';
        _firstNumber = 0;
        _secondNumber = 0;
        _waitingForOperand = false;
      } else if (buttonText == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (buttonText == '=') {
        _calculateResult();
      } else if (['+', '-', '×', '÷'].contains(buttonText)) {
        if (_operation.isNotEmpty && !_waitingForOperand) {
          _calculateResult();
        }
        _operation = buttonText;
        _firstNumber = double.parse(_display);
        _waitingForOperand = true;
      } else {
        if (_waitingForOperand) {
          _display = buttonText;
          _waitingForOperand = false;
        } else {
          _display = _display == '0' ? buttonText : _display + buttonText;
        }
      }
    });
  }

  void _calculateResult() {
    _secondNumber = double.parse(_display);
    double result = 0;
    switch (_operation) {
      case '+':
        result = _firstNumber + _secondNumber;
        break;
      case '-':
        result = _firstNumber - _secondNumber;
        break;
      case '×':
        result = _firstNumber * _secondNumber;
        break;
      case '÷':
        if (_secondNumber != 0) {
          result = _firstNumber / _secondNumber;
        }
        break;
    }
    _display = result.toString();
    if (_display.endsWith('.0')) {
      _display = _display.substring(0, _display.length - 2);
    }
    _operation = '';
    _waitingForOperand = true;
  }

  // 汇率换算方法
  Future<void> _convertExchangeRate() async {
    if (_exchangeAmount <= 0) return;

    setState(() {
      _isExchangeLoading = true;
    });

    try {
      final converted = await ExchangeRateService.convertCurrency(
        amount: _exchangeAmount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );
      setState(() {
        _convertedAmount = converted;
        _isExchangeLoading = false;
      });
    } catch (e) {
      setState(() {
        _isExchangeLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('汇率转换失败: $e')));
      }
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convertExchangeRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.05),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppBar(
                title: Text(
                  widget.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _display));
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.onSurface,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).primaryColor,
              dividerColor: Theme.of(context).colorScheme.outline,
              tabs: const [
                Tab(icon: Icon(Icons.calculate), text: '计算器'),
                Tab(icon: Icon(Icons.currency_exchange), text: '汇率换算'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildCalculatorTab(), _buildExchangeRateTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return Column(
      children: [
        // 显示屏
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _display,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.end,
              ),
              if (_operation.isNotEmpty)
                Text(
                  '$_firstNumber $_operation',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
        // 按钮网格
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('C', Colors.red),
                      _buildButton('⌫', Colors.orange),
                      _buildButton('÷', Colors.blue),
                      _buildButton('×', Colors.blue),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('-', Colors.blue),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('+', Colors.blue),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('=', Colors.green, 1, 2),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('0', null, 2, 1),
                      _buildButton('.'),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    String text, [
    Color? color,
    double width = 1,
    double height = 1,
  ]) {
    final buttonColor =
        color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = color != null
        ? Colors.white
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Expanded(
      flex: (width * 100).round(),
      child: Container(
        height: height == 2 ? 120 : 60,
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeRateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '输入金额',
                      hintText: '请输入要换算的金额',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: const OutlineInputBorder(),
                      suffixText: ExchangeRateService.getCurrencySymbol(
                        _fromCurrency,
                      ),
                    ),
                    onChanged: (value) {
                      final amount = double.tryParse(value);
                      if (amount != null) {
                        setState(() {
                          _exchangeAmount = amount;
                        });
                        _convertExchangeRate();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '从',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _fromCurrency,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: ExchangeRateService
                                  .supportedCurrencies
                                  .entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(
                                        '${entry.value} (${entry.key})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _fromCurrency = value;
                                  });
                                  _convertExchangeRate();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _swapCurrencies,
                        icon: const Icon(Icons.swap_horiz),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '到',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _toCurrency,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: ExchangeRateService
                                  .supportedCurrencies
                                  .entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(
                                        '${entry.value} (${entry.key})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _toCurrency = value;
                                  });
                                  _convertExchangeRate();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '换算结果',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (_isExchangeLoading)
                          const CircularProgressIndicator()
                        else
                          Text(
                            ExchangeRateService.formatAmount(
                              _convertedAmount,
                              _toCurrency,
                            ),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '常用汇率',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, double>>(
                    future: ExchangeRateService.getExchangeRates('USD'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final rates = snapshot.data!;
                        final commonPairs = [
                          {'from': 'USD', 'to': 'CNY'},
                          {'from': 'USD', 'to': 'HKD'},
                          {'from': 'CNY', 'to': 'HKD'},
                          {'from': 'USD', 'to': 'JPY'},
                        ];
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: commonPairs.map((pair) {
                            final rate = rates[pair['to']] ?? 1.0;
                            return Chip(
                              label: Text(
                                '1 ${pair['from']} = ${rate.toStringAsFixed(2)} ${pair['to']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.3),
                              ),
                            );
                          }).toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('加载失败: ${snapshot.error}');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
