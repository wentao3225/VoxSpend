import { loadModelConfig } from '../models/ai-config'

const API_KEY = import.meta.env.VITE_AI_API_KEY as string

export function useAIConfig() {
  const config = loadModelConfig()
  const isReady = !!API_KEY

  return { config, isReady }
}
