import 'dart:convert';
import 'package:http/http.dart' as http;

/// 汇率换算服务
class ExchangeRateService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  // 支持的货币列表
  static const Map<String, String> supportedCurrencies = {
    'USD': '美元',
    'CNY': '人民币',
    'HKD': '港币',
    'TWD': '台币',
    'SGD': '新加坡元',
    'JPY': '日元',
  };

  // 货币符号映射
  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'CNY': '¥',
    'HKD': 'HK\$',
    'TWD': 'NT\$',
    'SGD': 'S\$',
    'JPY': '¥',
  };

  // 缓存汇率数据
  static Map<String, double>? _cachedRates;
  static DateTime? _lastUpdateTime;
  static const Duration _cacheExpiry = Duration(hours: 1);

  /// 获取汇率数据
  static Future<Map<String, double>> getExchangeRates(
    String baseCurrency,
  ) async {
    // 检查缓存是否有效
    if (_cachedRates != null &&
        _lastUpdateTime != null &&
        DateTime.now().difference(_lastUpdateTime!) < _cacheExpiry) {
      return _cachedRates!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$baseCurrency'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(data['rates']);

        // 更新缓存
        _cachedRates = rates;
        _lastUpdateTime = DateTime.now();

        return rates;
      } else {
        throw Exception(
          'Failed to load exchange rates: ${response.statusCode}',
        );
      }
    } catch (e) {
      // 返回默认汇率（基于2024年的近似汇率）
      return _getDefaultRates(baseCurrency);
    }
  }

  /// 获取默认汇率（离线备用）
  static Map<String, double> _getDefaultRates(String baseCurrency) {
    // 基于USD的默认汇率
    const defaultRates = {
      'USD': 1.0,
      'CNY': 7.2,
      'HKD': 7.8,
      'TWD': 31.5,
      'SGD': 1.35,
      'JPY': 150.0,
    };

    if (baseCurrency == 'USD') {
      return defaultRates;
    }

    // 计算其他货币的汇率
    final baseRate = defaultRates[baseCurrency] ?? 1.0;
    final convertedRates = <String, double>{};

    for (final entry in defaultRates.entries) {
      convertedRates[entry.key] = entry.value / baseRate;
    }

    return convertedRates;
  }

  /// 货币换算
  static Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    try {
      final rates = await getExchangeRates(fromCurrency);
      final rate = rates[toCurrency] ?? 1.0;
      return amount * rate;
    } catch (e) {
      return amount; // 返回原金额
    }
  }

  /// 获取货币符号
  static String getCurrencySymbol(String currencyCode) {
    return currencySymbols[currencyCode] ?? currencyCode;
  }

  /// 获取货币名称
  static String getCurrencyName(String currencyCode) {
    return supportedCurrencies[currencyCode] ?? currencyCode;
  }

  /// 格式化金额
  static String formatAmount(double amount, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);

    // 根据货币类型选择不同的格式化方式
    switch (currencyCode) {
      case 'JPY':
        return '$symbol${amount.toStringAsFixed(0)}';
      case 'CNY':
      case 'HKD':
      case 'TWD':
      case 'SGD':
        return '$symbol${amount.toStringAsFixed(2)}';
      case 'USD':
        return '$symbol${amount.toStringAsFixed(2)}';
      default:
        return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  /// 清除缓存
  static void clearCache() {
    _cachedRates = null;
    _lastUpdateTime = null;
  }
}
