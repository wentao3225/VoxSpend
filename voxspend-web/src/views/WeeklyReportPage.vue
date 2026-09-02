<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import type { WeeklyReport } from '../models/weekly-report'
import { CATEGORY_COLORS } from '../models/transaction'

const route = useRoute()
const router = useRouter()

const report = computed<WeeklyReport | null>(() => {
  const data = route.query.data as string
  if (!data) return null
  try { return JSON.parse(data) } catch { return null }
})

const pieSections = computed(() => {
  if (!report.value) return []
  const breakdown = report.value.categoryBreakdown
  const total = report.value.totalExpense
  return Object.entries(breakdown).map(([cat, amount]) => ({
    category: cat,
    amount,
    percent: total > 0 ? (amount / total * 100).toFixed(0) : '0',
    color: CATEGORY_COLORS[cat] ?? '#8E8E93',
  }))
})
</script>

<template>
  <div v-if="report" class="page" style="background:rgba(0,0,0,0.4)">
    <div style="padding:8vh 16px 24px; display:flex; justify-content:center">
      <div style="background:var(--card); border-radius:20px; padding:20px; width:100%">
        <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:4px">
          <span style="display:flex; align-items:center; gap:8px; font-size:20px; font-weight:700">
            📊 消费周报
          </span>
          <button style="background:none; border:none; font-size:18px; cursor:pointer; color:var(--text-secondary)" @click="router.back()">✕</button>
        </div>
        <p style="font-size:13px; color:var(--text-secondary); margin-bottom:16px">
          {{ report.weekStartDate }} - {{ report.weekEndDate }}
        </p>
        <div style="background:var(--bg); border-radius:14px; padding:14px; font-size:14px; line-height:1.6; margin-bottom:20px">
          {{ report.aiSummary }}
        </div>
        <div class="pie-container">
          <div style="width:200px; height:200px; position:relative">
            <svg viewBox="0 0 100 100" style="width:100%; height:100%; transform:rotate(-90deg)">
              <circle
                v-for="(s, i) in pieSections"
                :key="s.category"
                cx="50" cy="50" r="35"
                fill="none"
                :stroke="s.color"
                stroke-width="26"
                :stroke-dasharray="`${(Number(s.percent) / 100) * 220} 220`"
                :stroke-dashoffset="pieSections.slice(0, i).reduce((sum, prev) => sum - (Number(prev.percent) / 100) * 220, 0)"
              />
            </svg>
          </div>
        </div>
        <div v-if="pieSections.length" class="pie-legend">
          <div v-for="s in pieSections" :key="s.category" class="legend-row">
            <span class="legend-dot" :style="{ background: s.color }"></span>
            <span class="legend-label">{{ s.category }}</span>
            <span class="legend-value">¥{{ s.amount.toFixed(2) }}（{{ s.percent }}%）</span>
          </div>
        </div>
        <p style="text-align:center; font-size:17px; font-weight:700; color:var(--expense); margin:16px 0">
          上周总支出 ¥{{ report.totalExpense.toFixed(2) }}
        </p>
        <button class="btn btn-primary" @click="router.back()">我知道了</button>
      </div>
    </div>
  </div>
</template>
