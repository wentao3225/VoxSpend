import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/ai_config.dart';
import '../models/transaction.dart';
import 'ai_providers/bailian_provider.dart';
import 'ai_providers/custom_provider.dart';
import 'ai_providers/deepseek_provider.dart';
import 'ai_providers/sensechat_provider.dart';
import 'parse_exception.dart';

/// AI 解析器抽象接口（Strategy 模式）
abstract interface class AiParser {
  /// 解析自然语言为账单列表
  Future<List<Transaction>> parse(
    String input,
    DateTime date,
    AIConfig config,
  );

  /// 发送 OpenAI 兼容的 chat completions 请求，各 Provider 复用
  Future<String> chatCompletion({
    required AIConfig config,
    required String apiUrl,
    required String systemPrompt,
    required String userPrompt,
  });
}

/// Provider 基类：提供 HTTP 请求通用实现
abstract class AiParserBase implements AiParser {
  @override
  Future<String> chatCompletion({
    required AIConfig config,
    required String apiUrl,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer ${config.apiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': config.modelName,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': 0.2,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw const ParseException('API Key 无效，请检查设置');
      }
      if (response.statusCode != 200) {
        throw ParseException('AI 服务返回错误（${response.statusCode}），请重试');
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final choices = body['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw const ParseException('AI 返回内容为空，请重试');
      }
      final content = (choices.first as Map<String, dynamic>)['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw const ParseException('AI 返回内容为空，请重试');
      }
      return content;
    } on SocketException {
      throw const ParseException('网络连接超时，请检查网络后重试');
    } on TimeoutException {
      throw const ParseException('网络连接超时，请检查网络后重试');
    } on ParseException {
      rethrow;
    } catch (e) {
      throw const ParseException('AI 请求失败，请重试');
    }
  }
}

/// AI 服务入口（Factory 模式）
class AIService {
  AIService._();

  static final Map<String, AiParser> _parsers = {
    AIProviders.deepseek: DeepSeekProvider(),
    AIProviders.bailian: BailianProvider(),
    AIProviders.sensechat: SenseChatProvider(),
    AIProviders.custom: CustomProvider(),
  };

  static AiParser _getProvider(String provider) {
    final parser = _parsers[provider];
    if (parser == null) {
      throw UnsupportedError('未知的 AI Provider: $provider');
    }
    return parser;
  }

  /// 解析自然语言为账单列表
  static Future<List<Transaction>> parseTransactions(
    String input,
    DateTime date,
    AIConfig config,
  ) async {
    if (!config.isReady) {
      throw const ParseException('AI 配置不完整，请先在设置中完成配置');
    }
    final parser = _getProvider(config.provider);
    return parser.parse(input, date, config);
  }
}

/// 各 Provider 共用的 Prompt 与响应解析逻辑
///
/// 使用方式：class XxxProvider extends AiParserBase with ParserMixin
mixin ParserMixin implements AiParser {
  /// 记账解析 System Prompt
  static const String kSystemPrompt = '''
你是一个记账助手。请将用户的口语化记账描述解析成结构化数据。
规则：
1. 输入可能是多条记录，用自然语言描述，没有固定分隔符
2. 你必须识别出每一条独立的消费记录
3. 每条记录必须包含：description（消费内容，简短）、amount（金额数字）、category（必须从以下类别中选择：餐饮、交通、购物、娱乐、居住、医疗、教育、其他）
4. 如果用户没有明确日期，使用提供的默认日期（忽略时分秒）
5. 如果某条记录缺少金额或缺少消费内容，该条标记为解析失败
6. 输出必须是严格的 JSON 数组格式，不要有任何 markdown 代码块标记，不要解释
7. 金额统一为数字（元），不要带单位

示例输出：
[{"description":"买面包","amount":5.0,"category":"餐饮"},{"description":"打车回家","amount":35.0,"category":"交通"}]
''';

  /// 构造 User Prompt
  String buildUserPrompt(String input, DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '记账描述：$input\n默认日期：$dateStr';
  }

  /// 解析 AI 响应为账单列表（含校验）
  List<Transaction> parseResponse(String response, DateTime defaultDate) {
    // 剥离可能的 markdown 代码块标记
    var text = response.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(json)?'), '').trim();
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3).trim();
      }
    }

    List<dynamic> jsonList;
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map && decoded.containsKey('error')) {
        throw ParseException('AI 返回错误：${decoded['error']}');
      } else {
        throw const ParseException('AI 返回格式错误，请重试');
      }
    } on FormatException {
      throw const ParseException('AI 返回格式错误，请重试');
    }

    if (jsonList.isEmpty) {
      throw const ParseException('未识别到任何消费记录，请检查输入');
    }

    final results = <Transaction>[];
    for (var i = 0; i < jsonList.length; i++) {
      final item = jsonList[i];
      if (item is! Map) {
        throw ParseException('第 ${i + 1} 条记录格式错误');
      }
      final map = Map<String, dynamic>.from(item);

      // description 校验
      final desc = (map['description'] ?? '').toString().trim();
      if (desc.isEmpty) {
        throw ParseException('第 ${i + 1} 条记录缺少消费内容');
      }

      // amount 校验
      final dynamic rawAmount = map['amount'];
      final double? amount = rawAmount is int
          ? rawAmount.toDouble()
          : rawAmount is double
              ? rawAmount
              : double.tryParse(rawAmount?.toString() ?? '');
      if (amount == null || amount <= 0) {
        throw ParseException('第 ${i + 1} 条记录缺少金额或金额无效');
      }

      // category 归一化
      final category = Categories.normalize(map['category']?.toString());

      results.add(Transaction(
        description: desc,
        amount: amount,
        category: category,
        date: _normalize(defaultDate),
        createdAt: DateTime.now(),
      ));
    }
    return results;
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}
