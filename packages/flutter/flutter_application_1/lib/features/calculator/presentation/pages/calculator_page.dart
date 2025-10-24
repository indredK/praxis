import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/viewmodels/calculator_viewmodel.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_keypad.dart';

/// 计算器页面
class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('计算器'),
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
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<CalculatorViewModel>(
        builder: (context, calculatorViewModel, child) {
          return Column(
            children: [
              // 显示屏
              CalculatorDisplay(display: calculatorViewModel.display),

              // 按钮区域
              Expanded(
                child: CalculatorKeypad(
                  onDigit: calculatorViewModel.onDigit,
                  onClear: calculatorViewModel.onClear,
                  onDelete: calculatorViewModel.onDelete,
                  onOperator: calculatorViewModel.onOperator,
                  onEqual: calculatorViewModel.onEqual,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
