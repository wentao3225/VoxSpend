export interface Transaction {
  id?: number
  description: string
  amount: number
  category: string
  date: string // YYYY-MM-DD
  createdAt: number // timestamp
}

export const CATEGORIES = ['餐饮', '交通', '购物', '娱乐', '居住', '医疗', '教育', '其他'] as const
export type Category = (typeof CATEGORIES)[number]

export const CATEGORY_COLORS: Record<string, string> = {
  '餐饮': '#FF9500',
  '交通': '#5856D6',
  '购物': '#FF2D55',
  '娱乐': '#AF52DE',
  '居住': '#34C759',
  '医疗': '#FF3B30',
  '教育': '#5AC8FA',
  '其他': '#8E8E93',
}

export function normalizeCategory(category: string | null | undefined): string {
  if (!category) return '其他'
  const trimmed = category.trim()
  return (CATEGORIES as readonly string[]).includes(trimmed) ? trimmed : '其他'
}

export function normalizeDate(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}
