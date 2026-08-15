/// AI 服务配置（非 Isar，JSON 序列化存于 FlutterSecureStorage）
class AIConfig {
  /// "deepseek" | "bailian" | "sensechat" | "custom"
  final String provider;

  final String apiKey;

  /// 如 "deepseek-chat"
  final String modelName;

  /// 自定义时必填，如 "https://api.xxx.com/v1"
  final String? apiUrl;

  const AIConfig({
    required this.provider,
    required this.apiKey,
    required this.modelName,
    this.apiUrl,
  });

  /// 默认配置
  factory AIConfig.defaultConfig() {
    return const AIConfig(
      provider: 'deepseek',
      apiKey: '',
      modelName: 'deepseek-chat',
      apiUrl: null,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'apiKey': apiKey,
        'modelName': modelName,
        'apiUrl': apiUrl,
      };

  factory AIConfig.fromJson(Map<String, dynamic> json) {
    return AIConfig(
      provider: json['provider'] as String? ?? 'deepseek',
      apiKey: json['apiKey'] as String? ?? '',
      modelName: json['modelName'] as String? ?? '',
      apiUrl: json['apiUrl'] as String?,
    );
  }

  AIConfig copyWith({
    String? provider,
    String? apiKey,
    String? modelName,
    String? apiUrl,
    bool clearApiUrl = false,
  }) {
    return AIConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      apiUrl: clearApiUrl ? null : (apiUrl ?? this.apiUrl),
    );
  }

  /// 配置是否完整可用
  bool get isReady {
    if (apiKey.isEmpty || modelName.isEmpty) return false;
    if (provider == 'custom') {
      return apiUrl != null && apiUrl!.isNotEmpty;
    }
    return true;
  }
}

/// 支持的 AI Provider 常量
class AIProviders {
  static const String deepseek = 'deepseek';
  static const String bailian = 'bailian';
  static const String sensechat = 'sensechat';
  static const String custom = 'custom';

  static const List<String> all = [deepseek, bailian, sensechat, custom];

  /// 展示名称
  static const Map<String, String> displayNames = {
    deepseek: 'DeepSeek',
    bailian: '阿里云百炼',
    sensechat: '商汤日日新',
    custom: '自定义 OpenAI 兼容',
  };

  /// 各平台默认 API 地址（OpenAI 兼容 chat completions 端点）
  static const Map<String, String> defaultApiUrls = {
    deepseek: 'https://api.deepseek.com/v1/chat/completions',
    bailian: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
    sensechat: 'https://api.sensenova.cn/compatible-mode/v1/chat/completions',
    custom: '',
  };

  /// 各平台默认模型名
  static const Map<String, String> defaultModels = {
    deepseek: 'deepseek-chat',
    bailian: 'qwen-plus',
    sensechat: 'SenseChat-5',
    custom: '',
  };

  static String displayName(String provider) =>
      displayNames[provider] ?? provider;
}
