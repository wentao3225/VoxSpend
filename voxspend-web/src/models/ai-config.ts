const TARGET_API = 'https://token.sensenova.cn/v1/chat/completions'
const isDev = import.meta.env.DEV
export const AI_API_URL = isDev
  ? `https://corsproxy.io/?url=${encodeURIComponent(TARGET_API)}`
  : TARGET_API

export const PARSE_MODELS = [
  { key: 'sensenova-6.7-flash-lite', name: 'SenseNova 6.7 Flash Lite' },
  { key: 'deepseek-v4-flash', name: 'DeepSeek V4 Flash' },
  { key: 'glm-5.2', name: 'GLM 5.2' },
  { key: 'sensenova-6.8-flash-lite', name: 'SenseNova 6.8 Flash Lite' },
] as const

export const REPORT_MODELS = [
  { key: 'sensenova-6.7-flash-lite', name: 'SenseNova 6.7 Flash Lite' },
  { key: 'deepseek-v4-flash', name: 'DeepSeek V4 Flash' },
  { key: 'glm-5.2', name: 'GLM 5.2' },
  { key: 'sensenova-6.8-flash-lite', name: 'SenseNova 6.8 Flash Lite' },
] as const

export type ModelKey = (typeof PARSE_MODELS)[number]['key']

export interface ModelConfig {
  parseModel: ModelKey
  reportModel: ModelKey
}

const SETTINGS_KEY = 'voxspend_model_config'

export function loadModelConfig(): ModelConfig {
  const raw = localStorage.getItem(SETTINGS_KEY)
  if (raw) {
    try { return JSON.parse(raw) } catch {}
  }
  return { parseModel: 'sensenova-6.7-flash-lite', reportModel: 'sensenova-6.8-flash-lite' }
}

export function saveModelConfig(config: ModelConfig) {
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(config))
}

export function getModelName(key: ModelKey): string {
  return [...PARSE_MODELS].find(m => m.key === key)?.name ?? key
}
