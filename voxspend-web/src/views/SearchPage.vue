<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import type { Transaction } from '../models/transaction'
import { CATEGORIES, CATEGORY_COLORS } from '../models/transaction'
import { searchTransactions } from '../db'

const router = useRouter()
const keyword = ref('')
const selectedCategories = ref<string[]>([])
const startDate = ref('')
const endDate = ref('')
const minAmount = ref<number | null>(null)
const maxAmount = ref<number | null>(null)
const results = ref<Transaction[]>([])
const hasFilter = ref(false)

let debounceTimer: any = null

function doSearch() {
  hasFilter.value = !!keyword.value || selectedCategories.value.length > 0 || startDate.value || endDate.value || minAmount.value != null || maxAmount.value != null
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(async () => {
    results.value = await searchTransactions({
      keyword: keyword.value || undefined,
      categories: selectedCategories.value.length ? selectedCategories.value : undefined,
      startDate: startDate.value || undefined,
      endDate: endDate.value || undefined,
      minAmount: minAmount.value ?? undefined,
      maxAmount: maxAmount.value ?? undefined,
    })
  }, 500)
}

function toggleCategory(c: string) {
  const idx = selectedCategories.value.indexOf(c)
  if (idx >= 0) selectedCategories.value.splice(idx, 1)
  else selectedCategories.value.push(c)
  doSearch()
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
}

function pickDateRange() {
  const s = document.createElement('input')
  s.type = 'date'
  if (startDate.value) s.value = startDate.value
  s.onchange = () => {
    if (s.value) {
      startDate.value = s.value
      const e = document.createElement('input')
      e.type = 'date'
      e.value = s.value
      e.min = s.value
      e.onchange = () => {
        if (e.value) {
          endDate.value = e.value
          doSearch()
        }
      }
      e.click()
    }
  }
  s.click()
}

function pickAmountRange() {
  const minStr = prompt('最小金额', minAmount.value?.toString() ?? '')
  const maxStr = prompt('最大金额', maxAmount.value?.toString() ?? '')
  minAmount.value = minStr ? parseFloat(minStr) : null
  maxAmount.value = maxStr ? parseFloat(maxStr) : null
  doSearch()
}

function goDetail(t: Transaction) {
  router.push({ name: 'transaction-detail', params: { id: t.id } })
}

watch(keyword, () => doSearch())
</script>

<template>
  <div class="page">
    <div class="page-header">
      <button class="back-btn" @click="router.back()">← 返回</button>
      <h1>搜索账单</h1>
      <div style="width:50px"></div>
    </div>
    <div class="search-bar">
      <input
        v-model="keyword"
        class="search-input"
        placeholder="搜索消费描述"
      />
      <button v-if="hasFilter" class="back-btn" @click="resetAll" style="font-size:14px">重置</button>
    </div>
    <div class="chip-row">
      <span
        v-for="c in CATEGORIES"
        :key="c"
        class="chip"
        :style="{
          background: selectedCategories.includes(c) ? CATEGORY_COLORS[c] : CATEGORY_COLORS[c] + '20',
          color: selectedCategories.includes(c) ? 'white' : CATEGORY_COLORS[c],
        }"
        @click="toggleCategory(c)"
      >{{ c }}</span>
    </div>
    <div class="filter-row">
      <button class="filter-btn" @click="pickDateRange">
        📅 {{ startDate && endDate ? `${startDate} ~ ${endDate}` : '日期' }}
      </button>
      <button class="filter-btn" @click="pickAmountRange">
        💰 {{ minAmount != null || maxAmount != null ? `${minAmount ?? 0}~${maxAmount ?? '∞'}` : '金额' }}
      </button>
    </div>
    <div style="height:0.5px; background:var(--separator); margin:0 16px"></div>
    <div class="page-content" style="padding-top:8px">
      <div v-if="!results.length" class="empty-state">
        <div class="icon">🔍</div>
        <div class="title">未找到相关账单</div>
        <div class="subtitle">试试其他关键词或筛选条件</div>
      </div>
      <div v-else>
        <div v-for="t in results" :key="t.id" class="tx-item" @click="goDetail(t)">
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
  </div>
</template>
