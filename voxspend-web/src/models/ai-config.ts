export const AI_API_URL = '/api/v1/chat/completions'

export const PARSE_MODELS = [
  { key: 'sensenova-6.8-flash-lite', name: 'SenseNova 6.8 Flash Lite' },
  { key: 'deepseek-v4-flash', name: 'DeepSeek V4 Flash' },
] as const

export const REPORT_MODELS = [
  { key: 'sensenova-6.8-flash-lite', name: 'SenseNova 6.8 Flash Lite' },
  { key: 'deepseek-v4-flash', name: 'DeepSeek V4 Flash' },
] as const

export type ModelKey = (typeof PARSE_MODELS)[number]['key']

export interface ModelConfig {
  parseModel: ModelKey
  reportModel: ModelKey
}

const SETTINGS_KEY = 'voxspend_model_config'
// 旧默认值（sensenova 太慢不稳定），自动迁移到新默认值
const MIGRATED_KEY = 'voxspend_model_migrated_v2'

export function loadModelConfig(): ModelConfig {
  const raw = localStorage.getItem(SETTINGS_KEY)
  if (raw) {
    try {
      const parsed = JSON.parse(raw) as ModelConfig
      // 若用户用的是旧默认模型，自动迁移（只迁移一次）
      if (!localStorage.getItem(MIGRATED_KEY) && parsed.parseModel === 'sensenova-6.8-flash-lite') {
        parsed.parseModel = 'deepseek-v4-flash'
        saveModelConfig(parsed)
        localStorage.setItem(MIGRATED_KEY, '1')
      }
      return parsed
    } catch {}
  }
  return { parseModel: 'deepseek-v4-flash', reportModel: 'sensenova-6.8-flash-lite' }
}

export function saveModelConfig(config: ModelConfig) {
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(config))
}

export function getModelName(key: ModelKey): string {
  return [...PARSE_MODELS].find(m => m.key === key)?.name ?? key
}
