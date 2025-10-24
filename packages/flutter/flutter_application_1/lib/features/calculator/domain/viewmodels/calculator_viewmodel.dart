import 'package:flutter/foundation.dart';

/// 计算器ViewModel
/// 管理计算器的业务逻辑和状态
class CalculatorViewModel extends ChangeNotifier {
  // 计算器状态
  String _display = '0';
  double? _previousValue;
  String? _operator;
  bool _shouldClearOnNextDigit = false;

  // 汇率相关状态
  String _fromCurrency = 'USD';
  String _toCurrency = 'CNY';
  double _exchangeAmount = 0.0;
  double _convertedAmount = 0.0;
  bool _isExchangeLoading = false;

  // Getters
  String get display => _display;
  String get fromCurrency => _fromCurrency;
  String get toCurrency => _toCurrency;
  double get exchangeAmount => _exchangeAmount;
  double get convertedAmount => _convertedAmount;
  bool get isExchangeLoading => _isExchangeLoading;

  /// 输入数字
  void onDigit(String digit) {
    if (_shouldClearOnNextDigit) {
      _display = '0';
      _shouldClearOnNextDigit = false;
    }

    if (digit == '.') {
      if (!_display.contains('.')) {
        _display = '$_display.';
      }
      return;
    }

    if (_display == '0') {
      _display = digit;
    } else {
      _display = '$_display$digit';
    }

    notifyListeners();
  }

  /// 清除所有
  void onClear() {
    _display = '0';
    _previousValue = null;
    _operator = null;
    _shouldClearOnNextDigit = false;
    notifyListeners();
  }

  /// 删除最后一位
  void onDelete() {
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

    notifyListeners();
  }

  /// 输入运算符
  void onOperator(String op) {
    final current = double.tryParse(_display) ?? 0.0;

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
    notifyListeners();
  }

  /// 计算结果
  void onEqual() {
    final current = double.tryParse(_display) ?? 0.0;

    if (_previousValue != null && _operator != null) {
      final result = _calculate(_previousValue!, current, _operator!);
      _display = _trimNumber(result);
      _previousValue = null;
      _operator = null;
      _shouldClearOnNextDigit = true;
    }

    notifyListeners();
  }

  /// 执行计算
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

  /// 格式化数字
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

  /// 设置汇率金额
  void setExchangeAmount(double amount) {
    _exchangeAmount = amount;
    notifyListeners();
  }

  /// 设置源货币
  void setFromCurrency(String currency) {
    _fromCurrency = currency;
    notifyListeners();
  }

  /// 设置目标货币
  void setToCurrency(String currency) {
    _toCurrency = currency;
    notifyListeners();
  }

  /// 交换货币
  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    notifyListeners();
  }

  /// 设置转换金额
  void setConvertedAmount(double amount) {
    _convertedAmount = amount;
    notifyListeners();
  }

  /// 设置汇率加载状态
  void setExchangeLoading(bool loading) {
    _isExchangeLoading = loading;
    notifyListeners();
  }

  /// 重置计算器
  void reset() {
    _display = '0';
    _previousValue = null;
    _operator = null;
    _shouldClearOnNextDigit = false;
    _exchangeAmount = 0.0;
    _convertedAmount = 0.0;
    _isExchangeLoading = false;
    notifyListeners();
  }
}
