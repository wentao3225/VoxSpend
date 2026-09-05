<script setup lang="ts">
import { ref, computed, onMounted, onActivated } from 'vue'
import { useRouter } from 'vue-router'
import type { Transaction } from '../models/transaction'
import { normalizeDate } from '../models/transaction'
import { getTransactionsByDate, getWeeklyReport, saveWeeklyReport } from '../db'
import { generateAiSummary } from '../services/ai-service'
import { formatCurrency, formatDateDisplay } from '../utils/format'
import { useTransactionNavigation } from '../composables/useTransactionNavigation'
import TransactionItem from '../components/TransactionItem.vue'
import EmptyState from '../components/EmptyState.vue'

const router = useRouter()
const { goDetail } = useTransactionNavigation()
const transactions = ref<Transaction[]>([])
const todayTotal = ref(0)
// 当前查看的日期（YYYY-MM-DD），默认今天
const viewDate = ref(normalizeDate(new Date()))
// 今天（YYYY-MM-DD），用于限制不能切到未来
const todayStr = normalizeDate(new Date())
const isToday = computed(() => viewDate.value === todayStr)
const isFuture = computed(() => viewDate.value >= todayStr)

async function loadDay() {
  transactions.value = await getTransactionsByDate(viewDate.value)
  todayTotal.value = transactions.value.reduce((s, t) => s + t.amount, 0)
}

function shiftDay(delta: number) {
  // 不允许切到未来
  if (delta > 0 && isFuture.value) return
  const d = new Date(viewDate.value + 'T00:00:00')
  d.setDate(d.getDate() + delta)
  viewDate.value = normalizeDate(d)
  loadDay()
}

function goToday() {
  viewDate.value = todayStr
  loadDay()
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
    const aiSummary = await generateAiSummary(total, breakdown)
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
  loadDay()
  checkWeeklyReport()
})

// keep-alive 缓存下从确认页返回时 onMounted 不触发，用 onActivated 刷新当前查看日期的数据
onActivated(() => {
  loadDay()
})
</script>

<template>
  <div class="page">
    <div class="page-header">
      <h1>{{ isToday ? '今日账单' : '账单明细' }}</h1>
      <button class="back-btn" @click="router.push('/search')">🔍</button>
    </div>
    <div class="page-content">
      <div class="total-card">
        <div class="date-nav">
          <button
            class="date-nav-btn"
            aria-label="前一天"
            @click="shiftDay(-1)"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"/></svg>
          </button>
          <span class="date-nav-label">{{ formatDateDisplay(new Date(viewDate + 'T00:00:00')) }}</span>
          <button
            class="date-nav-btn"
            aria-label="后一天"
            :disabled="isFuture"
            @click="shiftDay(1)"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M9 6l6 6-6 6"/></svg>
          </button>
        </div>
        <div class="label">{{ isToday ? '今日支出' : '当日支出' }}</div>
        <div class="amount">{{ formatCurrency(todayTotal) }}</div>
      </div>
      <EmptyState
        v-if="!transactions.length"
        icon="🧾"
        :title="isToday ? '今天还没有账单' : '这一天没有账单'"
        :subtitle="isToday ? '点击下方按钮开始记一笔吧' : '试试切换其他日期'"
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
    <div class="fab-group">
      <button
        v-if="!isToday"
        class="fab-today"
        aria-label="回到今天"
        @click="goToday"
      >今</button>
      <button class="btn btn-primary btn-fab" @click="router.push('/add')">
        <span>+</span> 记一笔
      </button>
    </div>
  </div>
</template>

<style scoped>
.date-nav {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  margin-bottom: 10px;
}
.date-nav-btn {
  background: none;
  border: none;
  color: #fff;
  cursor: pointer;
  padding: 6px 14px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.date-nav-btn:active {
  background: rgba(255, 255, 255, 0.2);
}
.date-nav-btn:disabled {
  color: rgba(255, 255, 255, 0.35);
  cursor: default;
}
.date-nav-label {
  font-size: 14px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.95);
  min-width: 130px;
  text-align: center;
}
.fab-group {
  position: fixed;
  right: 20px;
  bottom: 90px;
  display: flex;
  align-items: center;
  gap: 10px;
  z-index: 50;
}
.fab-group .btn-fab {
  position: static;
  box-shadow: 0 4px 12px var(--primary-light);
}
.fab-today {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: none;
  background: var(--card);
  color: var(--primary);
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  flex-shrink: 0;
}
.fab-today:active {
  transform: scale(0.92);
}
</style>
