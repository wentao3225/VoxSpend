<script setup lang="ts">
import { ref, onMounted, onActivated } from 'vue'
import { useRouter } from 'vue-router'
import type { Transaction } from '../models/transaction'
import { normalizeDate } from '../models/transaction'
import { getTransactionsByDate, getWeeklyReport, saveWeeklyReport } from '../db'
import { generateAiSummary } from '../services/ai-service'
import { useAIConfig } from '../composables/useAIConfig'
import { formatCurrency } from '../utils/format'
import { useTransactionNavigation } from '../composables/useTransactionNavigation'
import TransactionItem from '../components/TransactionItem.vue'
import EmptyState from '../components/EmptyState.vue'

const router = useRouter()
const { goDetail } = useTransactionNavigation()
const { config } = useAIConfig()
const transactions = ref<Transaction[]>([])
const todayTotal = ref(0)

async function loadToday() {
  const today = normalizeDate(new Date())
  transactions.value = await getTransactionsByDate(today)
  todayTotal.value = transactions.value.reduce((s, t) => s + t.amount, 0)
}

async function checkWeeklyReport() {
  const now = new Date()
  const day = now.getDay()
  if (day !== 1) return
  const lastMonday = new Date(now)
  lastMonday.setDate(now.getDate() - 7)
  const weekStart = normalizeDate(lastMonday)
  const existing = await getWeeklyReport(weekStart)
  if (existing) return
  try {
    const { getTransactionsBetween } = await import('../db')
    const end = new Date(lastMonday)
    end.setDate(lastMonday.getDate() + 6)
    const items = await getTransactionsBetween(weekStart, normalizeDate(end))
    if (!items.length) return
    const total = items.reduce((s, t) => s + t.amount, 0)
    const breakdown: Record<string, number> = {}
    items.forEach(t => { breakdown[t.category] = (breakdown[t.category] ?? 0) + t.amount })
    const aiSummary = await generateAiSummary(total, breakdown, config.reportModel)
    const report = {
      weekStartDate: weekStart,
      weekEndDate: normalizeDate(end),
      totalExpense: total,
      categoryBreakdown: breakdown,
      aiSummary,
      generatedAt: Date.now(),
    }
    await saveWeeklyReport(report)
    router.push({ name: 'weekly-report', query: { data: JSON.stringify(report) } })
  } catch {}
}

onMounted(() => {
  loadToday()
  checkWeeklyReport()
})

// keep-alive 缓存下从确认页返回时 onMounted 不触发，用 onActivated 刷新今日数据
onActivated(() => {
  loadToday()
})
</script>

<template>
  <div class="page">
    <div class="page-header">
      <h1>今日账单</h1>
      <button class="back-btn" @click="router.push('/search')">🔍</button>
    </div>
    <div class="page-content">
      <div class="total-card">
        <div class="label">今日支出</div>
        <div class="amount">{{ formatCurrency(todayTotal) }}</div>
      </div>
      <EmptyState
        v-if="!transactions.length"
        icon="🧾"
        title="今天还没有账单"
        subtitle="点击下方按钮开始记一笔吧"
      />
      <template v-else>
        <TransactionItem
          v-for="t in transactions"
          :key="t.id"
          :category="t.category"
          :icon="t.category"
          :description="t.description"
          :meta="`${t.category} · ${t.date}`"
          :amount="t.amount"
          @click="goDetail(t)"
        />
      </template>
    </div>
    <button class="btn btn-primary btn-fab" @click="router.push('/add')">
      <span>+</span> 记一笔
    </button>
  </div>
</template>
