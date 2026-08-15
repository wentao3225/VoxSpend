import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../models/transaction.dart' as model;
import '../providers/search_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_card.dart';
import 'transaction_detail_page.dart';

/// 搜索页：关键词 + 多维度筛选
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('搜索账单'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: _controller,
                      placeholder: '搜索消费描述',
                      onChanged: (v) =>
                          ref.read(searchProvider.notifier).setKeyword(v),
                    ),
                  ),
                  if (state.hasActiveFilter)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('重置'),
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchProvider.notifier).reset();
                      },
                    ),
                ],
              ),
            ),
            // 类别筛选标签
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final c in model.Categories.all)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(c, state.selectedCategories.contains(c)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // 日期与金额筛选入口
            _buildFilterRow(state),
            Container(
              height: 0.5,
              color: AppColors.separator,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            // 结果列表
            Expanded(
              child: state.results.isEmpty
                  ? const EmptyState(
                      icon: '🔍',
                      title: '未找到相关账单',
                      subtitle: '试试其他关键词或筛选条件',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final t = state.results[index];
                        return TransactionCard(
                          transaction: t,
                          onTap: () => _goDetail(t),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 类别标签点击回调（独立 Widget 便于触发 provider 更新）
  Widget _buildCategoryChip(String category, bool selected) {
    return GestureDetector(
      onTap: () =>
          ref.read(searchProvider.notifier).toggleCategory(category),
      child: _ChipVisual(category: category, selected: selected),
    );
  }

  Future<void> _goDetail(Transaction t) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => TransactionDetailPage(transaction: t)),
    );
    // 编辑/删除后刷新搜索结果
    ref.read(searchProvider.notifier).reset();
  }

  Widget _buildFilterRow(SearchState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterButton(
            icon: CupertinoIcons.calendar,
            label: _dateRangeLabel(state),
            onTap: _pickDateRange,
          ),
          const SizedBox(width: 8),
          _filterButton(
            icon: CupertinoIcons.money_dollar_circle,
            label: _amountRangeLabel(state),
            onTap: _pickAmountRange,
          ),
        ],
      ),
    );
  }

  String _dateRangeLabel(SearchState state) {
    if (state.startDate == null && state.endDate == null) return '日期';
    String fmt(DateTime? d) =>
        d == null ? '' : '${d.month}/${d.day}';
    return '${fmt(state.startDate)}-${fmt(state.endDate)}';
  }

  String _amountRangeLabel(SearchState state) {
    if (state.minAmount == null && state.maxAmount == null) return '金额';
    return '${state.minAmount?.toInt() ?? '0'}-${state.maxAmount?.toInt() ?? '∞'}';
  }

  Widget _filterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.separator),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final notifier = ref.read(searchProvider.notifier);
    final state = ref.read(searchProvider);

    // 弹窗选择起止日期
    final start = await _showDatePicker(title: '开始日期', initial: state.startDate);
    if (start == null || !mounted) return;
    final end = await _showDatePicker(title: '结束日期', initial: state.endDate ?? start);
    if (end == null) return;
    notifier.setStartDate(start);
    notifier.setEndDate(end);
  }

  Future<DateTime?> _showDatePicker({
    required String title,
    DateTime? initial,
  }) async {
    DateTime temp = initial ?? DateTime.now();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: SizedBox(
          height: 160,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: temp,
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
    return confirmed == true ? temp : null;
  }

  Future<void> _pickAmountRange() async {
    final notifier = ref.read(searchProvider.notifier);
    final state = ref.read(searchProvider);
    final minCtrl = TextEditingController(
      text: state.minAmount?.toStringAsFixed(0) ?? '',
    );
    final maxCtrl = TextEditingController(
      text: state.maxAmount?.toStringAsFixed(0) ?? '',
    );

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('金额区间'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: minCtrl,
              placeholder: '最小金额',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: maxCtrl,
              placeholder: '最大金额',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
          ],
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
      notifier.setMinAmount(double.tryParse(minCtrl.text));
      notifier.setMaxAmount(double.tryParse(maxCtrl.text));
    }
    minCtrl.dispose();
    maxCtrl.dispose();
  }
}

/// 类别标签视觉组件
class _ChipVisual extends StatelessWidget {
  final String category;
  final bool selected;

  const _ChipVisual({required this.category, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: selected ? CupertinoColors.white : color,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

