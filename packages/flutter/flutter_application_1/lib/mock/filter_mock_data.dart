import '../models/advanced_filter_models.dart';

/// 筛选器模拟数据
class FilterMockData {
  /// 获取筛选器配置数据
  static FilterTreeConfig getFilterConfig() {
    return FilterTreeConfig(
      root: FilterNode(
        id: 'root',
        title: '产品筛选',
        children: [
          // 品牌筛选器
          FilterNode(
            id: 'brand_filter',
            title: '品牌筛选',
            type: FilterType.multiSelect,
            enabled: true,
            children: [
              FilterNode(
                id: 'apple',
                title: 'Apple',
                value: 'Apple',
                icon: '🍎',
              ),
              FilterNode(
                id: 'samsung',
                title: 'Samsung',
                value: 'Samsung',
                icon: '📱',
              ),
              FilterNode(id: 'dell', title: 'Dell', value: 'Dell', icon: '💻'),
              FilterNode(id: 'hp', title: 'HP', value: 'HP', icon: '🖥️'),
              FilterNode(
                id: 'lenovo',
                title: 'Lenovo',
                value: 'Lenovo',
                icon: '💻',
              ),
              FilterNode(id: 'asus', title: 'ASUS', value: 'ASUS', icon: '🎮'),
              FilterNode(id: 'msi', title: 'MSI', value: 'MSI', icon: '🎮'),
              FilterNode(id: 'acer', title: 'Acer', value: 'Acer', icon: '💻'),
              FilterNode(
                id: 'huawei',
                title: 'Huawei',
                value: 'Huawei',
                icon: '📱',
              ),
              FilterNode(
                id: 'xiaomi',
                title: 'Xiaomi',
                value: 'Xiaomi',
                icon: '📱',
              ),
              FilterNode(id: 'oppo', title: 'OPPO', value: 'OPPO', icon: '📱'),
              FilterNode(id: 'vivo', title: 'vivo', value: 'vivo', icon: '📱'),
              FilterNode(
                id: 'oneplus',
                title: 'OnePlus',
                value: 'OnePlus',
                icon: '📱',
              ),
              FilterNode(
                id: 'google',
                title: 'Google',
                value: 'Google',
                icon: '🔍',
              ),
              FilterNode(id: 'sony', title: 'Sony', value: 'Sony', icon: '🎵'),
              FilterNode(id: 'lg', title: 'LG', value: 'LG', icon: '📺'),
              FilterNode(
                id: 'nintendo',
                title: 'Nintendo',
                value: 'Nintendo',
                icon: '🎮',
              ),
              FilterNode(
                id: 'microsoft',
                title: 'Microsoft',
                value: 'Microsoft',
                icon: '🪟',
              ),
              FilterNode(
                id: 'razer',
                title: 'Razer',
                value: 'Razer',
                icon: '🐍',
              ),
              FilterNode(
                id: 'corsair',
                title: 'Corsair',
                value: 'Corsair',
                icon: '⚡',
              ),
            ],
          ),
          // 类别筛选器
          FilterNode(
            id: 'category_filter',
            title: '类别筛选',
            type: FilterType.singleSelect,
            enabled: true,
            children: [
              FilterNode(id: 'phone', title: '手机', value: '手机', icon: '📱'),
              FilterNode(id: 'laptop', title: '笔记本', value: '笔记本', icon: '💻'),
              FilterNode(id: 'tablet', title: '平板', value: '平板', icon: '📱'),
              FilterNode(
                id: 'desktop',
                title: '台式机',
                value: '台式机',
                icon: '🖥️',
              ),
              FilterNode(
                id: 'gaming_laptop',
                title: '游戏本',
                value: '游戏本',
                icon: '🎮',
              ),
              FilterNode(
                id: 'ultrabook',
                title: '超极本',
                value: '超极本',
                icon: '💻',
              ),
              FilterNode(
                id: 'workstation',
                title: '工作站',
                value: '工作站',
                icon: '🖥️',
              ),
              FilterNode(
                id: 'all_in_one',
                title: '一体机',
                value: '一体机',
                icon: '🖥️',
              ),
              FilterNode(id: 'monitor', title: '显示器', value: '显示器', icon: '📺'),
              FilterNode(id: 'keyboard', title: '键盘', value: '键盘', icon: '⌨️'),
              FilterNode(id: 'mouse', title: '鼠标', value: '鼠标', icon: '🖱️'),
              FilterNode(id: 'headphone', title: '耳机', value: '耳机', icon: '🎧'),
              FilterNode(id: 'speaker', title: '音响', value: '音响', icon: '🔊'),
              FilterNode(id: 'camera', title: '相机', value: '相机', icon: '📷'),
              FilterNode(
                id: 'smartwatch',
                title: '智能手表',
                value: '智能手表',
                icon: '⌚',
              ),
              FilterNode(
                id: 'smartband',
                title: '智能手环',
                value: '智能手环',
                icon: '⌚',
              ),
              FilterNode(
                id: 'vr_headset',
                title: 'VR头显',
                value: 'VR头显',
                icon: '🥽',
              ),
              FilterNode(id: 'router', title: '路由器', value: '路由器', icon: '📶'),
              FilterNode(
                id: 'storage',
                title: '存储设备',
                value: '存储设备',
                icon: '💾',
              ),
              FilterNode(
                id: 'accessories',
                title: '配件',
                value: '配件',
                icon: '🔌',
              ),
            ],
          ),
          // 产品线筛选器
          FilterNode(
            id: 'product_line_filter',
            title: '产品线',
            type: FilterType.multiSelect,
            enabled: true,
            children: [
              FilterNode(id: 'flagship', title: '旗舰', value: '旗舰', icon: '⭐'),
              FilterNode(id: 'mid_range', title: '中端', value: '中端', icon: '🔸'),
              FilterNode(
                id: 'entry_level',
                title: '入门',
                value: '入门',
                icon: '🔹',
              ),
              FilterNode(id: 'premium', title: '高端', value: '高端', icon: '💎'),
              FilterNode(id: 'budget', title: '经济型', value: '经济型', icon: '💰'),
              FilterNode(
                id: 'professional',
                title: '专业级',
                value: '专业级',
                icon: '🔧',
              ),
              FilterNode(id: 'gaming', title: '游戏级', value: '游戏级', icon: '🎮'),
              FilterNode(
                id: 'business',
                title: '商务级',
                value: '商务级',
                icon: '💼',
              ),
              FilterNode(id: 'student', title: '学生级', value: '学生级', icon: '📚'),
              FilterNode(
                id: 'creative',
                title: '创作级',
                value: '创作级',
                icon: '🎨',
              ),
            ],
          ),
          // 价格区间筛选器
          FilterNode(
            id: 'price_range_filter',
            title: '价格区间',
            type: FilterType.multiSelect,
            enabled: true,
            children: [
              FilterNode(
                id: 'under_1000',
                title: '1000元以下',
                value: '1000元以下',
                icon: '💰',
              ),
              FilterNode(
                id: '1000_3000',
                title: '1000-3000元',
                value: '1000-3000元',
                icon: '💵',
              ),
              FilterNode(
                id: '3000_5000',
                title: '3000-5000元',
                value: '3000-5000元',
                icon: '💴',
              ),
              FilterNode(
                id: '5000_8000',
                title: '5000-8000元',
                value: '5000-8000元',
                icon: '💶',
              ),
              FilterNode(
                id: '8000_12000',
                title: '8000-12000元',
                value: '8000-12000元',
                icon: '💷',
              ),
              FilterNode(
                id: 'over_12000',
                title: '12000元以上',
                value: '12000元以上',
                icon: '💎',
              ),
            ],
          ),
          // 颜色筛选器
          FilterNode(
            id: 'color_filter',
            title: '颜色',
            type: FilterType.multiSelect,
            enabled: true,
            children: [
              FilterNode(id: 'black', title: '黑色', value: '黑色', icon: '⚫'),
              FilterNode(id: 'white', title: '白色', value: '白色', icon: '⚪'),
              FilterNode(id: 'silver', title: '银色', value: '银色', icon: '🔘'),
              FilterNode(id: 'gold', title: '金色', value: '金色', icon: '🟡'),
              FilterNode(id: 'blue', title: '蓝色', value: '蓝色', icon: '🔵'),
              FilterNode(id: 'red', title: '红色', value: '红色', icon: '🔴'),
              FilterNode(id: 'green', title: '绿色', value: '绿色', icon: '🟢'),
              FilterNode(id: 'purple', title: '紫色', value: '紫色', icon: '🟣'),
            ],
          ),
          // 尺寸筛选器
          FilterNode(
            id: 'size_filter',
            title: '尺寸',
            type: FilterType.multiSelect,
            enabled: true,
            children: [
              FilterNode(id: 'small', title: '小尺寸', value: '小尺寸', icon: '📱'),
              FilterNode(id: 'medium', title: '中尺寸', value: '中尺寸', icon: '💻'),
              FilterNode(id: 'large', title: '大尺寸', value: '大尺寸', icon: '🖥️'),
              FilterNode(
                id: 'extra_large',
                title: '超大尺寸',
                value: '超大尺寸',
                icon: '📺',
              ),
            ],
          ),
          // 特色功能筛选器
          FilterNode(
            id: 'feature_filter',
            title: '特色功能',
            type: FilterType.multiSelect,
            enabled: true,
            children: [
              FilterNode(
                id: 'waterproof',
                title: '防水',
                value: '防水',
                icon: '💧',
              ),
              FilterNode(id: 'wireless', title: '无线', value: '无线', icon: '📶'),
              FilterNode(
                id: 'fast_charging',
                title: '快充',
                value: '快充',
                icon: '⚡',
              ),
              FilterNode(
                id: 'high_resolution',
                title: '高分辨率',
                value: '高分辨率',
                icon: '📺',
              ),
              FilterNode(
                id: 'touch_screen',
                title: '触屏',
                value: '触屏',
                icon: '👆',
              ),
              FilterNode(id: 'backlit', title: '背光', value: '背光', icon: '💡'),
              FilterNode(
                id: 'mechanical',
                title: '机械',
                value: '机械',
                icon: '⚙️',
              ),
              FilterNode(id: 'rgb', title: 'RGB灯效', value: 'RGB灯效', icon: '🌈'),
            ],
          ),
        ],
      ),
      comparisonModes: {
        'same_brand': FilterModeConfig(
          title: '自家对比',
          enabledFilters: [
            'category_filter',
            'product_line_filter',
            'price_range_filter',
            'color_filter',
            'size_filter',
            'feature_filter',
          ],
        ),
        'same_category': FilterModeConfig(
          title: '同类对比',
          enabledFilters: [
            'brand_filter',
            'product_line_filter',
            'price_range_filter',
            'color_filter',
            'size_filter',
            'feature_filter',
          ],
        ),
        'price_comparison': FilterModeConfig(
          title: '价格对比',
          enabledFilters: [
            'brand_filter',
            'category_filter',
            'product_line_filter',
            'color_filter',
            'size_filter',
            'feature_filter',
          ],
        ),
        'feature_comparison': FilterModeConfig(
          title: '功能对比',
          enabledFilters: [
            'brand_filter',
            'category_filter',
            'product_line_filter',
            'price_range_filter',
            'color_filter',
            'size_filter',
          ],
        ),
      },
    );
  }

  /// 模拟网络延迟
  static Future<void> simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 模拟网络错误
  static Future<void> simulateNetworkError() async {
    await Future.delayed(const Duration(milliseconds: 300));
    throw Exception('网络连接失败');
  }
}
