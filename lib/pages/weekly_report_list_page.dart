import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weekly_report.dart';
import '../providers/weekly_report_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'weekly_report_page.dart';

/// 历史周报列表页
class WeeklyReportListPage extends ConsumerWidget {
  const WeeklyReportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(weeklyReportHistoryProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('历史周报'),
      ),
      child: SafeArea(
        child: reportsAsync.when(
          data: (reports) {
            if (reports.isEmpty) {
              return const EmptyState(
                icon: '📊',
                title: '暂无周报',
                subtitle: '每周一自动生成上周消费周报',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportCard(
                  report: report,
                  onTap: () => showCupertinoModalPopup(
                    context: context,
                    builder: (_) => WeeklyReportPage(report: report),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => EmptyState(
            icon: '⚠️',
            title: '加载失败',
            subtitle: e.toString(),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final WeeklyReport report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  String _fmt(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppStyle.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.chart_pie,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_fmt(report.weekStartDate)} ~ ${_fmt(report.weekEndDate)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '总支出 ¥${report.totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Color(0xFFC7C7CC),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
