import 'package:get_it/get_it.dart';
import '../../core/state/app_state_manager.dart';
import '../../core/navigation/navigation_manager.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/datasources/api_datasource.dart';
import '../../data/datasources/api_datasource_impl.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/datasources/local_datasource_impl.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/cache_service_impl.dart';
import '../../presentation/viewmodels/main_viewmodel.dart';
import '../../presentation/viewmodels/calculator_viewmodel.dart';

/// 服务定位器
/// 使用GetIt进行依赖注入管理
final GetIt sl = GetIt.instance;

/// 初始化依赖注入
Future<void> initializeDependencies() async {
  // 核心服务
  sl.registerLazySingleton<AppStateManager>(() => AppStateManager());
  sl.registerLazySingleton<NavigationManager>(() => NavigationManager());

  // 数据源
  sl.registerLazySingleton<ApiDataSource>(() => ApiDataSourceImpl());
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl());
  sl.registerLazySingleton<CacheService>(() => CacheServiceImpl());

  // 仓库
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      apiDataSource: sl<ApiDataSource>(),
      localDataSource: sl<LocalDataSource>(),
      cacheService: sl<CacheService>(),
    ),
  );

  // ViewModels
  sl.registerFactory<MainViewModel>(
    () => MainViewModel(
      appStateManager: sl<AppStateManager>(),
      productRepository: sl<ProductRepository>(),
    ),
  );

  sl.registerFactory<CalculatorViewModel>(() => CalculatorViewModel());
}

/// 重置所有依赖
void resetDependencies() {
  sl.reset();
}
