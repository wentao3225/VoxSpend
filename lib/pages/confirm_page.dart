import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../models/transaction.dart' as model;
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chip.dart';

/// 确认页：AI 解析结果逐条确认/修改后保存
class ConfirmPage extends ConsumerStatefulWidget {
  final List<Transaction> transactions;

  const ConfirmPage({super.key, required this.transactions});

  @override
  ConsumerState<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends ConsumerState<ConfirmPage> {
  late List<Transaction> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = widget.transactions.map((t) => t.copyWith()).toList();
  }

  Future<void> _save() async {
    // 最终校验
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].description.trim().isEmpty) {
        _showError('第 ${i + 1} 条记录缺少消费内容');
        return;
      }
      if (_items[i].amount <= 0) {
        _showError('第 ${i + 1} 条记录金额无效');
        return;
      }
    }

    setState(() => _saving = true);
    await ref.read(transactionProvider.notifier).addAll(_items);
    if (!mounted) return;
    setState(() => _saving = false);

    // 返回首页（退栈两层：ConfirmPage + AddPage）
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('无法保存'),
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

  void _showCategoryPicker(int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: CupertinoColors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: model.Categories.all
                      .map((c) => CategoryChip(
                            category: c,
                            selected: _items[index].category == c,
                            onTap: (_) {
                              setState(() {
                                _items[index] =
                                    _items[index].copyWith(category: c);
                              });
                              Navigator.of(context).pop();
                            },
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('确认账单'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) => _buildItemCard(index),
              ),
            ),
            // 底部保存按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _saving ? null : _save,
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: _saving
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : Text(
                          '保存 ${_items.length} 条记录',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    final color = AppColors.categoryColor(item.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyle.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 类别选择
          GestureDetector(
            onTap: () => _showCategoryPicker(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.category,
                    style: TextStyle(color: color, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    size: 12,
                    color: Color(0xFFC7C7CC),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 描述输入
          CupertinoTextField(
            controller: TextEditingController(text: item.description)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: item.description.length),
              ),
            style: const TextStyle(fontSize: 15),
            placeholder: '消费内容',
            decoration: null,
            onChanged: (v) {
              // 重建 controller 会丢失光标，此处直接更新数据
              _items[index] = item.copyWith(description: v);
            },
          ),
          const SizedBox(height: 10),
          // 金额输入
          Row(
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CupertinoTextField(
                  controller: TextEditingController(text: _trimAmount(item.amount)),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.expense,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  placeholder: '金额',
                  decoration: null,
                  onChanged: (v) {
                    final amount = double.tryParse(v);
                    if (amount != null) {
                      _items[index] = item.copyWith(amount: amount);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _trimAmount(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
  }
}
