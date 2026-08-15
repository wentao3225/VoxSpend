import '../../models/ai_config.dart';
import '../../models/transaction.dart';
import '../ai_service.dart';

/// 商汤日日新平台实现
class SenseChatProvider extends AiParserBase with ParserMixin {
  @override
  Future<List<Transaction>> parse(
    String input,
    DateTime date,
    AIConfig config,
  ) async {
    final content = await chatCompletion(
      config: config,
      apiUrl: config.apiUrl?.isNotEmpty == true
          ? config.apiUrl!
          : 'https://api.sensenova.cn/compatible-mode/v1/chat/completions',
      systemPrompt: ParserMixin.kSystemPrompt,
      userPrompt: buildUserPrompt(input, date),
    );
    return parseResponse(content, date);
  }
}
