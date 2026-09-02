export function validateTransaction(fields: { description: string; amount: number }): string | null {
  if (!fields.description.trim()) return '请输入账单描述'
  if (fields.amount <= 0) return '金额必须大于 0'
  return null
}
