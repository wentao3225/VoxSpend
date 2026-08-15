import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../models/transaction.dart' as model;
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';

/// 账单详情/编辑页
class TransactionDetailPage extends ConsumerStatefulWidget {
  final Transaction transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  ConsumerState<TransactionDetailPage> createState() =>
      _TransactionDetailPageState();
}

class _TransactionDetailPageState
    extends ConsumerState<TransactionDetailPage> {
  late Transaction _current;
  late TextEditingController _descController;
  late TextEditingController _amountController;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _current = widget.transaction;
    _descController = TextEditingController(text: _current.description);
    _amountController = TextEditingController(
      text: _current.amount == _current.amount.roundToDouble()
          ? _current.amount.toInt().toString()
          : _current.amount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _editing = !_editing);
    if (!_editing) {
      // 退出编辑时还原为已保存数据
      _descController.text = _current.description;
      _amountController.text = _current.amount.toStringAsFixed(2);
    }
  }

  Future<void> _save() async {
    final desc = _descController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (desc.isEmpty) {
      _showToast('请填写消费内容');
      return;
    }
    if (amount == null || amount <= 0) {
      _showToast('金额无效');
      return;
    }

    setState(() => _saving = true);
    final updated = _current.copyWith(
      description: desc,
      amount: amount,
      category: _pendingCategory ?? _current.category,
      date: _pendingDate ?? _current.date,
    );
    await ref.read(transactionProvider.notifier).update(updated);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _current = updated;
      _editing = false;
      _pendingCategory = null;
      _pendingDate = null;
    });
  }

  String? _pendingCategory;
  DateTime? _pendingDate;

  Future<void> _delete() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除账单'),
        content: const Text('确定要删除这条账单吗？删除后无法恢复。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(transactionProvider.notifier).delete(_current.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showToast(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
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

  Future<void> _pickDate() async {
    DateTime temp = _pendingDate ?? _current.date;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: SizedBox(
          height: 160,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: temp,
            maximumDate: DateTime.now(),
            onDateTimeChanged: (d) => temp = d,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        _pendingDate = DateTime(temp.year, temp.month, temp.day);
      });
    }
  }

  void _pickCategory() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: CupertinoColors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 8,
              runSpacing: 10,
              children: model.Categories.all
                  .map((c) => _buildCategoryOption(c))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String c) {
    final selected =
        (_pendingCategory ?? _current.category) == c;
    final color = AppColors.categoryColor(c);
    return GestureDetector(
      onTap: () {
        setState(() => _pendingCategory = c);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          c,
          style: TextStyle(
            color: selected ? CupertinoColors.white : color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayCategory = _pendingCategory ?? _current.category;
    final displayDate = _pendingDate ?? _current.date;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_editing ? '编辑账单' : '账单详情'),
        trailing: _editing
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CupertinoActivityIndicator()
                    : const Text('完成'),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _toggleEdit,
                child: const Text('编辑'),
              ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 金额展示
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '¥${_current.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppColors.expense,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.categoryColor(displayCategory)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        displayCategory,
                        style: TextStyle(
                          color: AppColors.categoryColor(displayCategory),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 字段表单
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildField(
                        icon: CupertinoIcons.doc_text,
                        label: '描述',
                        child: _editing
                            ? CupertinoTextField(
                                controller: _descController,
                                decoration: null,
                                style: const TextStyle(fontSize: 15),
                              )
                            : Text(
                                _current.description,
                                style: const TextStyle(fontSize: 15),
                              ),
                      ),
                      _buildField(
                        icon: CupertinoIcons.money_dollar_circle,
                        label: '金额',
                        child: _editing
                            ? CupertinoTextField(
                                controller: _amountController,
                                decoration: null,
                                keyboardType: const TextInputType
                                    .numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                style: const TextStyle(fontSize: 15),
                              )
                            : Text(
                                _current.amount.toStringAsFixed(2),
                                style: const TextStyle(fontSize: 15),
                              ),
                      ),
                      _buildField(
                        icon: CupertinoIcons.tag,
                        label: '类别',
                        child: _editing
                            ? GestureDetector(
                                onTap: _pickCategory,
                                child: Row(
                                  children: [
                                    Text(displayCategory),
                                    const Spacer(),
                                    const Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 16,
                                      color: Color(0xFFC7C7CC),
                                    ),
                                  ],
                                ),
                              )
                            : Text(displayCategory),
                      ),
                      _buildField(
                        icon: CupertinoIcons.calendar,
                        label: '日期',
                        child: _editing
                            ? GestureDetector(
                                onTap: _pickDate,
                                child: Row(
                                  children: [
                                    Text(_formatDate(displayDate)),
                                    const Spacer(),
                                    const Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 16,
                                      color: Color(0xFFC7C7CC),
                                    ),
                                  ],
                                ),
                              )
                            : Text(_formatDate(displayDate)),
                      ),
                    ],
                  ),
                ),
              ),
              // 删除按钮
              if (!_editing)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _delete,
                      color: AppColors.expense.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      child: const Text(
                        '删除账单',
                        style: TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
