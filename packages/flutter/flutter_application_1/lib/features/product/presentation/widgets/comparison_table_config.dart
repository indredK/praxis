/// 表格配置类
/// 负责计算和管理对比表格的布局配置
class ComparisonTableConfig {
  final double columnWidth;
  final double specColumnWidth;
  final double totalTableWidth;
  final bool needsScrolling;
  final bool shouldUseVirtualizedTable;
  final double minColumnWidth;
  final double maxColumnWidth;
  final double fontSize;
  final double headingFontSize;
  final double cellPadding;
  final double tableHeight;

  const ComparisonTableConfig({
    required this.columnWidth,
    required this.specColumnWidth,
    required this.totalTableWidth,
    required this.needsScrolling,
    required this.shouldUseVirtualizedTable,
    required this.minColumnWidth,
    required this.maxColumnWidth,
    required this.fontSize,
    required this.headingFontSize,
    required this.cellPadding,
    required this.tableHeight,
  });

  /// 计算表格配置
  ///
  /// [screenWidth] 屏幕宽度
  /// [screenHeight] 屏幕高度
  /// [productCount] 产品数量
  /// [rowCount] 行数（用于计算高度）
  static ComparisonTableConfig calculate(
    double screenWidth,
    double screenHeight,
    int productCount, {
    int rowCount = 10,
  }) {
    // 响应式断点
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1024;

    // 自适应字体大小和间距（先计算，后续需要使用）
    double fontSize;
    double headingFontSize;
    double cellPadding;

    if (isSmallScreen) {
      fontSize = 10.0;
      headingFontSize = 11.0;
      cellPadding = 4.0;
    } else if (isMediumScreen) {
      fontSize = 11.0;
      headingFontSize = 12.0;
      cellPadding = 6.0;
    } else {
      fontSize = 12.0;
      headingFontSize = 14.0;
      cellPadding = 8.0;
    }

    // 自适应列宽
    double specColumnWidth;
    double minProductColumnWidth;
    double maxProductColumnWidth;

    if (isSmallScreen) {
      specColumnWidth = 100.0;
      minProductColumnWidth = 80.0;
      maxProductColumnWidth = 120.0;
    } else if (isMediumScreen) {
      specColumnWidth = 120.0;
      minProductColumnWidth = 100.0;
      maxProductColumnWidth = 150.0;
    } else {
      specColumnWidth = 150.0;
      minProductColumnWidth = 120.0;
      maxProductColumnWidth = 200.0;
    }

    // 使用动态的 cellPadding 作为间距
    final double columnSpacing = cellPadding;
    const double tablePadding = 32.0;

    // 计算可用宽度（预留一些空间给 border 和舍入误差）
    final availableWidth = screenWidth - tablePadding - 4.0;
    // 间距：规格列后 1 个 + 产品列之间 (productCount - 1) 个 = productCount 个
    final totalSpacing = productCount * columnSpacing;

    // 先用最小宽度检查是否需要滚动
    final minTotalWidth =
        specColumnWidth + (productCount * minProductColumnWidth) + totalSpacing;

    final needsScrolling = minTotalWidth > availableWidth;

    // 计算最终列宽和总宽度
    double finalColumnWidth;
    double finalTotalWidth;

    if (needsScrolling) {
      // 需要滚动：使用最小宽度
      finalColumnWidth = minProductColumnWidth;
      finalTotalWidth = minTotalWidth;
    } else {
      // 不需要滚动：平均分配所有可用空间
      final remainingWidth = availableWidth - specColumnWidth - totalSpacing;
      finalColumnWidth = remainingWidth / productCount;

      // 确保不小于最小宽度，但可以超过最大宽度以填充空间
      finalColumnWidth = finalColumnWidth.clamp(
        minProductColumnWidth,
        double.infinity, // 允许超过最大宽度
      );

      finalTotalWidth = availableWidth;
    }

    // 判断是否需要虚拟化表格
    final shouldUseVirtualizedTable = productCount > 8;

    // 自适应表格高度
    const double headerHeight = 60.0;
    const double rowHeight = 70.0;
    const double minTableHeight = 300.0;
    const double maxTableHeight = 700.0;

    // 根据行数和屏幕高度计算表格高度
    double calculatedHeight = headerHeight + (rowCount * rowHeight);
    double availableHeight = screenHeight * 0.6; // 使用屏幕高度的60%

    double tableHeight = calculatedHeight.clamp(
      minTableHeight,
      availableHeight.clamp(minTableHeight, maxTableHeight),
    );

    return ComparisonTableConfig(
      columnWidth: finalColumnWidth,
      specColumnWidth: specColumnWidth,
      totalTableWidth: finalTotalWidth,
      needsScrolling: needsScrolling,
      shouldUseVirtualizedTable: shouldUseVirtualizedTable,
      minColumnWidth: minProductColumnWidth,
      maxColumnWidth: maxProductColumnWidth,
      fontSize: fontSize,
      headingFontSize: headingFontSize,
      cellPadding: cellPadding,
      tableHeight: tableHeight,
    );
  }

