const API_KEY = import.meta.env.VITE_AI_API_KEY as string

export function useAIConfig() {
  // 模型已定死（agnes-2.5-flash），不再有可配置项，仅暴露 API Key 就绪状态
  const isReady = !!API_KEY

  return { isReady }
}
