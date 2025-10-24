import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state_manager.dart';
import '../viewmodels/main_viewmodel.dart';
import '../widgets/bottom_navigation.dart';
import '../../features/product/presentation/pages/product_selection_page.dart';
import '../../features/product/presentation/pages/product_comparison_page.dart';
import '../../features/calculator/presentation/pages/calculator_page.dart';
import '../../features/exchange_rate/presentation/pages/exchange_rate_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// 主页面
/// 包含底部导航和页面切换逻辑
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateManager, MainViewModel>(
      builder: (context, appStateManager, mainViewModel, child) {
        return Scaffold(
          body: _buildCurrentPage(appStateManager, mainViewModel),
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }

  /// 构建当前显示的页面
  Widget _buildCurrentPage(
    AppStateManager appStateManager,
    MainViewModel mainViewModel,
  ) {
    // 显示对比页面
    if (appStateManager.showComparison &&
        appStateManager.selectedProductIds.isNotEmpty) {
      return ProductComparisonPage(
        productIds: appStateManager.selectedProductIds,
        onBackPressed: () => appStateManager.hideComparison(),
      );
    }

    // 显示对应的标签页
    switch (appStateManager.currentTabIndex) {
      case 0:
        return const ProductSelectionPage();
      case 1:
        return const CalculatorPage();
      case 2:
        return const ExchangeRatePage();
      case 3:
        return const SettingsPage();
      default:
        return const ProductSelectionPage();
    }
  }
}
