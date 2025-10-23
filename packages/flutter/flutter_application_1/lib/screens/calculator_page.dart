import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorPage extends StatefulWidget {
  final String title;

  const CalculatorPage({super.key, required this.title});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _operation = '';
  double _firstNumber = 0;
  double _secondNumber = 0;
  bool _waitingForOperand = false;

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
        _calculate();
      } else if (['+', '-', '×', '÷'].contains(buttonText)) {
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

  void _calculate() {
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
        } else {
          _display = 'Error';
          return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
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
      body: Column(
        children: [
          // 显示屏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
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
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_operation.isNotEmpty)
                  Text(
                    '$_firstNumber $_operation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          // 按钮区域
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // 第一行：清除和删除
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('C', Colors.red.shade400),
                        _buildButton('⌫', Colors.orange.shade400),
                        _buildButton('÷', Colors.blue.shade400),
                        _buildButton('×', Colors.blue.shade400),
                      ],
                    ),
                  ),
                  // 第二行：7, 8, 9, -
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('-', Colors.blue.shade400),
                      ],
                    ),
                  ),
                  // 第三行：4, 5, 6, +
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('+', Colors.blue.shade400),
                      ],
                    ),
                  ),
                  // 第四行：1, 2, 3, =
                  Expanded(
                    child: Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('=', Colors.green.shade400),
                      ],
                    ),
                  ),
                  // 第五行：0, .
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _buildButton('0')),
                        _buildButton('.'),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, [Color? color, bool isTall = false]) {
    final buttonColor = color ?? Theme.of(context).colorScheme.surface;
    final textColor = color != null
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        height: isTall ? double.infinity : null,
        child: FilledButton(
          onPressed: () => _onButtonPressed(text),
          style: FilledButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
