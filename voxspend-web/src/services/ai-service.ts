import { CapacitorHttp } from '@capacitor/core'
import { Capacitor } from '@capacitor/core'
import { AI_API_URL_NATIVE, AI_API_URL_WEB, PARSE_MODEL } from '../models/ai-config'
import type { Transaction } from '../models/transaction'
import { normalizeCategory, normalizeDate } from '../models/transaction'

const API_KEY = import.meta.env.VITE_AI_API_KEY as string

export class ParseException {
  reason: string
  constructor(reason: string) {
    this.reason = reason
  }
}

function getApiKey(): string {
  if (!API_KEY) throw new ParseException('未配置 AI API Key，请在 .env 文件中设置 VITE_AI_API_KEY')
  return API_KEY
}

const PARSE_SYSTEM_PROMPT = `你是一个记账助手。请将用户的口语化记账描述解析成结构化数据。
规则：
1. 输入可能是多条记录，用自然语言描述，没有固定分隔符
2. 你必须识别出每一条独立的消费记录
3. 每条记录必须包含：description（消费内容，简短）、amount（金额数字）、category（必须从以下类别中选择：餐饮、交通、购物、娱乐、居住、医疗、教育、其他）
4. 如果用户没有明确日期，使用提供的默认日期（忽略时分秒）
5. 如果某条记录缺少金额或缺少消费内容，该条标记为解析失败
6. 输出必须是严格的 JSON 数组格式，不要有任何 markdown 代码块标记，不要解释
7. 金额统一为数字（元），不要带单位

示例输出：
[{"description":"买面包","amount":5.0,"category":"餐饮"},{"description":"打车回家","amount":35.0,"category":"交通"}]`

const REPORT_SYSTEM_PROMPT = '你是一个贴心的个人消费分析助手。'

async function chatCompletion(opts: {
  systemPrompt: string
  userPrompt: string
  timeout?: number
  thinking?: boolean
}): Promise<string> {
  const { systemPrompt, userPrompt, timeout = 60000, thinking = false } = opts
  const apiKey = getApiKey()
  const reqBody: Record<string, unknown> = {
    model: PARSE_MODEL,
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt },
    ],
    temperature: 0.2,
    // Agnes 思考模式：enable_thinking 控制开/关（解析关、周报开）
    chat_template_kwargs: { enable_thinking: thinking },
  }
  try {
    let status: number
    let body: any

    if (Capacitor.isNativePlatform()) {
      // 原生环境：CapacitorHttp 走原生网络栈，无 CORS 限制，直连 Agnes
      const res = await CapacitorHttp.post({
        url: AI_API_URL_NATIVE,
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        data: reqBody,
        connectTimeout: timeout,
        readTimeout: timeout,
      })
      status = res.status
      body = typeof res.data === 'string' ? safeJsonParse(res.data) : res.data
    } else {
      // 浏览器环境：走 /api 相对路径，由 Vite dev proxy 转发
      const controller = new AbortController()
      const timer = setTimeout(() => controller.abort(), timeout)
      const res = await fetch(AI_API_URL_WEB, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(reqBody),
        signal: controller.signal,
      })
      clearTimeout(timer)
      status = res.status
      body = await res.json()
    }

    if (status === 401) throw new ParseException('API Key 无效，请检查 .env 配置')
    if (status < 200 || status >= 300) throw new ParseException(`AI 服务返回错误（${status}），请重试`)
    console.log('[AI Service] Response:', JSON.stringify(body).slice(0, 500))
    const choices = body.choices as any[]
    if (!choices?.length) throw new ParseException('AI 返回内容为空，请重试')
    const content = choices[0].message?.content as string
    console.log('[AI Service] Content length:', content?.length)
    if (!content?.trim()) throw new ParseException('AI 返回内容为空，请重试')
    return content
  } catch (e) {
    if (e instanceof ParseException) throw e
    if (e instanceof DOMException && e.name === 'AbortError') {
      throw new ParseException('网络连接超时，请检查网络后重试')
    }
    throw new ParseException('AI 请求失败，请重试')
  }
}

function safeJsonParse(text: string): any {
  try {
    return JSON.parse(text)
  } catch {
    return {}
  }
}

