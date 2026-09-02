export interface WeeklyReport {
  id?: number
  weekStartDate: string // YYYY-MM-DD
  weekEndDate: string
  totalExpense: number
  categoryBreakdown: Record<string, number>
  aiSummary: string
  generatedAt: number
}
