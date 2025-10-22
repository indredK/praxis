import '../models/filter_data_model.dart';

/// 筛选器数据服务（模拟后端API）
class FilterDataService {
  // 私有构造函数，防止实例化
  FilterDataService._();

  /// 获取产品选择页面的筛选器配置
  static Future<FilterConfigDataModel> getProductSelectionFilterConfig() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 2000));

    // 模拟后端返回的JSON数据 - 重新设计的数据结构
    final jsonData = {
      'id': 'product_selection_config',
      'name': 'product_selection',
      'displayName': '产品选择筛选器',
      'description': '用于产品选择页面的筛选器配置',
      'isDefault': true,
      'config': {
        'width': 200,
        'fontSize': 11,
        'titleFontSize': 12,
        'backgroundColor': null,
        'selectedColor': null,
        'textColor': null,
        'titleColor': null,
        'padding': {'left': 8, 'top': 8, 'right': 8, 'bottom': 8},
        'borderRadius': 12,
      },
      'groups': [
        {
          'id': 'same_brand_group',
          'name': 'same_brand_filters',
          'displayName': '自家对比筛选器',
          'description': '自家品牌产品对比的筛选器',
          'isActive': true,
          'sortOrder': 1,
          'filters': [
            // 品牌选择 - 第一级
            {
              'id': 'brand_filter',
              'name': 'brand',
              'displayName': '选择品牌',
              'level': 0,
              'isLeaf': false,
              'isDefault': false,
              'children': [
                {
                  'id': 'brand_all',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'brand_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                {
                  'id': 'brand_apple',
                  'name': 'Apple',
                  'displayName': '苹果',
                  'parentId': 'brand_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'brand_samsung',
                  'name': 'Samsung',
                  'displayName': '三星',
                  'parentId': 'brand_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'brand_huawei',
                  'name': 'Huawei',
                  'displayName': '华为',
                  'parentId': 'brand_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
              ],
            },
            // 产品类别选择 - 第二级（根据品牌动态加载）
            {
              'id': 'category_filter',
              'name': 'category',
              'displayName': '选择类别',
              'level': 0,
              'isLeaf': false,
              'isDefault': false,
              'children': [
                {
                  'id': 'category_all',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'category_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                // 这些类别会根据选择的品牌动态加载
                // 例如：苹果 -> 电子产品、软件服务
                // 三星 -> 电子产品、家电
                // 华为 -> 电子产品、通信设备
              ],
            },
            // 细分产品线选择 - 第三级（根据品牌+类别动态加载）
            {
              'id': 'product_line_filter',
              'name': 'productLine',
              'displayName': '选择产品线',
              'level': 0,
              'isLeaf': false,
              'isDefault': false,
              'children': [
                {
                  'id': 'product_line_all',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'product_line_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                // 这些产品线会根据品牌+类别动态加载
                // 例如：苹果+电子产品 -> iPhone、iPad、Mac、Apple Watch
                // 三星+电子产品 -> Galaxy手机、Galaxy平板、Galaxy手表
              ],
            },
            // 具体产品选择 - 第四级（根据品牌+类别+产品线动态加载）
            {
              'id': 'product_filter',
              'name': 'product',
              'displayName': '选择产品',
              'level': 0,
              'isLeaf': false,
              'isDefault': false,
              'children': [
                {
                  'id': 'product_all',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'product_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                // 这些具体产品会根据前面的选择动态加载
                // 例如：苹果+电子产品+iPhone -> iPhone 15、iPhone 15 Pro、iPhone 14
              ],
            },
          ],
        },
        {
          'id': 'same_category_group',
          'name': 'same_category_filters',
          'displayName': '同类对比筛选器',
          'description': '同类产品对比的筛选器',
          'isActive': true,
          'sortOrder': 2,
          'filters': [
            // 同类对比模式下，直接从产品类别开始
            {
              'id': 'category_filter_comp',
              'name': 'category',
              'displayName': '选择类别',
              'level': 0,
              'isLeaf': false,
              'isDefault': false,
              'children': [
                {
                  'id': 'category_all_comp',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'category_filter_comp',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                {
                  'id': 'category_electronics',
                  'name': 'Electronics',
                  'displayName': '电子产品',
                  'parentId': 'category_filter_comp',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'category_appliances',
                  'name': 'Appliances',
                  'displayName': '家电',
                  'parentId': 'category_filter_comp',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
              ],
            },
            {
              'id': 'product_line_filter_comp',
              'name': 'productLine',
              'displayName': '选择产品线',
              'level': 0,
              'isLeaf': false,
              'isDefault': false,
              'children': [
                {
                  'id': 'product_line_all_comp',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'product_line_filter_comp',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                // 根据类别动态加载产品线
                // 例如：电子产品 -> 手机、平板、电脑、手表
              ],
            },
            {
              'id': 'product_filter_comp',
              'name': 'product',
              'displayName': '选择产品',
              'level': 0,
              'isLeaf': false,
              'isDefault': false,
              'children': [
                {
                  'id': 'product_all_comp',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'product_filter_comp',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                // 根据类别+产品线动态加载具体产品
              ],
            },
          ],
        },
      ],
    };

    return FilterConfigDataModel.fromJson(jsonData);
  }

  /// 根据品牌获取产品类别
  static Future<List<Map<String, dynamic>>> getCategoriesByBrand(
    String brand,
  ) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    // 模拟不同品牌的产品类别
    switch (brand.toLowerCase()) {
      case 'apple':
        return [
          {
            'id': 'category_electronics',
            'name': 'Electronics',
            'displayName': '电子产品',
          },
          {
            'id': 'category_software',
            'name': 'Software',
            'displayName': '软件服务',
          },
        ];
      case 'samsung':
        return [
          {
            'id': 'category_electronics',
            'name': 'Electronics',
            'displayName': '电子产品',
          },
          {
            'id': 'category_appliances',
            'name': 'Appliances',
            'displayName': '家电',
          },
        ];
      case 'huawei':
        return [
          {
            'id': 'category_electronics',
            'name': 'Electronics',
            'displayName': '电子产品',
          },
          {'id': 'category_telecom', 'name': 'Telecom', 'displayName': '通信设备'},
        ];
      default:
        return [
          {
            'id': 'category_electronics',
            'name': 'Electronics',
            'displayName': '电子产品',
          },
        ];
    }
  }

  /// 根据品牌和类别获取产品线
  static Future<List<Map<String, dynamic>>> getProductLinesByBrandAndCategory(
    String brand,
    String category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    // 模拟不同品牌+类别的产品线
    if (brand.toLowerCase() == 'apple' &&
        category.toLowerCase() == 'electronics') {
      return [
        {
          'id': 'product_line_iphone',
          'name': 'iPhone',
          'displayName': 'iPhone',
        },
        {'id': 'product_line_ipad', 'name': 'iPad', 'displayName': 'iPad'},
        {'id': 'product_line_mac', 'name': 'Mac', 'displayName': 'Mac'},
        {
          'id': 'product_line_watch',
          'name': 'Apple Watch',
          'displayName': 'Apple Watch',
        },
      ];
    } else if (brand.toLowerCase() == 'samsung' &&
        category.toLowerCase() == 'electronics') {
      return [
        {
          'id': 'product_line_galaxy_phone',
          'name': 'Galaxy Phone',
          'displayName': 'Galaxy手机',
        },
        {
          'id': 'product_line_galaxy_tablet',
          'name': 'Galaxy Tablet',
          'displayName': 'Galaxy平板',
        },
        {
          'id': 'product_line_galaxy_watch',
          'name': 'Galaxy Watch',
          'displayName': 'Galaxy手表',
        },
      ];
    }

    return [
      {'id': 'product_line_default', 'name': 'Default', 'displayName': '默认产品线'},
    ];
  }

  /// 根据品牌、类别、产品线获取具体产品
  static Future<List<Map<String, dynamic>>> getProductsByBrandCategoryAndLine(
    String brand,
    String category,
    String productLine,
  ) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    // 模拟具体产品数据
    if (brand.toLowerCase() == 'apple' &&
        category.toLowerCase() == 'electronics' &&
        productLine.toLowerCase() == 'iphone') {
      return [
        {
          'id': 'product_iphone15',
          'name': 'iPhone 15',
          'displayName': 'iPhone 15',
        },
        {
          'id': 'product_iphone15pro',
          'name': 'iPhone 15 Pro',
          'displayName': 'iPhone 15 Pro',
        },
        {
          'id': 'product_iphone14',
          'name': 'iPhone 14',
          'displayName': 'iPhone 14',
        },
        {
          'id': 'product_iphone13',
          'name': 'iPhone 13',
          'displayName': 'iPhone 13',
        },
      ];
    }

    return [
      {
        'id': 'product_default',
        'name': 'Default Product',
        'displayName': '默认产品',
      },
    ];
  }

  /// 根据ID获取筛选器配置
  static Future<FilterConfigDataModel?> getFilterConfigById(String id) async {
    // 目前只支持产品选择筛选器配置
    if (id == 'product_selection_config') {
      return await getProductSelectionFilterConfig();
    }
    return null;
  }

  /// 保存筛选器选择状态到后端
  static Future<bool> saveFilterSelections(
    List<FilterSelectionModel> selections,
  ) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    // 模拟保存到后端
    print(
      '保存筛选器选择状态: ${selections.map((s) => '${s.filterId}: ${s.selectedValue}').join(', ')}',
    );

    // 模拟成功/失败
    return true;
  }

  /// 从后端获取筛选器选择状态
  static Future<List<FilterSelectionModel>> getFilterSelections(
    String userId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    // 模拟从后端获取数据
    return [
      FilterSelectionModel(
        filterId: 'brand_filter',
        selectedId: 'brand_apple',
        selectedValue: 'Apple',
        selectedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FilterSelectionModel(
        filterId: 'category_filter',
        selectedId: 'category_electronics',
        selectedValue: 'Electronics',
        selectedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
