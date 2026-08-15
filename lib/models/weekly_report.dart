import 'dart:convert';

import 'package:isar/isar.dart';

part 'weekly_report.g.dart';

/// 周报实体
@collection
class WeeklyReport {
  Id id = Isar.autoIncrement;

  /// 周一 00:00:00，每周唯一
  @Index(unique: true, replace: true)
  DateTime weekStartDate;

  /// 周日 23:59:59
  DateTime weekEndDate;

  /// 上周总支出
  double totalExpense;

  /// Map<String, double> 的 JSON 序列化（Isar 不支持 Map 原生类型）
  String categoryBreakdownJson;

  /// AI 生成的文字总结（≤150字）
  String aiSummary;

  /// 生成时间
  DateTime generatedAt;

  WeeklyReport({
    this.id = Isar.autoIncrement,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.totalExpense,
    required this.categoryBreakdownJson,
    required this.aiSummary,
    required this.generatedAt,
  });

  /// 反序列化分类明细（Isar 忽略此计算属性）
  @ignore
  Map<String, double> get categoryBreakdown {
    if (categoryBreakdownJson.isEmpty) return {};
    try {
      final raw = jsonDecode(categoryBreakdownJson) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  /// 序列化分类明细
  static String encodeBreakdown(Map<String, double> breakdown) {
    return jsonEncode(breakdown);
  }
}

