import type { AIConfig } from '../models/ai-config'
import { getProviderInfo } from '../models/ai-config'
import type { Transaction } from '../models/transaction'
import { normalizeCategory, normalizeDate } from '../models/transaction'

export class ParseException {
  constructor(public reason: string) {}
}

const SYSTEM_PROMPT = `你是一个记账助手。请将用户的口语化记账描述解析成结构化数据。
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

function buildUserPrompt(input: string, date: Date): string {
  const dateStr = normalizeDate(date)
  return `记账描述：${input}\n默认日期：${dateStr}`
}

async function chatCompletion(opts: {
  config: AIConfig
  apiUrl: string
  systemPrompt: string
  userPrompt: string
  timeout?: number
}): Promise<string> {
  const { config, apiUrl, systemPrompt, userPrompt, timeout = 10000 } = opts
  try {
    const controller = new AbortController()
    const timer = setTimeout(() => controller.abort(), timeout)
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: config.modelName,
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
        ],
        temperature: 0.2,
      }),
      signal: controller.signal,
    })
    clearTimeout(timer)
    if (res.status === 401) throw new ParseException('API Key 无效，请检查设置')
    if (!res.ok) throw new ParseException(`AI 服务返回错误（${res.status}），请重试`)
    const body = await res.json()
    const choices = body.choices as any[]
    if (!choices?.length) throw new ParseException('AI 返回内容为空，请重试')
    const content = choices[0].content as string
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

function parseResponse(response: string, defaultDate: Date): Transaction[] {
  let text = response.trim()
  if (text.startsWith('```')) {
    text = text.replace(/^```(json)?/, '').trim()
    if (text.endsWith('```')) text = text.slice(0, -3).trim()
  }
  let jsonList: any[]
  try {
    const decoded = JSON.parse(text)
    if (Array.isArray(decoded)) {
      jsonList = decoded
    } else {
      throw new ParseException('AI 返回格式错误，请重试')
    }
  } catch {
    throw new ParseException('AI 返回格式错误，请重试')
  }
  if (!jsonList.length) throw new ParseException('未识别到任何消费记录，请检查输入')
  const results: Transaction[] = []
  const dateStr = normalizeDate(defaultDate)
  for (let i = 0; i < jsonList.length; i++) {
    const item = jsonList[i]
    if (!item || typeof item !== 'object') throw new ParseException(`第 ${i + 1} 条记录格式错误`)
    const desc = String(item.description ?? '').trim()
    if (!desc) throw new ParseException(`第 ${i + 1} 条记录缺少消费内容`)
    const amount = typeof item.amount === 'number' ? item.amount : parseFloat(item.amount)
    if (!amount || amount <= 0) throw new ParseException(`第 ${i + 1} 条记录缺少金额或金额无效`)
    results.push({
      description: desc,
      amount,
      category: normalizeCategory(item.category),
      date: dateStr,
      createdAt: Date.now(),
    })
  }
  return results
}

export async function parseTransactions(
  input: string,
  date: Date,
  config: AIConfig,
): Promise<Transaction[]> {
  if (!config.apiKey || !config.modelName) {
    throw new ParseException('AI 配置不完整，请先在设置中完成配置')
  }
  const info = getProviderInfo(config.provider)
  const apiUrl = config.apiUrl || info.defaultUrl
  if (!apiUrl) throw new ParseException('自定义模式必须填写 API 地址')
  const content = await chatCompletion({
    config,
    apiUrl,
    systemPrompt: SYSTEM_PROMPT,
    userPrompt: buildUserPrompt(input, date),
  })
  return parseResponse(content, date)
}

export async function generateAiSummary(
  totalExpense: number,
  breakdown: Record<string, number>,
  config: AIConfig,
): Promise<string> {
  if (!config.apiKey || !config.modelName) {
    throw new ParseException('AI 配置不完整，请先在设置中完成配置')
  }
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

  const info = getProviderInfo(config.provider)
  const apiUrl = config.apiUrl || info.defaultUrl
  const content = await chatCompletion({
    config,
    apiUrl,
    systemPrompt: '你是一个贴心的个人消费分析助手。',
    userPrompt,
    timeout: 15000,
  })
  return content.length > 150 ? content.substring(0, 150) : content
}
