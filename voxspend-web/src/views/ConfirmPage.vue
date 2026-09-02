<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { Transaction } from '../models/transaction'
import { CATEGORIES, CATEGORY_COLORS } from '../models/transaction'
import { addTransactions } from '../db'

const router = useRouter()
const items = ref<Transaction[]>([])
const saving = ref(false)

onMounted(() => {
  const raw = sessionStorage.getItem('pending_txs')
  if (raw) {
    items.value = JSON.parse(raw)
  } else {
    router.replace('/add')
  }
})

async function save() {
  for (let i = 0; i < items.value.length; i++) {
    if (!items.value[i].description.trim()) {
      alert(`第 ${i + 1} 条记录缺少消费内容`)
      return
    }
    if (items.value[i].amount <= 0) {
      alert(`第 ${i + 1} 条记录金额无效`)
      return
    }
  }
  saving.value = true
  await addTransactions(items.value)
  saving.value = false
  sessionStorage.removeItem('pending_txs')
  router.replace('/')
}

function updateDesc(i: number, val: string) {
  items.value[i].description = val
}

function updateAmount(i: number, val: string) {
  const num = parseFloat(val)
  if (!isNaN(num)) items.value[i].amount = num
}

function setCategory(i: number, cat: string) {
  items.value[i].category = cat
  showPicker.value = -1
}

const showPicker = ref(-1)
</script>

<template>
  <div class="page">
    <div class="page-header">
      <h1>确认账单</h1>
    </div>
    <div class="page-content" style="padding-bottom:80px">
      <div v-for="(item, i) in items" :key="i" class="confirm-card">
        <div style="margin-bottom:8px">
          <span
            class="category-badge"
            :style="{ background: CATEGORY_COLORS[item.category] + '20', color: CATEGORY_COLORS[item.category], cursor:'pointer' }"
            @click="showPicker = showPicker === i ? -1 : i"
          >{{ item.category }} ▾</span>
          <div v-if="showPicker === i" style="display:flex; flex-wrap:wrap; gap:6px; margin-top:8px">
            <span
              v-for="c in CATEGORIES"
              :key="c"
              class="chip"
              :style="{
                background: item.category === c ? CATEGORY_COLORS[c] : CATEGORY_COLORS[c] + '20',
                color: item.category === c ? 'white' : CATEGORY_COLORS[c],
              }"
              @click="setCategory(i, c)"
            >{{ c }}</span>
          </div>
        </div>
        <input
          class="desc-input"
          :value="item.description"
          placeholder="消费内容"
          @input="updateDesc(i, ($event.target as HTMLInputElement).value)"
        />
        <div style="display:flex; align-items:center; gap:6px; margin-top:4px">
          <span style="font-size:18px; font-weight:600; color:var(--expense)">¥</span>
          <input
            class="amount-input"
            type="number"
            step="0.01"
            :value="item.amount"
            placeholder="金额"
            @input="updateAmount(i, ($event.target as HTMLInputElement).value)"
          />
        </div>
      </div>
      <button class="btn btn-primary" :disabled="saving" @click="save" style="margin-top:12px">
        <span v-if="saving" class="spinner"></span>
        <span v-else>保存 {{ items.length }} 条记录</span>
      </button>
    </div>
  </div>
</template>
