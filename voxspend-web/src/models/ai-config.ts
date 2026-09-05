// Agnes API（OpenAI 兼容协议）。按环境分流：
// - Android 原生环境：CapacitorHttp 走原生网络栈，无 CORS 限制，直连 Agnes
// - 浏览器环境：走 /api 相对路径，由 Vite dev proxy 转发（仅开发用）
export const AI_API_URL_NATIVE = 'https://api.agnes-ai.cn/v1/chat/completions'
export const AI_API_URL_WEB = '/api/v1/chat/completions'

// 模型已定死为 agnes-2.5-flash，不允许修改、不在设置页展示、不存 localStorage：
// - 记账解析：关闭思考（更快更稳，输出严格 JSON）
// - 周报总结：开启思考（总结更深入）
export const PARSE_MODEL = 'agnes-2.5-flash'
export const REPORT_MODEL = 'agnes-2.5-flash'
