import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_config.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'weekly_report_list_page.dart';

/// 设置页（我的 Tab）
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(settingsProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我的'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // AI 配置分组
            _buildSectionHeader('AI 服务配置'),
            _buildCard(
              children: [
                // Provider 选择
                _buildArrowTile(
                  icon: CupertinoIcons.sparkles,
                  label: 'AI 平台',
                  value: AIProviders.displayName(config.provider),
                  onTap: _showProviderPicker,
                ),
                // API Key
                _buildArrowTile(
                  icon: CupertinoIcons.lock,
                  label: 'API Key',
                  value: config.apiKey.isEmpty
                      ? '未设置'
                      : '已设置（${_maskKey(config.apiKey)}）',
                  onTap: () => _showInputTile(
                    title: 'API Key',
                    initial: config.apiKey,
                    obscure: true,
                    onSave: (v) => _saveConfig(
                      config.copyWith(apiKey: v),
                    ),
                  ),
                ),
                // 模型名称
                _buildArrowTile(
                  icon: CupertinoIcons.cube_box,
                  label: '模型名称',
                  value: config.modelName.isEmpty ? '未设置' : config.modelName,
                  onTap: () => _showInputTile(
                    title: '模型名称',
                    initial: config.modelName,
                    onSave: (v) => _saveConfig(
                      config.copyWith(modelName: v),
                    ),
                  ),
                ),
                // 自定义 API 地址（仅 custom 模式显示）
                if (config.provider == AIProviders.custom)
                  _buildArrowTile(
                    icon: CupertinoIcons.link,
                    label: 'API 地址',
                    value: config.apiUrl?.isEmpty == false
                        ? config.apiUrl!
                        : '未设置',
                    onTap: () => _showInputTile(
                      title: 'API 地址',
                      initial: config.apiUrl ?? '',
                      placeholder: 'https://api.example.com/v1/chat/completions',
                      onSave: (v) => _saveConfig(
                        config.copyWith(apiUrl: v),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // 周报入口
            _buildSectionHeader('消费周报'),
            _buildCard(
              children: [
                _buildArrowTile(
                  icon: CupertinoIcons.chart_pie,
                  label: '历史周报',
                  value: '',
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                        builder: (_) => const WeeklyReportListPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 关于
            _buildSectionHeader('关于'),
            _buildCard(
              children: [
                _buildPlainTile(
                  icon: CupertinoIcons.info,
                  label: '应用名称',
                  value: 'VoxSpend 记账',
                ),
                _buildPlainTile(
                  icon: CupertinoIcons.number,
                  label: '版本',
                  value: '1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 隐私说明
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '所有账单数据仅存储在本机，不上传任何服务器。\nAI 解析与周报生成会将脱敏文本发送至你配置的 AI 服务。',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _maskKey(String key) {
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
  }

  Future<void> _saveConfig(AIConfig config) async {
    await ref.read(settingsProvider.notifier).save(config);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPlainTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.separator, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 15,
              color: Color(0xFFC7C7CC),
            ),
          ],
        ),
      ),
    );
  }

  void _showProviderPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: CupertinoColors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AIProviders.all
                .map((p) => GestureDetector(
                      onTap: () {
                        ref.read(settingsProvider.notifier).changeProvider(p);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: AppColors.separator, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              AIProviders.displayName(p),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            if (ref.read(settingsProvider).provider == p)
                              const Icon(
                                CupertinoIcons.check_mark,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showInputTile({
    required String title,
    required String initial,
    bool obscure = false,
    String? placeholder,
    required ValueChanged<String> onSave,
  }) {
    final controller = TextEditingController(text: initial);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CupertinoTextField(
            controller: controller,
            obscureText: obscure,
            placeholder: placeholder,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
