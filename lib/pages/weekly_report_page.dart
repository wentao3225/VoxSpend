import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../models/weekly_report.dart';
import '../theme/app_theme.dart';

/// 周报展示页（弹窗形式）
class WeeklyReportPage extends StatelessWidget {
  final WeeklyReport report;
  final VoidCallback? onClose;

  const WeeklyReportPage({
    super.key,
    required this.report,
    this.onClose,
  });

  String get _title {
    final s = report.weekStartDate;
    final e = report.weekEndDate;
    String fmt(DateTime d) =>
        '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    return '${fmt(s)} - ${fmt(e)}';
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = report.categoryBreakdown;
    final sections = <PieChartSectionData>[];

    breakdown.forEach((category, amount) {
      final percentage =
          report.totalExpense > 0 ? amount / report.totalExpense : 0.0;
      sections.add(PieChartSectionData(
        color: AppColors.categoryColor(category),
        value: amount,
        title: '${(percentage * 100).toStringAsFixed(0)}%',
        radius: 62,
        titleStyle: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ));
    });

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).size.height * 0.08,
        bottom: 24,
      ),
      color: CupertinoColors.black.withValues(alpha: 0.4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题
            Row(
              children: [
                const Icon(
                  CupertinoIcons.chart_pie,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: const Text(
                    '消费周报',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // AI 总结卡片
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                report.aiSummary,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 饼图
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 36,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 图例
            if (breakdown.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: breakdown.entries
                      .map((e) => _buildLegendRow(e.key, e.value))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
            // 总支出
            Text(
              '上周总支出  ¥${report.totalExpense.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.expense,
              ),
            ),
            const SizedBox(height: 16),
            // 关闭按钮
            CupertinoButton(
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              child: const Text(
                '我知道了',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(String category, double amount) {
    final color = AppColors.categoryColor(category);
    final percent = report.totalExpense > 0
        ? (amount / report.totalExpense * 100).toStringAsFixed(1)
        : '0.0';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Text(
            '¥${amount.toStringAsFixed(2)}（$percent%）',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
