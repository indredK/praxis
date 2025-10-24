import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/exchange_rate_service.dart';

class ExchangeRatePage extends StatefulWidget {
  const ExchangeRatePage({super.key});

  @override
  State<ExchangeRatePage> createState() => _ExchangeRatePageState();
}

class _ExchangeRatePageState extends State<ExchangeRatePage> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'CNY';
  double _convertedAmount = 0.0;
  bool _isLoading = false;
  String _lastUpdateTime = '';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _convertCurrency();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    if (_amountController.text.isNotEmpty) {
      _convertCurrency();
    } else {
      setState(() {
        _convertedAmount = 0.0;
      });
    }
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final converted = await ExchangeRateService.convertCurrency(
        amount: amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );

      setState(() {
        _convertedAmount = converted;
        _isLoading = false;
        _lastUpdateTime = DateTime.now().toString().substring(0, 19);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('换算失败: $e')));
      }
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convertCurrency();
  }

  void _copyResult() {
    final result = ExchangeRateService.formatAmount(
      _convertedAmount,
      _toCurrency,
    );
    Clipboard.setData(ClipboardData(text: result));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('汇率换算'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.8),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 8,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ExchangeRateService.clearCache();
              _convertCurrency();
            },
            tooltip: '刷新汇率',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 汇率信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '汇率信息',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '支持货币: ${ExchangeRateService.supportedCurrencies.values.join('、')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_lastUpdateTime.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '更新时间: $_lastUpdateTime',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 换算界面
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 输入金额
                    TextField(
                      controller: _amountController,
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
                    ),
                    const SizedBox(height: 24),

                    // 货币选择行
                    Row(
                      children: [
                        // 源货币
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
                                value: _fromCurrency,
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
                                    _convertCurrency();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 交换按钮
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

                        // 目标货币
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
                                value: _toCurrency,
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
                                    _convertCurrency();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 换算结果
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
                          if (_isLoading)
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
                          const SizedBox(height: 8),
                          if (_amountController.text.isNotEmpty && !_isLoading)
                            Text(
                              '${ExchangeRateService.formatAmount(double.parse(_amountController.text), _fromCurrency)} = ${ExchangeRateService.formatAmount(_convertedAmount, _toCurrency)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _convertedAmount > 0
                                ? _copyResult
                                : null,
                            icon: const Icon(Icons.copy),
                            label: const Text('复制结果'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _convertCurrency,
                            icon: const Icon(Icons.refresh),
                            label: const Text('重新换算'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 常用汇率卡片
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
                    _buildCommonRates(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonRates() {
    final commonPairs = [
      {'from': 'USD', 'to': 'CNY'},
      {'from': 'USD', 'to': 'HKD'},
      {'from': 'CNY', 'to': 'HKD'},
      {'from': 'USD', 'to': 'JPY'},
      {'from': 'CNY', 'to': 'TWD'},
      {'from': 'USD', 'to': 'SGD'},
    ];

    return FutureBuilder<Map<String, double>>(
      future: ExchangeRateService.getExchangeRates('USD'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final rates = snapshot.data!;
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
    );
  }
}
