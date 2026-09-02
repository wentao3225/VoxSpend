import { loadAIConfig } from '../db'
import type { AIConfig } from '../models/ai-config'

export function useAIConfig() {
  const config = loadAIConfig()
  const isReady = !!config?.apiKey

  return { config: config as AIConfig | null, isReady }
}
