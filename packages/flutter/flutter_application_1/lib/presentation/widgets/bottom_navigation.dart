import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../core/state/app_state_manager.dart';

/// 底部导航栏组件
class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appStateManager, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: appStateManager.isDarkMode
                  ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                  : [Colors.white, Colors.grey.shade50],
            ),
            boxShadow: [
              BoxShadow(
                color: appStateManager.isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            border: appStateManager.isDarkMode
                ? Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.transparent,
                selectedItemColor: appStateManager.isDarkMode
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                unselectedItemColor: appStateManager.isDarkMode
                    ? Colors.white54
                    : Colors.grey,
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: appStateManager.isDarkMode
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                  color: appStateManager.isDarkMode
                      ? Colors.white54
                      : Colors.grey,
                ),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: appStateManager.showComparison
                        ? 0
                        : appStateManager.currentTabIndex,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onTap: (index) => appStateManager.setCurrentTab(index),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart, size: 28),
                        label: '产品选择',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.calculate, size: 28),
                        label: '计算器',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.currency_exchange, size: 28),
                        label: '汇率换算',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings, size: 28),
                        label: '设置',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
