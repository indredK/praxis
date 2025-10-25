import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import '../../domain/models/advanced_filter_models.dart';
import '../../data/services/advanced_filter_service.dart';

/// 高级筛选器组件 - 基于JSON配置
class AdvancedFilterWidget extends StatefulWidget {
  final String comparisonMode;
  final AdvancedFilterSelection initialSelection;
  final Function(AdvancedFilterSelection) onSelectionChanged;

  const AdvancedFilterWidget({
    super.key,
    required this.comparisonMode,
    required this.initialSelection,
    required this.onSelectionChanged,
  });

  @override
  State<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget> {
  late AdvancedFilterSelection _currentSelection;
  final AdvancedFilterService _filterService = AdvancedFilterService.instance;
  List<FilterNode> _enabledFilters = [];
  bool _isLoading = true;
  String? _errorMessage;
  // 记录每个筛选器的展开/收起状态，默认都展开
  final Map<String, bool> _expandedStates = {};
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  // 使用 flutter_sticky_header 后无需手动计算吸顶标题

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.initialSelection;
    _loadFilters();
  }

  @override
  void didUpdateWidget(AdvancedFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当对比模式改变时，重新加载筛选器配置
    if (oldWidget.comparisonMode != widget.comparisonMode) {
      debugPrint(
        '对比模式改变: ${oldWidget.comparisonMode} → ${widget.comparisonMode}',
      );
      _loadFilters();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _filterService.loadConfig();
      final filters = await _filterService.getEnabledFiltersAsync(
        widget.comparisonMode,
      );

      if (mounted) {
        setState(() {
          _enabledFilters = filters;
          // 初始化所有筛选器的展开状态为 true（展开）
          for (var filter in filters) {
            _expandedStates[filter.id] = true;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildFilterSkeleton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('加载失败: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadFilters, child: const Text('重试')),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // 裁剪圆角，保持视觉一致
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [
                Colors.transparent, // 顶部透明
                Colors.white, // 中间完全显示
                Colors.white, // 中间完全显示
                Colors.transparent, // 底部透明
              ],
              stops: const [0.0, 0.05, 0.95, 1.0], // 渐变位置
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn, // 关键：使用 dstIn 模式实现淡入淡出
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true, // 始终显示滚动条
            thickness: 6, // 滚动条厚度
            radius: const Radius.circular(3), // 滚动条圆角
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 使用 SliverStickyHeader 实现单标题吸顶
                ..._enabledFilters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filter = entry.value;
                  final isExpanded = _expandedStates[filter.id] ?? true;
                  const double headerHeight = 56.0;
                  return SliverStickyHeader(
                    overlapsContent: false,
                    sticky: true,
                    header: Container(
                      height: headerHeight,
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: index == 0 ? 0 : 0,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _expandedStates[filter.id] = !isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                filter.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      letterSpacing: 0.2,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 22,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    sliver: isExpanded
                        ? SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: filter.children.map((option) {
                                  final isSelected = _currentSelection
                                      .getFilterSelection(filter.id)
                                      .contains(option.value);
                                  return _buildFilterChip(
                                    context,
                                    option,
                                    isSelected,
                                    filter.type == FilterType.multiSelect,
                                    filter.id,
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : const SliverToBoxAdapter(child: SizedBox.shrink()),
                  );
                }),
                // 底部间距
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 采用 SliverStickyHeader 后无需额外的顶部单标题与普通标题构建函数

  // 内容渲染已集成到 SliverStickyHeader 的 sliver 中

  Widget _buildFilterChip(
    BuildContext context,
    FilterNode option,
    bool isSelected,
    bool isMultiSelect,
    String parentFilterId,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.icon != null) ...[
              Text(option.icon!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(
              option.title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (isMultiSelect) {
              _currentSelection = _currentSelection.toggleFilterSelection(
                parentFilterId,
                option.value!,
              );
            } else {
              // 单选模式：先清空其他选择，再设置当前选择
              _currentSelection = _currentSelection.setFilterSelection(
                parentFilterId,
                selected ? [option.value!] : [],
              );
            }
            widget.onSelectionChanged(_currentSelection);
          });
        },
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
        showCheckmark: false, // 不显示打钩
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1, // 统一边框宽度
        ),
        elevation: isSelected ? 1 : 0, // 减少阴影强度
        shadowColor: Theme.of(
          context,
        ).primaryColor.withValues(alpha: 0.2), // 减少阴影透明度
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }

  /// 筛选器骨架屏
  Widget _buildFilterSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题骨架
                _buildShimmer(
                  child: Container(
                    height: 16,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 选项骨架 - 使用LayoutBuilder自适应
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final itemWidth = (availableWidth - 32) / 3; // 3列，减去间距

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(6, (i) {
                        // 动态宽度，填充更多空间
                        final width = (itemWidth + (i % 3) * 10).clamp(
                          70.0,
                          itemWidth,
                        );
                        return _buildShimmer(
                          child: Container(
                            height: 32,
                            width: width,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 闪烁动画
  Widget _buildShimmer({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, _child) {
        return Opacity(opacity: value, child: _child);
      },
      onEnd: () {
        if (mounted && _isLoading) {
          setState(() {});
        }
      },
      child: child,
    );
  }
}
