/// AI 解析自定义异常
class ParseException implements Exception {
  final String reason;

  const ParseException(this.reason);

  @override
  String toString() => reason;
}
