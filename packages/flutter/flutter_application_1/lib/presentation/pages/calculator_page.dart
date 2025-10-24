import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculator_viewmodel.dart';
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
