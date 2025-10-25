import 'package:flutter/material.dart';
import '../../domain/models/product.dart' as models;
import 'comparison_product_card.dart';
import 'comparison_table_config.dart';

/// 吸顶产品卡片组件
/// 当用户滚动页面时，在顶部显示紧凑版的产品卡片
class StickyProductCards extends StatelessWidget {
  final List<models.Product> products;
  final int baselineIndex;
  final bool isVisible;
  final double scrollOffset;
  final Function(int) onSetBaseline;

  const StickyProductCards({
    super.key,
    required this.products,
    required this.baselineIndex,
    required this.isVisible,
    required this.scrollOffset,
    required this.onSetBaseline,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    // 计算透明度，基于滚动偏移量
    final opacity = (scrollOffset - 200).clamp(0.0, 100.0) / 100.0;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor.withValues(
                alpha: 0.95 + opacity * 0.05,
              ),
              Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.85 + opacity * 0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildProductCards(context),
      ),
    );
  }

  /// 构建产品卡片列表
  Widget _buildProductCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final productCount = products.length;

        // 计算吸顶卡片的自适应宽度
        const minCardWidth = 100.0; // 吸顶卡片最小宽度
        const maxCardWidth = 150.0; // 吸顶卡片最大宽度
        const cardSpacing = 8.0; // 吸顶卡片间距
        final totalSpacing = (productCount - 1) * cardSpacing;
        final availableWidth = screenWidth - 32; // 减去padding

        // 计算自适应宽度
        final adaptiveCardWidth =
            (availableWidth - totalSpacing) / productCount;
        final cardWidth = adaptiveCardWidth.clamp(minCardWidth, maxCardWidth);

        // 判断是否需要滚动
        final needsScrolling = ProductCardConfig.needsScrolling(
          cardWidth,
          productCount,
          cardSpacing,
          screenWidth,
        );

        if (needsScrolling) {
          // 需要滚动：使用水平滚动布局
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _buildCardsList(cardWidth, cardSpacing)),
          );
        } else {
          // 不需要滚动：使用自适应Row布局
          return Row(
            children: products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              final isBaseline = index == baselineIndex;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
                  child: CompactProductCard(
                    product: product,
                    isBaseline: isBaseline,
                    cardWidth: double.infinity,
                    onSetBaseline: () => onSetBaseline(index),
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  /// 构建卡片列表（用于滚动模式）
  List<Widget> _buildCardsList(double cardWidth, double cardSpacing) {
    return products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final isBaseline = index == baselineIndex;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
        child: CompactProductCard(
          product: product,
          isBaseline: isBaseline,
          cardWidth: cardWidth,
          onSetBaseline: () => onSetBaseline(index),
        ),
      );
    }).toList();
  }
}

/// 产品概览卡片列表组件
/// 显示完整的产品概览卡片
class ProductOverviewCards extends StatelessWidget {
  final List<models.Product> products;
  final int baselineIndex;
  final Function(int) onSetBaseline;

  const ProductOverviewCards({
    super.key,
    required this.products,
    required this.baselineIndex,
    required this.onSetBaseline,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final productCount = products.length;

        const cardSpacing = 16.0; // 卡片间距
        final totalSpacing = (productCount - 1) * cardSpacing; // 总间距
        final availableWidth = screenWidth - 32; // 可用宽度（减去padding）

        // 计算自适应宽度
        final adaptiveCardWidth =
            (availableWidth - totalSpacing) / productCount;
        const minCardWidth = 150.0; // 最小卡片宽度
        const maxCardWidth = 300.0; // 最大卡片宽度
        final cardWidth = adaptiveCardWidth.clamp(minCardWidth, maxCardWidth);

        // 智能高度计算：根据压缩状态动态调整
        final cardHeight = ProductCardConfig.calculateCardHeight(
          cardWidth,
          maxCardWidth,
        );

        // 判断是否需要滚动
        final needsScrolling = ProductCardConfig.needsScrolling(
          cardWidth,
          productCount,
          cardSpacing,
          screenWidth,
        );

        if (needsScrolling) {
          // 需要滚动：使用水平滚动布局
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildCardsList(cardWidth, cardHeight, cardSpacing),
            ),
          );
        } else {
          // 不需要滚动：使用自适应Row布局
          return Row(
            children: products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              final isBaseline = index == baselineIndex;

              return Expanded(
                child: Container(
                  height: cardHeight,
                  margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
                  child: ComparisonProductCard(
                    product: product,
                    isBaseline: isBaseline,
                    cardHeight: cardHeight,
                    onSetBaseline: () => onSetBaseline(index),
                    allPrices: products.map((p) => p.price).toList(),
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  /// 构建卡片列表（用于滚动模式）
  List<Widget> _buildCardsList(
    double cardWidth,
    double cardHeight,
    double cardSpacing,
  ) {
    return products.asMap().entries.map((entry) {
      final index = entry.key;
      final product = entry.value;
      final isBaseline = index == baselineIndex;

      return Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
        child: ComparisonProductCard(
          product: product,
          isBaseline: isBaseline,
          cardHeight: cardHeight,
          onSetBaseline: () => onSetBaseline(index),
          allPrices: products.map((p) => p.price).toList(),
        ),
      );
    }).toList();
  }
}
