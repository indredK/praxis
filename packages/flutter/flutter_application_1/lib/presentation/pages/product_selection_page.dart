import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state_manager.dart';
import '../viewmodels/main_viewmodel.dart';

/// 产品选择页面
class ProductSelectionPage extends StatelessWidget {
  const ProductSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('产品选择'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer2<AppStateManager, MainViewModel>(
        builder: (context, appStateManager, mainViewModel, child) {
          if (mainViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (mainViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mainViewModel.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => mainViewModel.clearError(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('产品选择页面 - 待实现'));
        },
      ),
    );
  }
}
