<script setup lang="ts">
import { ref, watch } from 'vue'
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

watch(keyword, () => doSearch())
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
      <button v-if="hasFilter" class="back-btn" @click="resetAll" style="font-size:14px">重置</button>
    </div>
    <div class="chip-row">
      <CategoryPicker v-model="selectedCategories" :multiple="true" @update:model-value="doSearch" />
    </div>
    <div class="filter-row">
      <button class="filter-btn" @click="pickDateRange">
        📅 {{ startDate && endDate ? `${startDate} ~ ${endDate}` : '日期' }}
      </button>
      <button class="filter-btn" @click="pickAmountRange">
        💰 {{ minAmount != null || maxAmount != null ? `${minAmount ?? 0}~${maxAmount ?? '∞'}` : '金额' }}
      </button>
    </div>
    <div class="separator"></div>
    <div class="page-content" style="padding-top:8px">
      <EmptyState
        v-if="!results.length"
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
