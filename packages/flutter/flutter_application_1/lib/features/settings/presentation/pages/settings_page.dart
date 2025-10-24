import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state_manager.dart';
import '../../../../l10n/app_localizations.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
                  title: Text(l10n.darkMode),
                  subtitle: Text(l10n.darkModeSubtitle),
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
                  title: Text(l10n.language),
                  subtitle: Text('${l10n.currentLanguage}: ${appStateManager.currentLanguage}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 显示语言选择对话框
                    _showLanguageDialog(context, appStateManager, l10n);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 主题颜色
              Card(
                child: ListTile(
                  leading: const Icon(Icons.palette),
                  title: Text(l10n.themeColor),
                  subtitle: Text(l10n.themeColorSubtitle),
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
                    _showColorDialog(context, appStateManager, l10n);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 关于
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(l10n.about),
                  subtitle: Text('${l10n.appVersion} 1.0.0'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showAboutDialog(context, l10n);
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
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.chinese),
              leading: const Text('🇨🇳'),
              onTap: () {
                appStateManager.changeLanguage('zh-CN');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.english),
              leading: const Text('🇺🇸'),
              onTap: () {
                appStateManager.changeLanguage('en-US');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.japanese),
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
  void _showColorDialog(
    BuildContext context,
    AppStateManager appStateManager,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectThemeColor),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildColorOption(context, Colors.blue, l10n.blue, appStateManager),
            _buildColorOption(context, Colors.green, l10n.green, appStateManager),
            _buildColorOption(context, Colors.purple, l10n.purple, appStateManager),
            _buildColorOption(context, Colors.orange, l10n.orange, appStateManager),
            _buildColorOption(context, Colors.red, l10n.red, appStateManager),
            _buildColorOption(context, Colors.teal, l10n.teal, appStateManager),
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
  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: l10n.aboutApp,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.compare, size: 48),
      children: [
        Text(l10n.aboutDescription),
        const SizedBox(height: 16),
        Text(l10n.features),
        Text(l10n.featureMultiDimension),
        Text(l10n.featureSmartAnalysis),
        Text(l10n.featureVisualization),
        Text(l10n.featurePersonalization),
      ],
    );
  }
}
