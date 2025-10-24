import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// 计算器键盘组件
class CalculatorKeypad extends StatelessWidget {
  final Function(String) onDigit;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final Function(String) onOperator;
  final VoidCallback onEqual;

  const CalculatorKeypad({
    super.key,
    required this.onDigit,
    required this.onClear,
    required this.onDelete,
    required this.onOperator,
    required this.onEqual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Column(
        children: [
          // 第一行：AC, DEL, ÷, ×
          Expanded(
            child: Row(
              children: [
                _buildButton('AC', onClear, isDark, theme),
                _buildButton('DEL', onDelete, isDark, theme),
                _buildButton('÷', () => onOperator('÷'), isDark, theme),
                _buildButton('×', () => onOperator('×'), isDark, theme),
              ],
            ),
          ),

          // 第二行：7, 8, 9, -
          Expanded(
            child: Row(
              children: [
                _buildButton('7', () => onDigit('7'), isDark, theme),
                _buildButton('8', () => onDigit('8'), isDark, theme),
                _buildButton('9', () => onDigit('9'), isDark, theme),
                _buildButton('-', () => onOperator('-'), isDark, theme),
              ],
            ),
          ),

          // 第三行：4, 5, 6, +
          Expanded(
            child: Row(
              children: [
                _buildButton('4', () => onDigit('4'), isDark, theme),
                _buildButton('5', () => onDigit('5'), isDark, theme),
                _buildButton('6', () => onDigit('6'), isDark, theme),
                _buildButton('+', () => onOperator('+'), isDark, theme),
              ],
            ),
          ),

          // 第四行：1, 2, 3, =
          Expanded(
            child: Row(
              children: [
                _buildButton('1', () => onDigit('1'), isDark, theme),
                _buildButton('2', () => onDigit('2'), isDark, theme),
                _buildButton('3', () => onDigit('3'), isDark, theme),
                _buildButton('=', onEqual, isDark, theme),
              ],
            ),
          ),

          // 第五行：0, .
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildButton('0', () => onDigit('0'), isDark, theme),
                ),
                Expanded(
                  child: _buildButton('.', () => onDigit('.'), isDark, theme),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建按钮
  Widget _buildButton(
    String text,
    VoidCallback onTap,
    bool isDark,
    ThemeData theme,
  ) {
    // 根据按钮类型和主题选择合适的颜色
    Color buttonColor;
    Color textColor;

    if (text == 'AC' || text == 'DEL') {
      buttonColor = isDark ? Colors.red.shade700 : Colors.red.shade500;
      textColor = Colors.white;
    } else if (text == '=') {
      buttonColor = isDark ? Colors.green.shade700 : Colors.green.shade500;
      textColor = Colors.white;
    } else if (['+', '-', '×', '÷'].contains(text)) {
      buttonColor = isDark ? Colors.blue.shade700 : Colors.blue.shade500;
      textColor = Colors.white;
    } else {
      // 数字按钮使用主题颜色
      buttonColor = isDark
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainer;
      textColor = theme.colorScheme.onSurface;
    }

    return Container(
      height: 72,
      margin: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: isDark ? 2 : 1,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
