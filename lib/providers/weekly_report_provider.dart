import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_service.dart';
import '../models/ai_config.dart';
import '../models/weekly_report.dart';
import '../services/parse_exception.dart';
import '../services/weekly_report_service.dart';
import 'database_provider.dart';

/// 周报状态管理
class WeeklyReportNotifier extends StateNotifier<AsyncValue<WeeklyReport?>> {
  final DatabaseService db;

  WeeklyReportNotifier(this.db) : super(const AsyncValue.data(null));

  /// 周一自动检测并生成上周周报
  ///
  /// 返回是否已展示周报（供首页判断是否弹窗）
  Future<WeeklyReport?> checkAndGenerateWeeklyReport(AIConfig config) async {
    // 仅周一触发
    final today = DateTime.now();
    if (today.weekday != DateTime.monday) return null;

    // 计算上周一
    final lastMonday = _normalize(today.subtract(Duration(days: today.weekday - 1 + 7)));

    // 已生成则跳过
    final existing = await db.getWeeklyReport(lastMonday);
    if (existing != null) return null;

    // 上周是否有账单
    final hasTransactions = await db.getTransactionsBetween(
      lastMonday,
      lastMonday.add(const Duration(days: 6)),
    );
    if (hasTransactions.isEmpty) return null;

    // 生成周报
    state = const AsyncValue.loading();
    try {
      final report =
          await WeeklyReportService.generateWeeklyReport(lastMonday, config);
      state = AsyncValue.data(report);
      return report;
    } on ParseException catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// 加载历史周报列表
  Future<List<WeeklyReport>> loadHistory() async {
    return await db.getAllWeeklyReports();
  }

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// 周报 Provider
final weeklyReportProvider =
    StateNotifierProvider<WeeklyReportNotifier, AsyncValue<WeeklyReport?>>((ref) {
  return WeeklyReportNotifier(ref.watch(databaseProvider));
});

/// 历史周报列表 Provider
final weeklyReportHistoryProvider = FutureProvider<List<WeeklyReport>>((ref) async {
  return await DatabaseService.instance.getAllWeeklyReports();
});

/// 周报生成辅助：获取上周一日期
DateTime lastMondayOf(DateTime today) {
  return DateTime(today.year, today.month, today.day)
      .subtract(Duration(days: today.weekday - 1 + 7));
}
