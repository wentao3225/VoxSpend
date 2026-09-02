<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { Transaction } from '../models/transaction'
import { CATEGORY_COLORS, normalizeDate } from '../models/transaction'
import { getTransactionsByDate } from '../db'
import { loadAIConfig } from '../db'
import { generateAiSummary } from '../services/ai-service'
import { getWeeklyReport, saveWeeklyReport } from '../db'

const router = useRouter()
const transactions = ref<Transaction[]>([])
const todayTotal = ref(0)

async function loadToday() {
  const today = normalizeDate(new Date())
  transactions.value = await getTransactionsByDate(today)
  todayTotal.value = transactions.value.reduce((s, t) => s + t.amount, 0)
}

async function checkWeeklyReport() {
  const config = loadAIConfig()
  if (!config?.apiKey) return
  const now = new Date()
  const day = now.getDay() // 0=Sun
  if (day !== 1) return // only on Monday
  // last Monday
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
    const aiSummary = await generateAiSummary(total, breakdown, config)
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

function goDetail(t: Transaction) {
  router.push({ name: 'transaction-detail', params: { id: t.id } })
}

onMounted(() => {
  loadToday()
  checkWeeklyReport()
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
        <div class="amount">¥{{ todayTotal.toFixed(2) }}</div>
      </div>
      <div v-if="!transactions.length" class="empty-state">
        <div class="icon">🧾</div>
        <div class="title">今天还没有账单</div>
        <div class="subtitle">点击下方按钮开始记一笔吧</div>
      </div>
      <div v-else>
        <div
          v-for="t in transactions"
          :key="t.id"
          class="tx-item"
          @click="goDetail(t)"
        >
          <div
            class="tx-icon"
            :style="{ background: CATEGORY_COLORS[t.category] + '20', color: CATEGORY_COLORS[t.category] }"
          >{{ t.category }}</div>
          <div class="tx-info">
            <div class="tx-desc">{{ t.description }}</div>
            <div class="tx-meta">{{ t.category }} · {{ t.date }}</div>
          </div>
          <div class="tx-amount">¥{{ t.amount.toFixed(2) }}</div>
        </div>
      </div>
    </div>
    <button class="btn btn-primary btn-fab" @click="router.push('/add')">
      <span>+</span> 记一笔
    </button>
  </div>
</template>
