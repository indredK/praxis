import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state_manager.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.8),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 8,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AppStateManager>(
        builder: (context, appStateManager, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 外观设置
              Card(
                child: ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('深色模式'),
                  subtitle: const Text('切换到深色主题'),
                  trailing: Switch(
                    value: appStateManager.isDarkMode,
                    onChanged: (value) => appStateManager.toggleDarkMode(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 语言设置
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('语言'),
                  subtitle: Text('当前语言: ${appStateManager.currentLanguage}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 显示语言选择对话框
                    _showLanguageDialog(context, appStateManager);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 主题颜色
              Card(
                child: ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('主题颜色'),
                  subtitle: const Text('选择应用主题色'),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: appStateManager.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    // 显示颜色选择对话框
                    _showColorDialog(context, appStateManager);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 关于
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('关于'),
                  subtitle: const Text('应用版本 1.0.0'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(
    BuildContext context,
    AppStateManager appStateManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('中文'),
              leading: const Text('🇨🇳'),
              onTap: () {
                appStateManager.changeLanguage('zh-CN');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸'),
              onTap: () {
                appStateManager.changeLanguage('en-US');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('日本語'),
              leading: const Text('🇯🇵'),
              onTap: () {
                appStateManager.changeLanguage('ja-JP');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示颜色选择对话框
  void _showColorDialog(BuildContext context, AppStateManager appStateManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题颜色'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildColorOption(context, Colors.blue, '蓝色', appStateManager),
            _buildColorOption(context, Colors.green, '绿色', appStateManager),
            _buildColorOption(context, Colors.purple, '紫色', appStateManager),
            _buildColorOption(context, Colors.orange, '橙色', appStateManager),
            _buildColorOption(context, Colors.red, '红色', appStateManager),
            _buildColorOption(context, Colors.teal, '青色', appStateManager),
          ],
        ),
      ),
    );
  }

  /// 构建颜色选项
  Widget _buildColorOption(
    BuildContext context,
    Color color,
    String name,
    AppStateManager appStateManager,
  ) {
    return GestureDetector(
      onTap: () {
        appStateManager.setPrimaryColor(color);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '产品对比分析',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.compare, size: 48),
      children: const [
        Text('一款强大的产品对比分析工具，帮助您做出明智的购买决策。'),
        SizedBox(height: 16),
        Text('功能特点：'),
        Text('• 多维度产品对比'),
        Text('• 智能数据分析'),
        Text('• 可视化图表展示'),
        Text('• 个性化设置'),
      ],
    );
  }
}
