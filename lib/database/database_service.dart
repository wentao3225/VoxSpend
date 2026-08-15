import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/transaction.dart';
import '../models/weekly_report.dart';

/// Isar 数据库单例 + CRUD 服务
class DatabaseService {
  DatabaseService._internal(this.isar);

  static DatabaseService? _instance;

  final Isar isar;

  /// 初始化数据库（App 启动时调用一次）
  static Future<DatabaseService> init() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [TransactionSchema, WeeklyReportSchema],
      directory: dir.path,
    );
    _instance = DatabaseService._internal(isar);
    return _instance!;
  }

  static DatabaseService get instance {
    assert(_instance != null, 'DatabaseService 未初始化，请先调用 init()');
    return _instance!;
  }

  // ==================== Transaction CRUD ====================

  /// 查询某天的账单（按创建时间倒序）
  Future<List<Transaction>> getTransactionsByDate(DateTime date) async {
    final normalized = _normalizeDate(date);
    final list = await isar.collection<Transaction>()
        .filter()
        .dateEqualTo(normalized)
        .findAll();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
  /// 批量新增账单
  Future<List<Transaction>> addAll(List<Transaction> transactions) async {
    await isar.writeTxn(() async {
      await isar.collection<Transaction>().putAll(transactions);
    });
    return transactions;
  }

  /// 更新账单
  Future<void> update(Transaction transaction) async {
    await isar.writeTxn(() async {
      await isar.collection<Transaction>().put(transaction);
    });
  }

  /// 删除账单
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.collection<Transaction>().delete(id);
    });
  }

  /// 多维度搜索
  ///
  /// - [keyword]：描述关键词（descriptionContains）
  /// - [categories]：类别多选（OR 组合）
  /// - [startDate]/[endDate]：日期范围
  /// - [minAmount]/[maxAmount]：金额区间
  Future<List<Transaction>> searchTransactions({
    String? keyword,
    List<String>? categories,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    // Isar QueryBuilder 类型链：统一先取全表再在内存过滤
    // （个人记账数据量小，内存过滤性能足够且语义清晰）
    final all = await isar.collection<Transaction>().where().anyId().findAll();

    Iterable<Transaction> result = all;

    // 关键词
    final kw = keyword?.trim() ?? '';
    if (kw.isNotEmpty) {
      result = result.where((t) => t.description.contains(kw));
    }

    // 类别多选
    if (categories != null && categories.isNotEmpty) {
      result = result.where((t) => categories.contains(t.category));
    }

    // 日期范围
    if (startDate != null) {
      final s = _normalizeDate(startDate);
      result = result.where((t) => !t.date.isBefore(s));
    }
    if (endDate != null) {
      final e = _normalizeEndOfDay(endDate);
      result = result.where((t) => !t.date.isAfter(e));
    }

    // 金额区间
    if (minAmount != null) {
      final min = minAmount;
      result = result.where((t) => t.amount >= min);
    }
    if (maxAmount != null) {
      final max = maxAmount;
      result = result.where((t) => t.amount <= max);
    }

    final list = result.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// 查询日期范围内的账单（用于周报聚合）
  Future<List<Transaction>> getTransactionsBetween(
    DateTime start,
    DateTime end,
  ) async {
    return await isar.collection<Transaction>()
        .filter()
        .dateGreaterThan(_normalizeDate(start), include: true)
        .and()
        .dateLessThan(_normalizeEndOfDay(end), include: true)
        .findAll();
  }

  // ==================== WeeklyReport CRUD ====================

  /// 获取某周周报
  Future<WeeklyReport?> getWeeklyReport(DateTime weekStart) async {
    return await isar.collection<WeeklyReport>()
        .filter()
        .weekStartDateEqualTo(_normalizeDate(weekStart))
        .findFirst();
  }

  /// 保存周报（每周唯一，替换旧数据）
  Future<void> saveWeeklyReport(WeeklyReport report) async {
    await isar.writeTxn(() async {
      await isar.collection<WeeklyReport>().putByWeekStartDate(report);
    });
  }

  /// 获取所有历史周报（按周开始时间倒序）
  Future<List<WeeklyReport>> getAllWeeklyReports() async {
    final list = await isar.collection<WeeklyReport>().where().anyId().findAll();
    list.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
    return list;
  }

  /// 归一化日期到 00:00:00
  static DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  /// 归一化日期到 23:59:59.999
  static DateTime _normalizeEndOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
}
