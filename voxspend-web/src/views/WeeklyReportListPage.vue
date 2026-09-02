<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { WeeklyReport } from '../models/weekly-report'
import { getAllWeeklyReports } from '../db'
import { formatCurrency } from '../utils/format'
import PageHeader from '../components/PageHeader.vue'
import EmptyState from '../components/EmptyState.vue'

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
    <PageHeader title="历史周报" :show-back="true" />
    <div class="page-content">
      <EmptyState
        v-if="!reports.length"
        icon="📊"
        title="暂无周报"
        subtitle="每周一自动生成上周消费周报"
      />
      <template v-else>
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
          <div class="tx-amount">{{ formatCurrency(r.totalExpense) }}</div>
        </div>
      </template>
    </div>
  </div>
</template>
