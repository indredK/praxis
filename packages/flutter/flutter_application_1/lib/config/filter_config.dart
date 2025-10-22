import 'package:flutter/material.dart';
import '../models/filter_tree.dart';

/// 筛选器配置管理类
class FilterConfig {
  // 私有构造函数，防止实例化
  FilterConfig._();

  /// 默认筛选器配置
  static const FilterTreeConfig defaultConfig = FilterTreeConfig(
    width: 200,
    fontSize: 11,
    titleFontSize: 12,
    backgroundColor: null, // 使用主题色
    selectedColor: null, // 使用主题色
    textColor: null, // 使用主题色
    titleColor: null, // 使用主题色
    padding: EdgeInsets.all(8),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  /// 紧凑型筛选器配置（用于空间较小的场景）
  static const FilterTreeConfig compactConfig = FilterTreeConfig(
    width: 160,
    fontSize: 10,
    titleFontSize: 11,
    backgroundColor: null,
    selectedColor: null,
    textColor: null,
    titleColor: null,
    padding: EdgeInsets.all(6),
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  /// 宽松型筛选器配置（用于空间较大的场景）
  static const FilterTreeConfig spaciousConfig = FilterTreeConfig(
    width: 240,
    fontSize: 12,
    titleFontSize: 13,
    backgroundColor: null,
    selectedColor: null,
    textColor: null,
    titleColor: null,
    padding: EdgeInsets.all(12),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  /// 深色主题筛选器配置
  static FilterTreeConfig get darkThemeConfig => FilterTreeConfig(
    width: 200,
    fontSize: 11,
    titleFontSize: 12,
    backgroundColor: Colors.grey.shade900,
    selectedColor: Colors.blue.withOpacity(0.7),
    textColor: Colors.white,
    titleColor: Colors.blue.withOpacity(0.6),
    padding: const EdgeInsets.all(8),
    borderRadius: const BorderRadius.all(Radius.circular(12)),
  );

  /// 浅色主题筛选器配置
  static FilterTreeConfig get lightThemeConfig => FilterTreeConfig(
    width: 200,
    fontSize: 11,
    titleFontSize: 12,
    backgroundColor: Colors.grey.shade50,
    selectedColor: Colors.blue.withOpacity(0.7),
    textColor: Colors.black87,
    titleColor: Colors.blue.withOpacity(0.6),
    padding: const EdgeInsets.all(8),
    borderRadius: const BorderRadius.all(Radius.circular(12)),
  );

  /// 根据屏幕尺寸自动选择配置
  static FilterTreeConfig getResponsiveConfig(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return compactConfig;
    } else if (screenWidth > 1200) {
      return spaciousConfig;
    } else {
      return defaultConfig;
    }
  }

  /// 根据主题自动选择配置
  static FilterTreeConfig getThemeConfig(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (brightness == Brightness.dark) {
      return darkThemeConfig;
    } else {
      return lightThemeConfig;
    }
  }

  /// 获取产品选择页面的筛选器配置
  static FilterTreeConfig getProductSelectionConfig(BuildContext context) {
    return FilterTreeConfig(
      width: 200,
      fontSize: 11,
      titleFontSize: 12,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.grey.shade50,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.7),
      textColor: Theme.of(context).textTheme.bodyLarge?.color,
      titleColor: Theme.of(context).primaryColor.withOpacity(0.6),
      padding: const EdgeInsets.all(8),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    );
  }

  /// 获取产品对比页面的筛选器配置
  static FilterTreeConfig getProductComparisonConfig(BuildContext context) {
    return FilterTreeConfig(
      width: 180,
      fontSize: 10,
      titleFontSize: 11,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.6),
      textColor: Theme.of(context).textTheme.bodyMedium?.color,
      titleColor: Theme.of(context).primaryColor.withOpacity(0.5),
      padding: const EdgeInsets.all(6),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }

  /// 自定义配置构建器
  static FilterTreeConfig buildCustomConfig({
    double? width,
    double? fontSize,
    double? titleFontSize,
    Color? backgroundColor,
    Color? selectedColor,
    Color? textColor,
    Color? titleColor,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    return FilterTreeConfig(
      width: width ?? defaultConfig.width,
      fontSize: fontSize ?? defaultConfig.fontSize,
      titleFontSize: titleFontSize ?? defaultConfig.titleFontSize,
      backgroundColor: backgroundColor ?? defaultConfig.backgroundColor,
      selectedColor: selectedColor ?? defaultConfig.selectedColor,
      textColor: textColor ?? defaultConfig.textColor,
      titleColor: titleColor ?? defaultConfig.titleColor,
      padding: padding ?? defaultConfig.padding,
      borderRadius: borderRadius ?? defaultConfig.borderRadius,
    );
  }
}

/// 筛选器预设配置枚举
enum FilterConfigPreset {
  defaultConfig,
  compactConfig,
  spaciousConfig,
  darkThemeConfig,
  lightThemeConfig,
  productSelectionConfig,
  productComparisonConfig,
}

/// 筛选器配置扩展方法
extension FilterConfigPresetExtension on FilterConfigPreset {
  FilterTreeConfig getConfig(BuildContext context) {
    switch (this) {
      case FilterConfigPreset.defaultConfig:
        return FilterConfig.defaultConfig;
      case FilterConfigPreset.compactConfig:
        return FilterConfig.compactConfig;
      case FilterConfigPreset.spaciousConfig:
        return FilterConfig.spaciousConfig;
      case FilterConfigPreset.darkThemeConfig:
        return FilterConfig.darkThemeConfig;
      case FilterConfigPreset.lightThemeConfig:
        return FilterConfig.lightThemeConfig;
      case FilterConfigPreset.productSelectionConfig:
        return FilterConfig.getProductSelectionConfig(context);
      case FilterConfigPreset.productComparisonConfig:
        return FilterConfig.getProductComparisonConfig(context);
    }
  }
}
