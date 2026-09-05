// 商汤 token.sensenova.cn 不支持浏览器 CORS（OPTIONS 预检返回 404）。
// - Android 原生环境：CapacitorHttp 走原生网络栈，无 CORS 限制，直连商汤
// - 浏览器环境：走 /api 相对路径，由 Vite dev proxy 转发（仅开发用）
export const AI_API_URL_NATIVE = 'https://token.sensenova.cn/v1/chat/completions'
export const AI_API_URL_WEB = '/api/v1/chat/completions'

// 解析模型固定使用 deepseek-v4-flash（更快更稳），不允许修改
export const PARSE_MODEL = 'deepseek-v4-flash'
export const PARSE_MODEL_NAME = 'DeepSeek V4 Flash'

export const REPORT_MODELS = [
  { key: 'sensenova-6.8-flash-lite', name: 'SenseNova 6.8 Flash Lite' },
  { key: 'deepseek-v4-flash', name: 'DeepSeek V4 Flash' },
] as const

export type ModelKey = (typeof REPORT_MODELS)[number]['key']

export interface ModelConfig {
  reportModel: ModelKey
}

const SETTINGS_KEY = 'voxspend_model_config'

export function loadModelConfig(): ModelConfig {
  const raw = localStorage.getItem(SETTINGS_KEY)
  if (raw) {
    try {
      const parsed = JSON.parse(raw) as ModelConfig
      if (parsed && typeof parsed.reportModel === 'string') {
        return { reportModel: parsed.reportModel as ModelKey }
      }
    } catch {}
  }
  return { reportModel: 'sensenova-6.8-flash-lite' }
}

export function saveModelConfig(config: ModelConfig) {
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(config))
}

export function getModelName(key: ModelKey): string {
  return [...REPORT_MODELS].find(m => m.key === key)?.name ?? key
}
