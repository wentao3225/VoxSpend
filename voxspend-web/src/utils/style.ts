import { CATEGORY_COLORS } from '../models/transaction'

export function getCategoryStyle(category: string, selected = false) {
  const color = CATEGORY_COLORS[category] || '#8E8E93'
  return {
    background: selected ? color : color + '20',
    color: selected ? 'white' : color,
  }
}
