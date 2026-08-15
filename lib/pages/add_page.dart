import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../services/parse_exception.dart';
import 'confirm_page.dart';

/// 记账页：自然语言输入
class AddPage extends ConsumerStatefulWidget {
  const AddPage({super.key});

  @override
  ConsumerState<AddPage> createState() => _AddPageState();
}

class _AddPageState extends ConsumerState<AddPage> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _parsing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 触发 AI 解析
  Future<void> _parse() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      _showError('请输入记账描述');
      return;
    }

    final config = ref.read(settingsProvider);
    if (!config.isReady) {
      _showError('请先在「我的」页面配置 AI 服务');
      return;
    }

    setState(() => _parsing = true);
    try {
      final transactions = await AIService.parseTransactions(
        input,
        _selectedDate,
        config,
      );
      if (!mounted) return;
      setState(() => _parsing = false);
      // 成功 -> 确认页
      await Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (_) => ConfirmPage(transactions: transactions),
        ),
      );
    } on ParseException catch (e) {
      if (!mounted) return;
      setState(() => _parsing = false);
      _showError(e.reason);
    } catch (e) {
      if (!mounted) return;
      setState(() => _parsing = false);
      _showError('解析失败，请重试');
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('解析失败'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  /// 日期选择器（只允许选择今天及过去）
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => Container(
        height: 280,
        color: CupertinoColors.white,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _selectedDate,
          maximumDate: now,
          minimumYear: 2020,
          maximumYear: now.year,
          onDateTimeChanged: (d) => setState(() => _selectedDate = d),
        ),
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _dateText {
    final d = _selectedDate;
    final today = DateTime.now();
    final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
    final yesterday = today.subtract(const Duration(days: 1));
    final isYesterday = d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day;
    final base =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (isToday) return '今天 ($base)';
    if (isYesterday) return '昨天 ($base)';
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('记一笔'),
        trailing: _parsing
            ? const CupertinoActivityIndicator()
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 日期选择行
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        color: Color(0xFF007AFF),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '记账日期',
                        style: TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
                      ),
                      const Spacer(),
                      Text(
                        _dateText,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: Color(0xFFC7C7CC),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 大文本输入框
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoTextField(
                  controller: _controller,
                  placeholder: '用一句话描述你的消费，例如：\n买了个面包花了五块，买了包烟花了十元',
                  placeholderStyle: const TextStyle(
                    color: Color(0xFFB0B0B5),
                    fontSize: 15,
                  ),
                  maxLength: 500,
                  maxLines: 6,
                  minLines: 4,
                  style: const TextStyle(fontSize: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: null,
                ),
              ),
              const SizedBox(height: 12),
              // 提示
              const Text(
                '支持多条混合输入，AI 自动识别每笔消费',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // 解析按钮
              CupertinoButton(
                onPressed: _parsing ? null : _parse,
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(14),
                child: _parsing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(color: CupertinoColors.white),
                          SizedBox(width: 8),
                          Text('AI 解析中...',
                              style: TextStyle(color: CupertinoColors.white)),
                        ],
                      )
                    : const Text(
                        '解 析',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
