<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { WeeklyReport } from '../models/weekly-report'
import { getAllWeeklyReports } from '../db'

const router = useRouter()
const reports = ref<WeeklyReport[]>([])

onMounted(async () => {
  reports.value = await getAllWeeklyReports()
})

function viewReport(r: WeeklyReport) {
  router.push({ name: 'weekly-report', query: { data: JSON.stringify(r) } })
}
</script>

<template>
  <div class="page">
    <div class="page-header">
      <button class="back-btn" @click="router.back()">← 返回</button>
      <h1>历史周报</h1>
      <div style="width:50px"></div>
    </div>
    <div class="page-content">
      <div v-if="!reports.length" class="empty-state">
        <div class="icon">📊</div>
        <div class="title">暂无周报</div>
        <div class="subtitle">每周一自动生成上周消费周报</div>
      </div>
      <div v-else>
        <div
          v-for="r in reports"
          :key="r.id"
          class="tx-item"
          @click="viewReport(r)"
        >
          <div class="tx-icon" style="background:rgba(0,122,255,0.12); color:var(--primary)">📊</div>
          <div class="tx-info">
            <div class="tx-desc">{{ r.weekStartDate }} ~ {{ r.weekEndDate }}</div>
            <div class="tx-meta">{{ r.aiSummary.slice(0, 30) }}...</div>
          </div>
          <div class="tx-amount">¥{{ r.totalExpense.toFixed(2) }}</div>
        </div>
      </div>
    </div>
  </div>
</template>
