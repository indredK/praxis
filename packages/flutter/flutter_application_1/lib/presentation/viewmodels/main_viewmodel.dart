import 'package:flutter/foundation.dart';
import '../../core/state/app_state_manager.dart';
import '../../domain/repositories/product_repository.dart';
import '../../models/product.dart';

/// 主页面ViewModel
/// 管理主页面的业务逻辑和状态
class MainViewModel extends ChangeNotifier {
  final AppStateManager _appStateManager;
  final ProductRepository _productRepository;

  MainViewModel({
    required AppStateManager appStateManager,
    required ProductRepository productRepository,
  }) : _appStateManager = appStateManager,
       _productRepository = productRepository {
    _initialize();
  }

  // 页面状态
  bool _isInitialized = false;
  List<Product> _products = [];
  List<String> _categories = [];
  List<String> _companies = [];

  // Getters
  bool get isInitialized => _isInitialized;
  List<Product> get products => _products;
  List<String> get categories => _categories;
  List<String> get companies => _companies;
  List<String> get selectedProductIds => _appStateManager.selectedProductIds;
  bool get showComparison => _appStateManager.showComparison;
  int get currentTabIndex => _appStateManager.currentTabIndex;
  bool get isLoading => _appStateManager.isLoading;
  String? get errorMessage => _appStateManager.errorMessage;

  /// 初始化ViewModel
  Future<void> _initialize() async {
    try {
      _appStateManager.setLoading(true);

      // 并行加载数据
      await Future.wait([_loadProducts(), _loadCategories(), _loadCompanies()]);

      _isInitialized = true;
      _appStateManager.setLoading(false);
      notifyListeners();
    } catch (e) {
      _appStateManager.setError('初始化失败: $e');
      notifyListeners();
    }
  }

  /// 加载产品数据
  Future<void> _loadProducts() async {
    try {
      _products = await _productRepository.getAllProducts();
    } catch (e) {
      _products = [];
      rethrow;
    }
  }

  /// 加载类别数据
  Future<void> _loadCategories() async {
    try {
      _categories = await _productRepository.getAllCategories();
    } catch (e) {
      _categories = [];
      rethrow;
    }
  }

  /// 加载公司数据
  Future<void> _loadCompanies() async {
    try {
      _companies = await _productRepository.getAllCompanies();
    } catch (e) {
      _companies = [];
      rethrow;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    try {
      _appStateManager.setLoading(true);
      await _productRepository.refreshProducts();
      await _initialize();
    } catch (e) {
      _appStateManager.setError('刷新失败: $e');
    }
  }

  /// 添加选中的产品
  void addSelectedProduct(String productId) {
    _appStateManager.addSelectedProduct(productId);
    notifyListeners();
  }

  /// 移除选中的产品
  void removeSelectedProduct(String productId) {
    _appStateManager.removeSelectedProduct(productId);
    notifyListeners();
  }

  /// 设置选中的产品列表
  void setSelectedProducts(List<String> productIds) {
    _appStateManager.setSelectedProducts(productIds);
    notifyListeners();
  }

  /// 清空选中的产品
  void clearSelectedProducts() {
    _appStateManager.clearSelectedProducts();
    notifyListeners();
  }

  /// 显示对比页面
  void showComparisonPage() {
    _appStateManager.showComparisonPage();
    notifyListeners();
  }

  /// 隐藏对比页面
  void hideComparison() {
    _appStateManager.hideComparison();
    notifyListeners();
  }

  /// 设置当前标签页
  void setCurrentTab(int index) {
    _appStateManager.setCurrentTab(index);
    notifyListeners();
  }

  /// 搜索产品
  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _productRepository.searchProducts(query);
    } catch (e) {
      _appStateManager.setError('搜索失败: $e');
      return [];
    }
  }

  /// 根据类别筛选产品
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await _productRepository.getProductsByCategory(category);
    } catch (e) {
      _appStateManager.setError('获取产品失败: $e');
      return [];
    }
  }

  /// 根据公司筛选产品
  Future<List<Product>> getProductsByCompany(String company) async {
    try {
      return await _productRepository.getProductsByCompany(company);
    } catch (e) {
      _appStateManager.setError('获取产品失败: $e');
      return [];
    }
  }

  /// 清除错误信息
  void clearError() {
    _appStateManager.clearError();
    notifyListeners();
  }
}
