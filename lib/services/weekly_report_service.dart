import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../database/database_service.dart';
import '../models/ai_config.dart';
import '../models/weekly_report.dart';
import 'parse_exception.dart';

/// 周报生成服务
class WeeklyReportService {
  WeeklyReportService._();

  /// 生成指定周的周报（weekStart 必须是周一）
  static Future<WeeklyReport> generateWeeklyReport(
    DateTime weekStart,
    AIConfig config,
  ) async {
    final db = DatabaseService.instance;
    final start = _normalize(weekStart);
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));

    // 1. 查询上周所有账单
    final transactions = await db.getTransactionsBetween(start, end);
    if (transactions.isEmpty) {
      throw const ParseException('上周无账单，无法生成周报');
    }

    // 2. 聚合
    final totalExpense =
        transactions.fold<double>(0, (sum, t) => sum + t.amount);
    final breakdown = <String, double>{};
    for (final t in transactions) {
      breakdown[t.category] = (breakdown[t.category] ?? 0) + t.amount;
    }

    // 3. 调用 AI 生成总结
    final aiSummary = await _generateAiSummary(totalExpense, breakdown, config);

    // 4. 组装保存
    final report = WeeklyReport(
      weekStartDate: start,
      weekEndDate: end.add(const Duration(seconds: 1)),
      totalExpense: totalExpense,
      categoryBreakdownJson: jsonEncode(breakdown),
      aiSummary: aiSummary,
      generatedAt: DateTime.now(),
    );
    await db.saveWeeklyReport(report);
    return report;
  }

  /// 调用 AI 生成周报文字总结（≤150字）
  static Future<String> _generateAiSummary(
    double totalExpense,
    Map<String, double> breakdown,
    AIConfig config,
  ) async {
    if (!config.isReady) {
      throw const ParseException('AI 配置不完整，请先在设置中完成配置');
    }

    final breakdownText = breakdown.entries
        .map((e) => '${e.key}：${e.value.toStringAsFixed(2)}元（${(e.value / totalExpense * 100).toStringAsFixed(1)}%）')
        .join('；');

    final userPrompt = '''
以下是用户上周的消费数据：
总支出：${totalExpense.toStringAsFixed(2)}元
分类明细：$breakdownText

请根据以上数据生成一段简短的消费总结，要求：
1. 不超过150字
2. 指出主要消费构成与占比最高的分类
3. 给出1-2条实用的节省建议
4. 语气友好自然，直接输出总结文字，不要任何前后缀
''';

    final url = config.apiUrl?.isNotEmpty == true
        ? config.apiUrl!
        : AIProviders.defaultApiUrls[config.provider] ?? '';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer ${config.apiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': config.modelName,
              'messages': [
                {'role': 'system', 'content': '你是一个贴心的个人消费分析助手。'},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': 0.4,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        throw const ParseException('API Key 无效，请检查设置');
      }
      if (response.statusCode != 200) {
        throw ParseException('AI 服务返回错误（${response.statusCode}）');
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final choices = body['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw const ParseException('AI 返回内容为空');
      }
      var content = (choices.first as Map<String, dynamic>)['content'] as String? ?? '';
      content = content.trim();
      if (content.isEmpty) {
        throw const ParseException('AI 返回内容为空');
      }
      // 截断至 150 字
      if (content.length > 150) {
        content = content.substring(0, 150);
      }
      return content;
    } on SocketException {
      throw const ParseException('网络连接超时，请检查网络后重试');
    } on TimeoutException {
      throw const ParseException('网络连接超时，请检查网络后重试');
    } on ParseException {
      rethrow;
    } catch (e) {
      throw const ParseException('周报生成失败，请重试');
    }
  }

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}