function extractJsonList(text: string): any[] | null {
  // 直接解析整个文本
  try {
    const decoded = JSON.parse(text)
    if (Array.isArray(decoded)) return decoded
    if (decoded && Array.isArray(decoded.transactions)) return decoded.transactions
    // 如果返回的是单个对象，包装成数组
    if (decoded && typeof decoded === 'object' && !Array.isArray(decoded)) {
      return [decoded]
    }
  } catch {}
  // 兜底：从文本中截取 [ ... ] 数组片段（兼容模型输出前后附带的解释文字）
  const start = text.indexOf('[')
  const end = text.lastIndexOf(']')
  if (start !== -1 && end > start) {
    try {
      const decoded = JSON.parse(text.slice(start, end + 1))
      if (Array.isArray(decoded)) return decoded
    } catch {}
  }
  // 兜底：从文本中截取 { ... } 对象片段（兼容模型输出单个对象）
  const objStart = text.indexOf('{')
  const objEnd = text.lastIndexOf('}')
  if (objStart !== -1 && objEnd > objStart) {
    try {
      const decoded = JSON.parse(text.slice(objStart, objEnd + 1))
      if (decoded && typeof decoded === 'object' && !Array.isArray(decoded)) {
        return [decoded]
      }
    } catch {}
  }
  // 兜底：循环解码多段 JSON，取第一段数组（兼容模型连续输出多份对象拼接）
  try {
    let idx = 0
    while (idx < text.length) {
      const slice = text.slice(idx)
      if (slice.trimStart().startsWith('[')) {
        const decoded = JSON.parse(slice)
        if (Array.isArray(decoded)) return decoded
      }
      const match = /^\s*[\[{]/.exec(slice)
      if (!match) break
      const value = JSON.parse(slice)
      if (Array.isArray(value)) return value
      idx += JSON.stringify(value).length
      if (idx <= 0) break
    }
  } catch {}
  return null
}

function parseResponse(response: string, defaultDate: Date): Transaction[] {
  let text = response.trim()
  if (text.startsWith('```')) {
    text = text.replace(/^```(json)?/, '').trim()
    if (text.endsWith('```')) text = text.slice(0, -3).trim()
  }
  const jsonList = extractJsonList(text)
  if (!jsonList) {
    throw new ParseException('AI 返回格式错误，请重试')
  }
  if (!jsonList.length) throw new ParseException('未识别到任何消费记录，请检查输入')
  const results: Transaction[] = []
  const dateStr = normalizeDate(defaultDate)
  const baseTime = Date.now()
  for (let i = 0; i < jsonList.length; i++) {
    const item = jsonList[i]
    if (!item || typeof item !== 'object') throw new ParseException(`第 ${i + 1} 条记录格式错误`)
    // 兼容部分模型返回中文键名（如模型可能输出"描述"/"金额"/"类别"）
    const desc = String(item.description ?? item.描述 ?? '').trim()
    const amountVal = item.amount ?? item.金额
    const category = item.category ?? item.类别
    if (!desc) throw new ParseException(`第 ${i + 1} 条记录缺少消费内容`)
    const amount = typeof amountVal === 'number' ? amountVal : parseFloat(amountVal)
    if (!amount || amount <= 0) throw new ParseException(`第 ${i + 1} 条记录缺少金额或金额无效`)
    // 确保每条记录有唯一的时间戳（毫秒级递增）
    results.push({
      description: desc,
      amount,
      category: normalizeCategory(category),
      date: dateStr,
      createdAt: baseTime + i,
    })
  }
  return results
}

export async function parseTransactions(
  input: string,
  date: Date,
): Promise<Transaction[]> {
  const content = await chatCompletion({
    systemPrompt: PARSE_SYSTEM_PROMPT,
    userPrompt: `记账描述：${input}\n默认日期：${normalizeDate(date)}`,
  })
  return parseResponse(content, date)
}

export async function generateAiSummary(
  totalExpense: number,
  breakdown: Record<string, number>,
): Promise<string> {
  const breakdownText = Object.entries(breakdown)
    .map(([k, v]) => `${k}：${v.toFixed(2)}元（${(v / totalExpense * 100).toFixed(1)}%）`)
    .join('；')
  const userPrompt = `以下是用户上周的消费数据：
总支出：${totalExpense.toFixed(2)}元
分类明细：${breakdownText}

请根据以上数据生成一段简短的消费总结，要求：
1. 不超过150字
2. 指出主要消费构成与占比最高的分类
3. 给出1-2条实用的节省建议
4. 语气友好自然，直接输出总结文字，不要任何前后缀`

  const content = await chatCompletion({
    systemPrompt: REPORT_SYSTEM_PROMPT,
    userPrompt,
    timeout: 60000,
    thinking: true,
  })
  return content.length > 150 ? content.substring(0, 150) : content
}
