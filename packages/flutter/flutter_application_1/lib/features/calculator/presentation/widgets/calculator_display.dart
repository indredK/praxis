import 'package:flutter/material.dart';

/// 计算器显示屏组件
class CalculatorDisplay extends StatelessWidget {
  final String display;

  const CalculatorDisplay({super.key, required this.display});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        alignment: Alignment.bottomRight,
        fit: BoxFit.scaleDown,
        child: Text(
          display,
          maxLines: 1,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
