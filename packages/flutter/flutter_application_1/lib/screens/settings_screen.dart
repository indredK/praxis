import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/settings_service.dart';
import '../services/theme_manager.dart';
import '../services/language_manager.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 设置状态
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoRefresh = false;
  String _defaultCurrency = 'USD';
  String _defaultLanguage = 'zh-CN';
  int _maxProducts = 5;
  bool _showPrices = true;
  bool _showSpecs = true;
  bool _showCharts = true;
  // String _themeColor = 'blue'; // 暂时注释掉，后续会使用

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // 监听语言变化
    LanguageManager().addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageManager().removeListener(_onLanguageChanged);
    super.dispose();
  }

  // 语言变化回调
  void _onLanguageChanged() {
    setState(() {
      _defaultLanguage = _getCurrentLanguageCode();
    });
  }

  // 获取本地化文本
  String _getLocalizedText(BuildContext context, String key) {
    try {
      final l10n = AppLocalizations.of(context);
      switch (key) {
        case 'appearanceSettings':
          return l10n.appearanceSettings;
        case 'darkMode':
          return l10n.darkMode;
        case 'darkModeSubtitle':
          return l10n.darkModeSubtitle;
        case 'themeColor':
          return l10n.themeColor;
        case 'themeColorSubtitle':
          return l10n.themeColorSubtitle;
        case 'displaySettings':
          return l10n.displaySettings;
        case 'showPrices':
          return l10n.showPrices;
        case 'showPricesSubtitle':
          return l10n.showPricesSubtitle;
        case 'showSpecs':
          return l10n.showSpecs;
        case 'showSpecsSubtitle':
          return l10n.showSpecsSubtitle;
        case 'showCharts':
          return l10n.showCharts;
        case 'showChartsSubtitle':
          return l10n.showChartsSubtitle;
        case 'comparisonSettings':
          return l10n.comparisonSettings;
        case 'maxProducts':
          return l10n.maxProducts;
        case 'maxProductsSubtitle':
          return l10n.maxProductsSubtitle(_maxProducts);
        case 'notificationSettings':
          return l10n.notificationSettings;
        case 'notifications':
          return l10n.notifications;
        case 'notificationsSubtitle':
          return l10n.notificationsSubtitle;
        case 'autoRefresh':
          return l10n.autoRefresh;
        case 'autoRefreshSubtitle':
          return l10n.autoRefreshSubtitle;
        case 'languageSettings':
          return l10n.languageSettings;
        case 'appLanguage':
          return l10n.appLanguage;
        case 'appLanguageSubtitle':
          return l10n.appLanguageSubtitle;
        case 'about':
          return l10n.about;
        case 'appVersion':
          return l10n.appVersion;
        case 'privacyPolicy':
          return l10n.privacyPolicy;
        case 'privacyPolicySubtitle':
          return l10n.privacyPolicySubtitle;
        case 'userFeedback':
          return l10n.userFeedback;
        case 'userFeedbackSubtitle':
          return l10n.userFeedbackSubtitle;
        case 'resetSettings':
          return l10n.resetSettings;
        case 'languageChangeTitle':
          return l10n.languageChangeTitle;
        case 'languageChangeMessage':
          return l10n.languageChangeMessage;
        case 'languageChanged':
          return l10n.languageChanged;
        case 'cancel':
          return l10n.cancel;
        case 'confirm':
          return l10n.confirm;
        case 'confirmReset':
          return l10n.confirmReset;
        case 'settingsReset':
          return l10n.settingsReset;
        case 'defaultCurrency':
          return l10n.defaultCurrency;
        case 'defaultCurrencySubtitle':
          return l10n.defaultCurrencySubtitle;
        default:
          return key;
      }
    } catch (e) {
      // 如果本地化失败，返回默认中文文本
      switch (key) {
        case 'appearanceSettings':
          return '外观设置';
        case 'darkMode':
          return '深色模式';
        case 'darkModeSubtitle':
          return '切换到深色主题';
        case 'themeColor':
          return '主题颜色';
        case 'themeColorSubtitle':
          return '选择应用主题色';
        case 'displaySettings':
          return '显示设置';
        case 'showPrices':
          return '显示价格';
        case 'showPricesSubtitle':
          return '在产品列表中显示价格信息';
        case 'showSpecs':
          return '显示规格';
        case 'showSpecsSubtitle':
          return '在对比表格中显示详细规格';
        case 'showCharts':
          return '显示图表';
        case 'showChartsSubtitle':
          return '在对比页面中显示图表分析';
        case 'comparisonSettings':
          return '对比设置';
        case 'maxProducts':
          return '最大产品数量';
        case 'maxProductsSubtitle':
          return '最多选择 $_maxProducts 个产品进行对比';
        case 'notificationSettings':
          return '通知设置';
        case 'notifications':
          return '推送通知';
        case 'notificationsSubtitle':
          return '接收产品更新和价格变动通知';
        case 'autoRefresh':
          return '自动刷新';
        case 'autoRefreshSubtitle':
          return '自动刷新产品数据和价格信息';
        case 'languageSettings':
          return '语言设置';
        case 'appLanguage':
          return '应用语言';
        case 'appLanguageSubtitle':
          return '选择应用显示语言';
        case 'about':
          return '关于';
        case 'appVersion':
          return '应用版本';
        case 'privacyPolicy':
          return '隐私政策';
        case 'privacyPolicySubtitle':
          return '查看隐私政策和使用条款';
        case 'userFeedback':
          return '用户反馈';
        case 'userFeedbackSubtitle':
          return '提交问题或建议';
        case 'resetSettings':
          return '重置所有设置';
        case 'languageChangeTitle':
          return '切换语言';
        case 'languageChangeMessage':
          return '确定要切换语言吗？界面将立即更新为新语言。';
        case 'languageChanged':
          return '语言已切换';
        case 'cancel':
          return '取消';
        case 'confirm':
          return '确定';
        case 'confirmReset':
          return '确定要重置所有设置吗？此操作不可撤销。';
        case 'settingsReset':
          return '设置已重置';
        case 'defaultCurrency':
          return '默认货币';
        case 'defaultCurrencySubtitle':
          return '价格显示货币单位';
        default:
          return key;
      }
    }
  }

  // 加载设置
  Future<void> _loadSettings() async {
    await SettingsService.init();
    setState(() {
      _darkMode = SettingsService.darkMode;
      _notifications = SettingsService.notifications;
      _autoRefresh = SettingsService.autoRefresh;
      _defaultCurrency = SettingsService.defaultCurrency;
      // 从LanguageManager获取当前语言，而不是从SettingsService
      _defaultLanguage = _getCurrentLanguageCode();
      _maxProducts = SettingsService.maxProducts;
      _showPrices = SettingsService.showPrices;
      _showSpecs = SettingsService.showSpecs;
      _showCharts = SettingsService.showCharts;
      // _themeColor = SettingsService.themeColor;
    });
  }

  // 获取当前语言代码
  String _getCurrentLanguageCode() {
    try {
      final currentLocale = LanguageManager().currentLocale;
      return '${currentLocale.languageCode}-${currentLocale.countryCode}';
    } catch (e) {
      return 'zh-CN'; // 默认中文
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 外观设置
                _buildSectionCard(
                  title: _getLocalizedText(context, 'appearanceSettings'),
                  icon: Icons.palette,
                  children: [
                    _buildSwitchTile(
                      title: _getLocalizedText(context, 'darkMode'),
                      subtitle: _getLocalizedText(context, 'darkModeSubtitle'),
                      value: _darkMode,
                      onChanged: (value) async {
                        setState(() {
                          _darkMode = value;
                        });
                        await SettingsService.setDarkMode(value);
                        // 通知主题管理器刷新主题
                        ThemeManager().refreshTheme();
                      },
                    ),
                    _buildDivider(),
                    _buildListTile(
                      title: '主题颜色',
                      subtitle: '选择应用主题色',
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onTap: () {
                        _showColorPicker();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 显示设置
                _buildSectionCard(
                  title: _getLocalizedText(context, 'displaySettings'),
                  icon: Icons.visibility,
                  children: [
                    _buildSwitchTile(
                      title: _getLocalizedText(context, 'showPrices'),
                      subtitle: _getLocalizedText(
                        context,
                        'showPricesSubtitle',
                      ),
                      value: _showPrices,
                      onChanged: (value) async {
                        setState(() {
                          _showPrices = value;
                        });
                        await SettingsService.setShowPrices(value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: _getLocalizedText(context, 'showSpecs'),
                      subtitle: _getLocalizedText(context, 'showSpecsSubtitle'),
                      value: _showSpecs,
                      onChanged: (value) async {
                        setState(() {
                          _showSpecs = value;
                        });
                        await SettingsService.setShowSpecs(value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: _getLocalizedText(context, 'showCharts'),
                      subtitle: _getLocalizedText(
                        context,
                        'showChartsSubtitle',
                      ),
                      value: _showCharts,
                      onChanged: (value) async {
                        setState(() {
                          _showCharts = value;
                        });
                        await SettingsService.setShowCharts(value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 对比设置
                _buildSectionCard(
                  title: _getLocalizedText(context, 'comparisonSettings'),
                  icon: Icons.compare,
                  children: [
                    _buildListTile(
                      title: _getLocalizedText(context, 'maxProducts'),
                      subtitle: _getLocalizedText(
                        context,
                        'maxProductsSubtitle',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _maxProducts > 2
                                ? () async {
                                    setState(() {
                                      _maxProducts--;
                                    });
                                    await SettingsService.setMaxProducts(
                                      _maxProducts,
                                    );
                                  }
                                : null,
                          ),
                          Text(
                            '$_maxProducts',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _maxProducts < 10
                                ? () async {
                                    setState(() {
                                      _maxProducts++;
                                    });
                                    await SettingsService.setMaxProducts(
                                      _maxProducts,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      title: '默认货币',
                      subtitle: '价格显示货币单位',
                      trailing: DropdownButton<String>(
                        value: _defaultCurrency,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'USD',
                            child: Text('USD (\$)'),
                          ),
                          const DropdownMenuItem(
                            value: 'EUR',
                            child: Text('EUR (€)'),
                          ),
                          const DropdownMenuItem(
                            value: 'CNY',
                            child: Text('CNY (¥)'),
                          ),
                          const DropdownMenuItem(
                            value: 'JPY',
                            child: Text('JPY (¥)'),
                          ),
                        ],
                        onChanged: (value) async {
                          setState(() {
                            _defaultCurrency = value!;
                          });
                          await SettingsService.setDefaultCurrency(value!);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 通知设置
                _buildSectionCard(
                  title: _getLocalizedText(context, 'notificationSettings'),
                  icon: Icons.notifications,
                  children: [
                    _buildSwitchTile(
                      title: _getLocalizedText(context, 'notifications'),
                      subtitle: _getLocalizedText(
                        context,
                        'notificationsSubtitle',
                      ),
                      value: _notifications,
                      onChanged: (value) async {
                        setState(() {
                          _notifications = value;
                        });
                        await SettingsService.setNotifications(value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: _getLocalizedText(context, 'autoRefresh'),
                      subtitle: _getLocalizedText(
                        context,
                        'autoRefreshSubtitle',
                      ),
                      value: _autoRefresh,
                      onChanged: (value) async {
                        setState(() {
                          _autoRefresh = value;
                        });
                        await SettingsService.setAutoRefresh(value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 语言设置
                _buildSectionCard(
                  title: _getLocalizedText(context, 'languageSettings'),
                  icon: Icons.language,
                  children: [
                    _buildListTile(
                      title: _getLocalizedText(context, 'appLanguage'),
                      subtitle: _getLocalizedText(
                        context,
                        'appLanguageSubtitle',
                      ),
                      trailing: DropdownButton<String>(
                        value: _defaultLanguage,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        items: LanguageManager()
                            .getAllLanguages()
                            .where(
                              (language) =>
                                  language.containsKey('code') &&
                                  language.containsKey('name'),
                            )
                            .map(
                              (language) => DropdownMenuItem(
                                value: language['code'],
                                child: Text(language['name']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          if (value != null && value != _defaultLanguage) {
                            await _showLanguageChangeDialog(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 关于
                _buildSectionCard(
                  title: _getLocalizedText(context, 'about'),
                  icon: Icons.info,
                  children: [
                    _buildListTile(
                      title: _getLocalizedText(context, 'appVersion'),
                      subtitle: AppConfig.appVersion,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showAboutDialog();
                      },
                    ),
                    _buildDivider(),
                    _buildListTile(
                      title: _getLocalizedText(context, 'privacyPolicy'),
                      subtitle: _getLocalizedText(
                        context,
                        'privacyPolicySubtitle',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showPrivacyPolicy();
                      },
                    ),
                    _buildDivider(),
                    _buildListTile(
                      title: _getLocalizedText(context, 'userFeedback'),
                      subtitle: _getLocalizedText(
                        context,
                        'userFeedbackSubtitle',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showFeedbackDialog();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 重置设置按钮
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _resetSettings,
                    icon: const Icon(Icons.refresh),
                    label: Text(_getLocalizedText(context, 'resetSettings')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.orange.shade700
                          : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // 构建设置卡片
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // 构建开关选项
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  // 构建列表选项
  Widget _buildListTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // 构建分割线
  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  // 显示颜色选择器
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题颜色'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildColorOption(Colors.blue, '蓝色'),
            _buildColorOption(Colors.green, '绿色'),
            _buildColorOption(Colors.purple, '紫色'),
            _buildColorOption(Colors.orange, '橙色'),
            _buildColorOption(Colors.red, '红色'),
            _buildColorOption(Colors.teal, '青色'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  // 构建颜色选项
  Widget _buildColorOption(Color color, String name) {
    return GestureDetector(
      onTap: () async {
        // 保存颜色设置
        final colorMap = {
          '蓝色': 'blue',
          '绿色': 'green',
          '紫色': 'purple',
          '橙色': 'orange',
          '红色': 'red',
          '青色': 'teal',
        };
        await SettingsService.setThemeColor(colorMap[name] ?? 'blue');
        // 通知主题管理器刷新主题
        ThemeManager().refreshTheme();
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已选择 $name 主题')));
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

  // 显示关于对话框
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationIcon: const Icon(Icons.compare, size: 48),
      children: [
        const Text('一款强大的产品对比分析工具，帮助您做出明智的购买决策。'),
        const SizedBox(height: 16),
        const Text('功能特点：'),
        const Text('• 多维度产品对比'),
        const Text('• 智能数据分析'),
        const Text('• 可视化图表展示'),
        const Text('• 个性化设置'),
      ],
    );
  }

  // 显示隐私政策
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '我们重视您的隐私权。本应用仅收集必要的产品数据用于对比分析，不会收集您的个人信息。所有数据均存储在本地设备上，不会上传到服务器。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 显示反馈对话框
  void _showFeedbackDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户反馈'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '请输入您的建议或问题...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('感谢您的反馈！')));
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  // 显示语言切换确认对话框
  Future<void> _showLanguageChangeDialog(String newLanguage) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedText(context, 'languageChangeTitle')),
        content: Text(_getLocalizedText(context, 'languageChangeMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_getLocalizedText(context, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_getLocalizedText(context, 'confirm')),
          ),
        ],
      ),
    );

    if (result == true) {
      await _changeLanguage(newLanguage);
    }
  }

  // 切换语言
  Future<void> _changeLanguage(String newLanguage) async {
    try {
      // 使用LanguageManager更新语言，这会触发界面重新构建
      await LanguageManager().updateLanguage(newLanguage);
      // 不需要手动setState，因为_onLanguageChanged会自动处理

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedText(context, 'languageChanged')),
          duration: const Duration(seconds: 2),
        ),
      );

      // 显示语言切换成功消息
      Future.delayed(const Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '语言已切换为 ${LanguageManager().getLanguageName(newLanguage)}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('语言切换失败: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 重置设置
  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedText(context, 'resetSettings')),
        content: Text(_getLocalizedText(context, 'confirmReset')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedText(context, 'cancel')),
          ),
          TextButton(
            onPressed: () async {
              await SettingsService.resetAllSettings();
              setState(() {
                _darkMode = false;
                _notifications = true;
                _autoRefresh = false;
                _defaultCurrency = 'USD';
                _defaultLanguage = 'zh-CN';
                _maxProducts = 5;
                _showPrices = true;
                _showSpecs = true;
                _showCharts = true;
                // _themeColor = 'blue';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getLocalizedText(context, 'settingsReset')),
                ),
              );
            },
            child: Text(_getLocalizedText(context, 'confirm')),
          ),
        ],
      ),
    );
  }
}
