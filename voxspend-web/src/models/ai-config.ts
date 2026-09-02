export interface AIConfig {
  provider: string
  apiKey: string
  modelName: string
  apiUrl?: string
}

export const AI_PROVIDERS = [
  { key: 'deepseek', name: 'DeepSeek', defaultModel: 'deepseek-chat', defaultUrl: 'https://api.deepseek.com/v1/chat/completions' },
  { key: 'bailian', name: '阿里云百炼', defaultModel: 'qwen-plus', defaultUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions' },
  { key: 'sensechat', name: '商汤日日新', defaultModel: 'SenseChat-5', defaultUrl: 'https://api.sensenova.cn/compatible-mode/v1/chat/completions' },
  { key: 'custom', name: '自定义 OpenAI 兼容', defaultModel: '', defaultUrl: '' },
] as const

export function getDefaultConfig(): AIConfig {
  return { provider: 'deepseek', apiKey: '', modelName: 'deepseek-chat' }
}

export function isConfigReady(config: AIConfig): boolean {
  if (!config.apiKey || !config.modelName) return false
  if (config.provider === 'custom') return !!config.apiUrl
  return true
}

export function getProviderInfo(provider: string) {
  return AI_PROVIDERS.find(p => p.key === provider) ?? AI_PROVIDERS[0]
}
