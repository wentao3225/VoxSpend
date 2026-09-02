import { normalizeDate } from '../models/transaction'

export function formatCurrency(amount: number): string {
  return `¥${amount.toFixed(2)}`
}

export function formatDateDisplay(d: Date): string {
  const today = new Date()
  const yesterday = new Date(today)
  yesterday.setDate(yesterday.getDate() - 1)

  const ds = normalizeDate(d)
  const ts = normalizeDate(today)
  const ys = normalizeDate(yesterday)

  if (ds === ts) return `今天 (${ds})`
  if (ds === ys) return `昨天 (${ds})`
  return ds
}
