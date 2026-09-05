<script setup lang="ts">
import { ref, watch, onActivated } from 'vue'
import type { Transaction } from '../models/transaction'
import { searchTransactions } from '../db'
import { useTransactionNavigation } from '../composables/useTransactionNavigation'
import PageHeader from '../components/PageHeader.vue'
import TransactionItem from '../components/TransactionItem.vue'
import EmptyState from '../components/EmptyState.vue'
import CategoryPicker from '../components/CategoryPicker.vue'

const { goDetail } = useTransactionNavigation()
const keyword = ref('')
const selectedCategories = ref<string[]>([])
const startDate = ref('')
const endDate = ref('')
const minAmount = ref<number | null>(null)
const maxAmount = ref<number | null>(null)
const results = ref<Transaction[]>([])
const hasFilter = ref(false)
const searching = ref(false)

// 筛选面板：'date' | 'amount' | null
const activePanel = ref<null | 'date' | 'amount'>(null)
// 面板内的临时编辑值，点确定才应用
const draftStart = ref('')
const draftEnd = ref('')
const draftMin = ref('')
const draftMax = ref('')

let debounceTimer: any = null

function doSearch() {
  hasFilter.value = Boolean(keyword.value) || selectedCategories.value.length > 0 || Boolean(startDate.value) || Boolean(endDate.value) || minAmount.value != null || maxAmount.value != null
  clearTimeout(debounceTimer)
  searching.value = true
  debounceTimer = setTimeout(async () => {
    try {
      results.value = await searchTransactions({
        keyword: keyword.value || undefined,
        categories: selectedCategories.value.length ? selectedCategories.value : undefined,
        startDate: startDate.value || undefined,
        endDate: endDate.value || undefined,
        minAmount: minAmount.value ?? undefined,
        maxAmount: maxAmount.value ?? undefined,
      })
    } finally {
      searching.value = false
    }
  }, 500)
}

function resetAll() {
  keyword.value = ''
  selectedCategories.value = []
  startDate.value = ''
  endDate.value = ''
  minAmount.value = null
  maxAmount.value = null
  results.value = []
  hasFilter.value = false
  searching.value = false
  activePanel.value = null
  clearTimeout(debounceTimer)
}

function togglePanel(panel: 'date' | 'amount') {
  if (activePanel.value === panel) {
    activePanel.value = null
    return
  }
  activePanel.value = panel
  // 打开面板时把当前已应用的值填入草稿
  draftStart.value = startDate.value
  draftEnd.value = endDate.value
  draftMin.value = minAmount.value?.toString() ?? ''
  draftMax.value = maxAmount.value?.toString() ?? ''
}

function applyDate() {
  // 只填了结束日期时，自动把开始日期设为同一天（单日查询）
  if (!draftStart.value && draftEnd.value) draftStart.value = draftEnd.value
  if (draftStart.value && draftEnd.value && draftStart.value > draftEnd.value) {
    // 起止颠倒时自动交换
    startDate.value = draftEnd.value
    endDate.value = draftStart.value
  } else {
    startDate.value = draftStart.value
    endDate.value = draftEnd.value
  }
  activePanel.value = null
  doSearch()
}

function clearDate() {
  draftStart.value = ''
  draftEnd.value = ''
  startDate.value = ''
  endDate.value = ''
  doSearch()
}

function applyAmount() {
  // type=number 的 input 在某些情况下 v-model 可能拿到 number，统一转字符串处理
  const minStr = draftMin.value == null ? '' : String(draftMin.value).trim()
  const maxStr = draftMax.value == null ? '' : String(draftMax.value).trim()
  const min = minStr === '' ? null : parseFloat(minStr)
  const max = maxStr === '' ? null : parseFloat(maxStr)
  if (minStr !== '' && (min == null || isNaN(min) || min < 0)) {
    alert('最小金额无效')
    return
  }
  if (maxStr !== '' && (max == null || isNaN(max) || max < 0)) {
    alert('最大金额无效')
    return
  }
  if (min != null && max != null && min > max) {
    alert('最小金额不能大于最大金额')
    return
  }
  minAmount.value = min
  maxAmount.value = max
  activePanel.value = null
  doSearch()
}

