import '../models/filter_data_model.dart';

/// 筛选器数据服务（模拟后端API）
class FilterDataService {
  // 私有构造函数，防止实例化
  FilterDataService._();

  /// 获取产品选择页面的筛选器配置
  static Future<FilterConfigDataModel> getProductSelectionFilterConfig() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟后端返回的JSON数据
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
            {
              'id': 'company_filter',
              'name': 'company',
              'displayName': '选择公司',
              'level': 0,
              'isLeaf': false,
              'isDefault': false,
              'children': [
                {
                  'id': 'company_all',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'company_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                {
                  'id': 'company_apple',
                  'name': 'Apple',
                  'displayName': '苹果',
                  'parentId': 'company_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'company_samsung',
                  'name': 'Samsung',
                  'displayName': '三星',
                  'parentId': 'company_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'company_huawei',
                  'name': 'Huawei',
                  'displayName': '华为',
                  'parentId': 'company_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
              ],
            },
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
                {
                  'id': 'category_phone',
                  'name': 'Phone',
                  'displayName': '手机',
                  'parentId': 'category_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'category_laptop',
                  'name': 'Laptop',
                  'displayName': '笔记本电脑',
                  'parentId': 'category_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'category_tablet',
                  'name': 'Tablet',
                  'displayName': '平板',
                  'parentId': 'category_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
              ],
            },
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
                {
                  'id': 'product_iphone15',
                  'name': 'iPhone 15',
                  'displayName': 'iPhone 15',
                  'parentId': 'product_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'product_macbookair',
                  'name': 'MacBook Air',
                  'displayName': 'MacBook Air',
                  'parentId': 'product_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
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
                {
                  'id': 'category_phone',
                  'name': 'Phone',
                  'displayName': '手机',
                  'parentId': 'category_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'category_laptop',
                  'name': 'Laptop',
                  'displayName': '笔记本电脑',
                  'parentId': 'category_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
              ],
            },
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
                {
                  'id': 'product_iphone15',
                  'name': 'iPhone 15',
                  'displayName': 'iPhone 15',
                  'parentId': 'product_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
                {
                  'id': 'product_galaxys24',
                  'name': 'Galaxy S24',
                  'displayName': 'Galaxy S24',
                  'parentId': 'product_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': false,
                  'children': [],
                },
              ],
            },
          ],
        },
      ],
    };

    return FilterConfigDataModel.fromJson(jsonData);
  }

  /// 获取通用筛选器配置
  static Future<FilterConfigDataModel> getGenericFilterConfig() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final jsonData = {
      'id': 'generic_filter_config',
      'name': 'generic',
      'displayName': '通用筛选器',
      'description': '通用筛选器配置',
      'isDefault': false,
      'config': {
        'width': 180,
        'fontSize': 10,
        'titleFontSize': 11,
        'borderRadius': 8,
      },
      'groups': [
        {
          'id': 'generic_group',
          'name': 'generic_filters',
          'displayName': '通用筛选器组',
          'description': '通用筛选器组',
          'isActive': true,
          'sortOrder': 1,
          'filters': [
            {
              'id': 'status_filter',
              'name': 'status',
              'displayName': '状态',
              'level': 0,
              'isLeaf': false,
              'children': [
                {
                  'id': 'status_all',
                  'name': '全部',
                  'displayName': '全部',
                  'parentId': 'status_filter',
                  'level': 1,
                  'isLeaf': true,
                  'isDefault': true,
                  'children': [],
                },
                {
                  'id': 'status_active',
                  'name': 'active',
                  'displayName': '活跃',
                  'parentId': 'status_filter',
                  'level': 1,
                  'isLeaf': true,
                  'children': [],
                },
                {
                  'id': 'status_inactive',
                  'name': 'inactive',
                  'displayName': '非活跃',
                  'parentId': 'status_filter',
                  'level': 1,
                  'isLeaf': true,
                  'children': [],
                },
              ],
            },
          ],
        },
      ],
    };

    return FilterConfigDataModel.fromJson(jsonData);
  }

  /// 获取所有可用的筛选器配置
  static Future<List<FilterConfigDataModel>> getAllFilterConfigs() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final productConfig = await getProductSelectionFilterConfig();
    final genericConfig = await getGenericFilterConfig();

    return [productConfig, genericConfig];
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
    await Future.delayed(const Duration(milliseconds: 200));

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
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟从后端获取数据
    return [
      FilterSelectionModel(
        filterId: 'company_filter',
        selectedId: 'company_apple',
        selectedValue: 'Apple',
        selectedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FilterSelectionModel(
        filterId: 'category_filter',
        selectedId: 'category_phone',
        selectedValue: 'Phone',
        selectedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
