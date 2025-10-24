import 'package:flutter/material.dart';
import '../models/advanced_filter_models.dart';
import '../services/advanced_filter_service.dart';

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

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.initialSelection;
    _loadFilters();
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
      return const Center(child: CircularProgressIndicator());
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

    return SizedBox(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true, // 始终显示滚动条
          thickness: 6, // 滚动条厚度
          radius: const Radius.circular(3), // 滚动条圆角
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 20,
              left: 20,
              right: 20, // 右侧留出空间给滚动条
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 动态生成筛选器
                ..._enabledFilters.map(
                  (filter) => _buildFilterSection(context, filter),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, FilterNode filter) {
    final isMultiSelect = filter.type == FilterType.multiSelect;
    final currentSelections = _currentSelection.getFilterSelection(filter.id);
    final isExpanded = _expandedStates[filter.id] ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 可点击的标题区域
        InkWell(
          onTap: () {
            setState(() {
              _expandedStates[filter.id] = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  filter.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                // 展开/收起图标
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 可展开的内容区域
        AnimatedCrossFade(
          firstChild: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filter.children.map((option) {
              final isSelected = currentSelections.contains(option.value);
              return _buildFilterChip(
                context,
                option,
                isSelected,
                isMultiSelect,
                filter.id,
              );
            }).toList(),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

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
}
