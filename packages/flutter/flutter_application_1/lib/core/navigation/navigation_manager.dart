import 'package:flutter/material.dart';

/// 导航管理器
/// 统一管理应用的路由导航
class NavigationManager {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  /// 获取当前上下文
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// 导航到指定页面
  static Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool replace = false,
  }) {
    if (replace) {
      return navigatorKey.currentState?.pushReplacementNamed<T, dynamic>(
            routeName,
            arguments: arguments,
          ) ??
          Future.value(null);
    } else {
      return navigatorKey.currentState?.pushNamed<T>(
            routeName,
            arguments: arguments,
          ) ??
          Future.value(null);
    }
  }

  /// 导航到产品对比页面
  static Future<void> navigateToComparison(List<String> productIds) {
    return navigateTo<void>(
      '/comparison',
      arguments: {'productIds': productIds},
    );
  }

  /// 导航到产品详情页面
  static Future<void> navigateToProductDetail(String productId) {
    return navigateTo<void>(
      '/product-detail',
      arguments: {'productId': productId},
    );
  }

  /// 导航到设置页面
  static Future<void> navigateToSettings() {
    return navigateTo<void>('/settings');
  }

  /// 导航到计算器页面
  static Future<void> navigateToCalculator() {
    return navigateTo<void>('/calculator');
  }

  /// 导航到汇率页面
  static Future<void> navigateToExchangeRate() {
    return navigateTo<void>('/exchange-rate');
  }

  /// 返回上一页
  static void goBack<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  /// 返回到根页面
  static void goToRoot() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  /// 显示对话框
  static Future<T?> showDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return builder(context);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
    );
  }

  /// 显示底部弹窗
  static Future<T?> showBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorKey.currentContext!,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  /// 显示SnackBar
  static void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: textColor)),
          duration: duration,
          backgroundColor: backgroundColor,
          action: action,
        ),
      );
    }
  }

  /// 显示加载对话框
  static void showLoadingDialog({String message = '加载中...'}) {
    showDialog(
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// 隐藏加载对话框
  static void hideLoadingDialog() {
    goBack();
  }
}