  @override
  String toString() {
    return 'ComparisonTableConfig('
        'columnWidth: $columnWidth, '
        'specColumnWidth: $specColumnWidth, '
        'totalTableWidth: $totalTableWidth, '
        'needsScrolling: $needsScrolling, '
        'shouldUseVirtualizedTable: $shouldUseVirtualizedTable, '
        'fontSize: $fontSize, '
        'tableHeight: $tableHeight)';
  }
}

/// 产品卡片配置常量
class ProductCardConfig {
  // 高度配置（优化后更紧凑）
  static const double maxCardHeight = 150.0; // 最高高度限制
  static const double minCardHeight = 130.0; // 最低高度限制

  // 基础高度配置
  static const double cardPadding = 32.0; // Card padding (16px * 2)
  static const double logoHeight = 80.0; // Logo区域高度
  static const double logoSpacing = 10.0; // Logo后间距

  // 内容区域高度配置
  static const double nameHeight = 50.0; // 产品名称区域高度
  static const double nameSpacing = 12.0; // 名称后间距
  static const double companyHeight = 40.0; // 公司标签区域高度
  static const double companySpacing = 12.0; // 标签后间距
  static const double priceHeight = 50.0; // 价格区域高度

  // 压缩阈值配置
  static const double nameThreshold = 0.2; // 产品名称显示阈值
  static const double companyThreshold = 0.1; // 公司标签显示阈值
  static const double priceThreshold = 0.15; // 价格显示阈值

  /// 计算卡片高度
  ///
  /// [cardWidth] 卡片宽度
  /// [maxCardWidth] 最大卡片宽度
  static double calculateCardHeight(double cardWidth, double maxCardWidth) {
    // 简化的压缩逻辑：直接根据卡片宽度决定显示内容和高度
    final compressionRatio = cardWidth / maxCardWidth;
    final cardHeight =
        (minCardHeight + (maxCardHeight - minCardHeight) * compressionRatio)
            .clamp(minCardHeight, maxCardHeight);
    return cardHeight;
  }

  /// 计算卡片宽度
  ///
  /// [screenWidth] 屏幕宽度
  /// [productCount] 产品数量
  /// [cardSpacing] 卡片间距
  static double calculateCardWidth(
    double screenWidth,
    int productCount,
    double cardSpacing,
  ) {
    const double minCardWidth = 150.0; // 最小卡片宽度
    const double maxCardWidth = 300.0; // 最大卡片宽度

    final totalSpacing = (productCount - 1) * cardSpacing; // 总间距
    final availableWidth = screenWidth - 32; // 可用宽度（减去padding）

    // 计算自适应宽度
    final adaptiveCardWidth = (availableWidth - totalSpacing) / productCount;
    final cardWidth = adaptiveCardWidth.clamp(minCardWidth, maxCardWidth);

    return cardWidth;
  }

  /// 判断是否需要滚动
  ///
  /// [cardWidth] 卡片宽度
  /// [productCount] 产品数量
  /// [cardSpacing] 卡片间距
  /// [screenWidth] 屏幕宽度
  static bool needsScrolling(
    double cardWidth,
    int productCount,
    double cardSpacing,
    double screenWidth,
  ) {
    final totalSpacing = (productCount - 1) * cardSpacing;
    final totalRequiredWidth = (cardWidth * productCount) + totalSpacing;
    final availableWidth = screenWidth - 32;

    return totalRequiredWidth > availableWidth;
  }
}
