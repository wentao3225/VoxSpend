import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/ai_config.dart';

/// SecureStorage 实例 Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

/// 设置状态管理：AI 配置的读写
class SettingsNotifier extends StateNotifier<AIConfig> {
  final FlutterSecureStorage storage;

  static const _storageKey = 'ai_config';

  SettingsNotifier(this.storage) : super(AIConfig.defaultConfig());

  /// 从 SecureStorage 读取配置（App 启动时调用）
  Future<void> load() async {
    try {
      final raw = await storage.read(key: _storageKey);
      if (raw != null && raw.isNotEmpty) {
        state = AIConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // 读取失败保持默认配置
    }
  }

  /// 更新并持久化配置
  Future<void> save(AIConfig config) async {
    state = config;
    await storage.write(
      key: _storageKey,
      value: jsonEncode(config.toJson()),
    );
  }

  /// 切换 Provider 时应用该平台默认模型与地址
  Future<void> changeProvider(String provider) async {
    await save(state.copyWith(
      provider: provider,
      modelName: AIProviders.defaultModels[provider] ?? '',
      apiUrl: AIProviders.defaultApiUrls[provider],
      clearApiUrl: provider != AIProviders.custom,
    ));
  }
}

/// 设置 Provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AIConfig>((ref) {
  return SettingsNotifier(ref.watch(secureStorageProvider));
});
