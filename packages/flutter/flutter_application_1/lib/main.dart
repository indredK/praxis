import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'core/state/app_state_manager.dart';
import 'core/navigation/navigation_manager.dart';
import 'core/constants/app_constants.dart';
import 'presentation/pages/main_page.dart';
import 'features/calculator/presentation/pages/calculator_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/exchange_rate/presentation/pages/exchange_rate_page.dart';
import 'presentation/pages/product_comparison_page.dart';
import 'presentation/pages/product_selection_page.dart';
import 'presentation/viewmodels/main_viewmodel.dart';
import 'features/calculator/domain/viewmodels/calculator_viewmodel.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化依赖注入
    await initializeDependencies();

    // 初始化应用状态
    await sl<AppStateManager>().initialize();

    runApp(const MyApp());
  } catch (e) {
    // 初始化失败时仍然启动应用，但使用默认配置
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AppStateManager>()),
        ChangeNotifierProvider(create: (_) => sl<MainViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<CalculatorViewModel>()),
      ],
      child: Consumer<AppStateManager>(
        builder: (context, appStateManager, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // 主题配置
            theme: _buildLightTheme(appStateManager.primaryColor),
            darkTheme: _buildDarkTheme(appStateManager.primaryColor),
            themeMode: appStateManager.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            // 导航配置
            navigatorKey: NavigationManager.navigatorKey,
            scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),

            // 本地化配置
            locale: appStateManager.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
              Locale('ja', 'JP'),
            ],

            // 路由配置
            initialRoute: AppConstants.routeHome,
            routes: _buildRoutes(),
            onGenerateRoute: _generateRoute,
          );
        },
      ),
    );
  }

  /// 构建浅色主题
  ThemeData _buildLightTheme(Color primaryColor) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: null,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  /// 构建深色主题
  ThemeData _buildDarkTheme(Color primaryColor) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: null,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  /// 构建路由表
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      AppConstants.routeHome: (context) => const MainPage(),
      AppConstants.routeCalculator: (context) => const CalculatorPage(),
      AppConstants.routeExchangeRate: (context) => const ExchangeRatePage(),
      AppConstants.routeSettings: (context) => const SettingsPage(),
    };
  }

  /// 生成路由
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeProductComparison:
        final args = settings.arguments as Map<String, dynamic>?;
        final productIds = args?['productIds'] as List<String>? ?? [];
        return MaterialPageRoute(
          builder: (context) => ProductComparisonPage(
            productIds: productIds,
            onBackPressed: () => Navigator.pop(context),
          ),
        );
      case AppConstants.routeProductDetail:
        return MaterialPageRoute(
          builder: (context) => ProductSelectionPage(), // 暂时使用产品选择页面
        );
      default:
        return null;
    }
  }
}
