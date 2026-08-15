import '../../models/ai_config.dart';
import '../../models/transaction.dart';
import '../ai_service.dart';
import '../parse_exception.dart';

/// 自定义 OpenAI 兼容接口实现
class CustomProvider extends AiParserBase with ParserMixin {
  @override
  Future<List<Transaction>> parse(
    String input,
    DateTime date,
    AIConfig config,
  ) async {
    final url = config.apiUrl;
    if (url == null || url.trim().isEmpty) {
      throw const ParseException('自定义模式必须填写 API 地址');
    }
    final content = await chatCompletion(
      config: config,
      apiUrl: url,
      systemPrompt: ParserMixin.kSystemPrompt,
      userPrompt: buildUserPrompt(input, date),
    );
    return parseResponse(content, date);
  }
}