function clearAmount() {
  draftMin.value = ''
  draftMax.value = ''
  minAmount.value = null
  maxAmount.value = null
  doSearch()
}

watch(keyword, () => doSearch())

// keep-alive 缓存实例：从详情页返回时账单可能已被删除/编辑，重跑搜索刷新结果
onActivated(() => {
  if (hasFilter.value || keyword.value) doSearch()
})
</script>

<template>
  <div class="page">
    <PageHeader title="搜索账单" :show-back="true" />
    <div class="search-bar">
      <input
        v-model="keyword"
        class="search-input"
        placeholder="搜索消费描述"
      />
      <span v-if="searching" class="search-spinner"></span>
      <button v-if="hasFilter" class="filter-btn reset-btn" @click="resetAll">重置</button>
    </div>
    <div class="chip-row">
      <CategoryPicker v-model="selectedCategories" :multiple="true" @update:model-value="doSearch" />
    </div>
    <div class="filter-row">
      <button
        :class="['filter-btn', { 'filter-btn-active': startDate || endDate }]"
        @click="togglePanel('date')"
      >
        📅 {{ startDate && endDate ? `${startDate} ~ ${endDate}` : startDate || endDate || '日期' }}
      </button>
      <button
        :class="['filter-btn', { 'filter-btn-active': minAmount != null || maxAmount != null }]"
        @click="togglePanel('amount')"
      >
        💰 {{ minAmount != null || maxAmount != null ? `${minAmount ?? 0}~${maxAmount ?? '∞'}` : '金额' }}
      </button>
    </div>

    <!-- 日期范围面板 -->
    <div v-if="activePanel === 'date'" class="filter-panel">
      <div class="filter-panel-row">
        <label class="filter-label">开始</label>
        <input v-model="draftStart" class="filter-date-input" type="date" :max="draftEnd || undefined" />
      </div>
      <div class="filter-panel-row">
        <label class="filter-label">结束</label>
        <input v-model="draftEnd" class="filter-date-input" type="date" :min="draftStart || undefined" />
      </div>
      <div class="filter-panel-actions">
        <button class="filter-action-btn clear" @click="clearDate">清除</button>
        <button class="filter-action-btn apply" @click="applyDate">确定</button>
      </div>
    </div>

    <!-- 金额范围面板 -->
    <div v-if="activePanel === 'amount'" class="filter-panel">
      <div class="filter-panel-row">
        <label class="filter-label">最小</label>
        <input
          v-model="draftMin"
          class="filter-amount-input"
          type="number"
          inputmode="decimal"
          min="0"
          step="0.01"
          placeholder="0"
        />
      </div>
      <div class="filter-panel-row">
        <label class="filter-label">最大</label>
        <input
          v-model="draftMax"
          class="filter-amount-input"
          type="number"
          inputmode="decimal"
          min="0"
          step="0.01"
          placeholder="不限"
        />
      </div>
      <div class="filter-panel-actions">
        <button class="filter-action-btn clear" @click="clearAmount">清除</button>
        <button class="filter-action-btn apply" @click="applyAmount">确定</button>
      </div>
    </div>

    <div class="separator"></div>
    <div class="page-content" :class="{ 'searching-dim': searching && results.length > 0 }" style="padding-top:8px">
      <!-- 搜索中且无旧结果：居中 loading -->
      <div v-if="searching && !results.length" class="search-loading">
        <span class="search-spinner search-spinner-lg"></span>
        <span class="search-loading-text">搜索中…</span>
      </div>
      <!-- 非搜索中且无结果：空状态 -->
      <EmptyState
        v-else-if="!results.length"
        icon="🔍"
        title="未找到相关账单"
        subtitle="试试其他关键词或筛选条件"
      />
      <template v-else>
        <TransactionItem
          v-for="t in results"
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
  </div>
</template>
