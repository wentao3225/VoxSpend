<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { Transaction } from '../models/transaction'
import { addTransactions } from '../db'
import { validateTransaction } from '../utils/validation'
import { formatCurrency } from '../utils/format'
import { useAsyncAction } from '../composables/useAsyncAction'
import PageHeader from '../components/PageHeader.vue'
import CategoryPicker from '../components/CategoryPicker.vue'
import LoadingButton from '../components/LoadingButton.vue'

const router = useRouter()
const items = ref<Transaction[]>([])
const { loading: saving, execute } = useAsyncAction()

onMounted(() => {
  const raw = sessionStorage.getItem('pending_txs')
  if (raw) {
    const parsed = JSON.parse(raw)
    console.log('[ConfirmPage] Parsed items:', parsed)
    // 确保是纯对象数组，移除可能的不可克隆属性
    items.value = parsed.map((item: any) => ({
      description: String(item.description ?? ''),
      amount: Number(item.amount ?? 0),
      category: String(item.category ?? '其他'),
      date: String(item.date ?? ''),
      createdAt: Number(item.createdAt ?? Date.now()),
    }))
    console.log('[ConfirmPage] Cleaned items:', items.value)
  } else {
    router.replace('/add')
  }
})

async function save() {
  for (let i = 0; i < items.value.length; i++) {
    const err = validateTransaction(items.value[i])
    if (err) {
      alert(`第 ${i + 1} 条记录: ${err}`)
      return
    }
  }
  await execute(async () => {
    await addTransactions(items.value)
    sessionStorage.removeItem('pending_txs')
    router.replace('/')
  })
}

function updateDesc(i: number, val: string) {
  items.value[i].description = val
}

function updateAmount(i: number, val: string) {
  const num = parseFloat(val)
  if (!isNaN(num)) items.value[i].amount = num
}

const showPicker = ref(-1)
</script>

<template>
  <div class="page">
    <PageHeader title="确认账单" />
    <div class="page-content" style="padding-bottom:80px">
      <div v-for="(item, i) in items" :key="i" class="confirm-card">
        <div style="margin-bottom:8px">
          <span
            class="category-badge"
            :style="{ background: `var(--primary)`, color: 'white', cursor:'pointer' }"
            @click="showPicker = showPicker === i ? -1 : i"
          >{{ item.category }} ▾</span>
          <CategoryPicker
            v-if="showPicker === i"
            :model-value="item.category"
            @update:model-value="(v) => { items[i].category = v as string; showPicker = -1 }"
          />
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
      <LoadingButton :loading="saving" :text="`保存 ${items.length} 条记录`" style="margin-top:12px" @click="save" />
    </div>
  </div>
</template>
