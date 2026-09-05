<script setup lang="ts">
import { ref, onMounted, onActivated } from 'vue'
import { useRouter } from 'vue-router'
import type { WeeklyReport } from '../models/weekly-report'
import { getAllWeeklyReports, deleteWeeklyReport } from '../db'
import { formatCurrency } from '../utils/format'
import PageHeader from '../components/PageHeader.vue'
import EmptyState from '../components/EmptyState.vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'

const router = useRouter()
const reports = ref<WeeklyReport[]>([])
const showDeleteDialog = ref(false)
const pendingDelete = ref<WeeklyReport | null>(null)

async function loadReports() {
  reports.value = await getAllWeeklyReports()
}

onMounted(loadReports)
// keep-alive 缓存实例：重新进入时刷新列表（周报可能已新增/删除）
onActivated(loadReports)

function viewReport(r: WeeklyReport) {
  router.push({ name: 'weekly-report', query: { data: JSON.stringify(r) } })
}

function askDelete(r: WeeklyReport) {
  pendingDelete.value = r
  showDeleteDialog.value = true
}

async function doDelete() {
  if (!pendingDelete.value?.id) return
  await deleteWeeklyReport(pendingDelete.value.id)
  reports.value = await getAllWeeklyReports()
  pendingDelete.value = null
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
          <button
            class="tx-delete"
            @click.stop="askDelete(r)"
            aria-label="删除周报"
          >🗑️</button>
        </div>
      </template>
    </div>

    <ConfirmDialog
      v-model:visible="showDeleteDialog"
      title="删除周报"
      :message="`确定要删除 ${pendingDelete?.weekStartDate} ~ ${pendingDelete?.weekEndDate} 的周报吗？删除后无法恢复。`"
      confirm-text="删除"
      destructive
      @confirm="doDelete"
    />
  </div>
</template>
