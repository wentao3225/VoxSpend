import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../models/weekly_report.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weekly_report_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_card.dart';
import 'add_page.dart';
import 'search_page.dart';
import 'transaction_detail_page.dart';
import 'weekly_report_page.dart';

/// 首页：今日账单视图
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 周一自动检测周报
    Future.microtask(() => _checkWeeklyReport());
  }

  Future<void> _checkWeeklyReport() async {
    final config = ref.read(settingsProvider);
    if (!config.isReady) return; // AI 未配置则跳过

    final notifier = ref.read(weeklyReportProvider.notifier);
    final report = await notifier.checkAndGenerateWeeklyReport(config);
    if (report != null && mounted) {
      _showWeeklyReport(report);
    }
  }

  void _showWeeklyReport(WeeklyReport report) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => WeeklyReportPage(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final todayTotal = transactions.fold<double>(0, (s, t) => s + t.amount);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('今日账单'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => const SearchPage()),
          ),
          child: const Icon(CupertinoIcons.search),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 今日总支出卡片
                _buildTotalCard(todayTotal),
                // 账单列表
                Expanded(
                  child: transactions.isEmpty
                      ? const EmptyState(
                          icon: '🧾',
                          title: '今天还没有账单',
                          subtitle: '点击下方按钮开始记一笔吧',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 90),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final t = transactions[index];
                            return TransactionCard(
                              transaction: t,
                              onTap: () => _goDetail(t),
                            );
                          },
                        ),
                ),
              ],
            ),
            // 悬浮记一笔按钮
            Positioned(
              right: 20,
              bottom: 24,
              child: _buildAddButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日支出',
            style: TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '¥${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const AddPage()),
      ),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.plus, color: CupertinoColors.white, size: 22),
            SizedBox(width: 6),
            Text(
              '记一笔',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goDetail(Transaction t) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => TransactionDetailPage(transaction: t)),
    );
    ref.read(transactionProvider.notifier).loadToday();
  }
}
