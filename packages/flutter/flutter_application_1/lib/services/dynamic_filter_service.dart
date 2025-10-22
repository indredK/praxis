import '../models/product_filter_models.dart';
import '../models/filter_tree.dart';
import '../services/filter_data_service.dart';

/// 动态筛选器服务 - 处理联动逻辑
class DynamicFilterService {
  // 私有构造函数，防止实例化
  DynamicFilterService._();

  /// 缓存数据
  static final Map<String, List<dynamic>> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// 检查缓存是否有效
  static bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// 设置缓存
  static void _setCache(String key, List<dynamic> data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 获取缓存
  static List<T>? _getCache<T>(String key) {
    if (!_isCacheValid(key)) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    return _cache[key]?.cast<T>();
  }

  /// 获取所有品牌
  static Future<List<Brand>> getAllBrands() async {
    const cacheKey = 'all_brands';
    final cached = _getCache<Brand>(cacheKey);
    if (cached != null) return cached;

    await Future.delayed(const Duration(milliseconds: 2000));

    final brands = [
      const Brand(
        id: 'brand_apple',
        name: 'Apple',
        displayName: '苹果',
        logo: 'assets/logos/apple.png',
      ),
      const Brand(
        id: 'brand_samsung',
        name: 'Samsung',
        displayName: '三星',
        logo: 'assets/logos/samsung.png',
      ),
      const Brand(
        id: 'brand_huawei',
        name: 'Huawei',
        displayName: '华为',
        logo: 'assets/logos/huawei.png',
      ),
      const Brand(
        id: 'brand_xiaomi',
        name: 'Xiaomi',
        displayName: '小米',
        logo: 'assets/logos/xiaomi.png',
      ),
    ];

    _setCache(cacheKey, brands);
    return brands;
  }

  /// 根据品牌获取产品类别
  static Future<List<Category>> getCategoriesByBrand(String brand) async {
    final cacheKey = 'categories_$brand';
    final cached = _getCache<Category>(cacheKey);
    if (cached != null) return cached;

    final categoriesData = await FilterDataService.getCategoriesByBrand(brand);
    final categories = categoriesData
        .map((data) => Category.fromJson(data))
        .toList();

    _setCache(cacheKey, categories);
    return categories;
  }

  /// 根据品牌和类别获取产品线
  static Future<List<ProductLine>> getProductLinesByBrandAndCategory(
    String brand,
    String category,
  ) async {
    final cacheKey = 'product_lines_${brand}_$category';
    final cached = _getCache<ProductLine>(cacheKey);
    if (cached != null) return cached;

    final productLinesData =
        await FilterDataService.getProductLinesByBrandAndCategory(
          brand,
          category,
        );
    final productLines = productLinesData
        .map((data) => ProductLine.fromJson(data))
        .toList();

    _setCache(cacheKey, productLines);
    return productLines;
  }

  /// 根据品牌、类别、产品线获取具体产品
  static Future<List<Product>> getProductsByBrandCategoryAndLine(
    String brand,
    String category,
    String productLine,
  ) async {
    final cacheKey = 'products_${brand}_${category}_$productLine';
    final cached = _getCache<Product>(cacheKey);
    if (cached != null) return cached;

    final productsData =
        await FilterDataService.getProductsByBrandCategoryAndLine(
          brand,
          category,
          productLine,
        );
    final products = productsData
        .map((data) => Product.fromJson(data))
        .toList();

    _setCache(cacheKey, products);
    return products;
  }

  /// 创建动态筛选器树
  static Future<List<FilterTreeNode>> createDynamicFilterTree({
    required String comparisonMode,
    required FilterSelectionState currentSelection,
    required Function(String nodeId, String? value) onSelectionChanged,
  }) async {
    if (comparisonMode == 'same_brand') {
      return await _createSameBrandFilterTree(
        currentSelection: currentSelection,
        onSelectionChanged: onSelectionChanged,
      );
    } else {
      // 同类对比模式使用同步方法
      return _createSameCategoryFilterTree(
        currentSelection: currentSelection,
        onSelectionChanged: onSelectionChanged,
      );
    }
  }

  /// 创建自家对比筛选器树
  static Future<List<FilterTreeNode>> _createSameBrandFilterTree({
    required FilterSelectionState currentSelection,
    required Function(String nodeId, String? value) onSelectionChanged,
  }) async {
    final List<FilterTreeNode> filterTree = [];

    // 1. 品牌选择
    final brands = await getAllBrands();
    filterTree.add(
      FilterTreeNode(
        id: 'brand_filter',
        title: '选择品牌',
        isExpanded: true,
        children: [
          FilterTreeNode(
            id: 'brand_all',
            title: '全部',
            value: '全部',
            isSelected:
                currentSelection.selectedBrand == null ||
                currentSelection.selectedBrand == '全部',
          ),
          ...brands.map(
            (brand) => FilterTreeNode(
              id: 'brand_${brand.name}',
              title: brand.displayName,
              value: brand.name,
              isSelected: currentSelection.selectedBrand == brand.name,
            ),
          ),
        ],
      ),
    );

    // 2. 产品类别选择（根据品牌动态加载）
    List<Category> categories = [];
    if (currentSelection.selectedBrand != null &&
        currentSelection.selectedBrand != '全部') {
      categories = await getCategoriesByBrand(currentSelection.selectedBrand!);
    }

    filterTree.add(
      FilterTreeNode(
        id: 'category_filter',
        title: '选择类别',
        isExpanded: true,
        children: [
          FilterTreeNode(
            id: 'category_all',
            title: '全部',
            value: '全部',
            isSelected:
                currentSelection.selectedCategory == null ||
                currentSelection.selectedCategory == '全部',
          ),
          ...categories.map(
            (category) => FilterTreeNode(
              id: 'category_${category.name}',
              title: category.displayName,
              value: category.name,
              isSelected: currentSelection.selectedCategory == category.name,
            ),
          ),
        ],
      ),
    );

    // 3. 产品线选择（根据品牌+类别动态加载）
    List<ProductLine> productLines = [];
    if (currentSelection.selectedBrand != null &&
        currentSelection.selectedBrand != '全部' &&
        currentSelection.selectedCategory != null &&
        currentSelection.selectedCategory != '全部') {
      productLines = await getProductLinesByBrandAndCategory(
        currentSelection.selectedBrand!,
        currentSelection.selectedCategory!,
      );
    }

    filterTree.add(
      FilterTreeNode(
        id: 'product_line_filter',
        title: '选择产品线',
        isExpanded: true,
        children: [
          FilterTreeNode(
            id: 'product_line_all',
            title: '全部',
            value: '全部',
            isSelected:
                currentSelection.selectedProductLine == null ||
                currentSelection.selectedProductLine == '全部',
          ),
          ...productLines.map(
            (productLine) => FilterTreeNode(
              id: 'product_line_${productLine.name}',
              title: productLine.displayName,
              value: productLine.name,
              isSelected:
                  currentSelection.selectedProductLine == productLine.name,
            ),
          ),
        ],
      ),
    );

    // 筛选器只有三级：品牌 → 类别 → 产品线
    // 选择产品线后，具体产品会在右边的产品列表中显示

    return filterTree;
  }

  /// 创建同类对比筛选器树（同步版本）
  static List<FilterTreeNode> createSameCategoryFilterTreeSync({
    required FilterSelectionState currentSelection,
    required Function(String nodeId, String? value) onSelectionChanged,
  }) {
    return _createSameCategoryFilterTree(
      currentSelection: currentSelection,
      onSelectionChanged: onSelectionChanged,
    );
  }

  /// 创建同类对比筛选器树
  static List<FilterTreeNode> _createSameCategoryFilterTree({
    required FilterSelectionState currentSelection,
    required Function(String nodeId, String? value) onSelectionChanged,
  }) {
    final List<FilterTreeNode> filterTree = [];

    // 1. 产品类别选择（固定列表，无"全部"选项）
    final categories = [
      const Category(
        id: 'category_electronics',
        name: 'Electronics',
        displayName: '电子产品',
      ),
      const Category(
        id: 'category_appliances',
        name: 'Appliances',
        displayName: '家电',
      ),
      const Category(
        id: 'category_software',
        name: 'Software',
        displayName: '软件服务',
      ),
      const Category(
        id: 'category_automotive',
        name: 'Automotive',
        displayName: '汽车',
      ),
      const Category(
        id: 'category_fashion',
        name: 'Fashion',
        displayName: '时尚',
      ),
    ];

    filterTree.add(
      FilterTreeNode(
        id: 'category_filter',
        title: '选择类别',
        isExpanded: true,
        children: categories
            .map(
              (category) => FilterTreeNode(
                id: 'category_${category.name}',
                title: category.displayName,
                value: category.name,
                isSelected: currentSelection.selectedCategory == category.name,
              ),
            )
            .toList(),
      ),
    );

    // 2. 产品线选择（固定列表，无"全部"选项，无级联关系）
    final productLines = [
      const ProductLine(
        id: 'product_line_phone',
        name: 'Phone',
        displayName: '手机',
      ),
      const ProductLine(
        id: 'product_line_tablet',
        name: 'Tablet',
        displayName: '平板',
      ),
      const ProductLine(
        id: 'product_line_laptop',
        name: 'Laptop',
        displayName: '笔记本电脑',
      ),
      const ProductLine(
        id: 'product_line_watch',
        name: 'Watch',
        displayName: '智能手表',
      ),
      const ProductLine(
        id: 'product_line_headphones',
        name: 'Headphones',
        displayName: '耳机',
      ),
      const ProductLine(
        id: 'product_line_camera',
        name: 'Camera',
        displayName: '相机',
      ),
    ];

    filterTree.add(
      FilterTreeNode(
        id: 'product_line_filter',
        title: '选择产品线',
        isExpanded: true,
        children: productLines
            .map(
              (productLine) => FilterTreeNode(
                id: 'product_line_${productLine.name}',
                title: productLine.displayName,
                value: productLine.name,
                isSelected:
                    currentSelection.selectedProductLine == productLine.name,
              ),
            )
            .toList(),
      ),
    );

    // 同类对比模式：类别和产品线都是独立的，必须都选择
    // 没有级联关系，都是前端固定数据
    return filterTree;
  }

  /// 清除缓存
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// 清除特定缓存
  static void clearCacheForKey(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }
}
