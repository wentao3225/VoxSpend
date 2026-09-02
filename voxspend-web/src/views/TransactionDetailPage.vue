<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import type { Transaction } from '../models/transaction'
import { CATEGORIES, CATEGORY_COLORS } from '../models/transaction'
import { getAllTransactions, updateTransaction, deleteTransaction } from '../db'

const router = useRouter()
const route = useRoute()
const current = ref<Transaction | null>(null)
const editing = ref(false)
const desc = ref('')
const amountStr = ref('')
const pendingCategory = ref('')
const pendingDate = ref('')
const saving = ref(false)

onMounted(async () => {
  const id = Number(route.params.id)
  const all = await getAllTransactions()
  const found = all.find(t => t.id === id)
  if (!found) { router.back(); return }
  current.value = found
  desc.value = found.description
  amountStr.value = found.amount.toString()
  pendingCategory.value = found.category
  pendingDate.value = found.date
})

function toggleEdit() {
  if (editing.value && current.value) {
    desc.value = current.value.description
    amountStr.value = current.value.amount.toString()
    pendingCategory.value = current.value.category
    pendingDate.value = current.value.date
  }
  editing.value = !editing.value
}

async function save() {
  if (!current.value) return
  if (!desc.value.trim()) { alert('请填写消费内容'); return }
  const amount = parseFloat(amountStr.value)
  if (!amount || amount <= 0) { alert('金额无效'); return }
  saving.value = true
  await updateTransaction({
    ...current.value,
    description: desc.value.trim(),
    amount,
    category: pendingCategory.value,
    date: pendingDate.value,
  })
  saving.value = false
  editing.value = false
  current.value = {
    ...current.value,
    description: desc.value.trim(),
    amount,
    category: pendingCategory.value,
    date: pendingDate.value,
  }
}

async function doDelete() {
  if (!current.value?.id) return
  if (!confirm('确定要删除这条账单吗？删除后无法恢复。')) return
  await deleteTransaction(current.value.id)
  router.back()
}

function pickDate() {
  const el = document.createElement('input')
  el.type = 'date'
  el.value = pendingDate.value
  el.max = new Date().toISOString().split('T')[0]
  el.onchange = () => { if (el.value) pendingDate.value = el.value }
  el.click()
}
</script>

<template>
  <div class="page" v-if="current">
    <div class="page-header">
      <button class="back-btn" @click="router.back()">← 返回</button>
      <h1>{{ editing ? '编辑账单' : '账单详情' }}</h1>
      <button v-if="editing" class="back-btn" @click="save" style="font-weight:600">
        {{ saving ? '...' : '完成' }}
      </button>
      <button v-else class="back-btn" @click="toggleEdit" style="font-weight:600">编辑</button>
    </div>
    <div class="page-content">
      <div class="detail-amount-card">
        <div class="detail-amount">¥{{ current.amount.toFixed(2) }}</div>
        <div style="margin-top:8px">
          <span
            class="category-badge"
            :style="{ background: CATEGORY_COLORS[pendingCategory] + '20', color: CATEGORY_COLORS[pendingCategory] }"
          >{{ pendingCategory }}</span>
        </div>
      </div>
      <div class="card">
        <div class="detail-field">
          <span class="field-icon">📝</span>
          <span class="field-label">描述</span>
          <div class="field-value">
            <input v-if="editing" v-model="desc" />
            <span v-else>{{ current.description }}</span>
          </div>
        </div>
        <div class="detail-field">
          <span class="field-icon">💰</span>
          <span class="field-label">金额</span>
          <div class="field-value">
            <input v-if="editing" v-model="amountStr" type="number" step="0.01" />
            <span v-else>¥{{ current.amount.toFixed(2) }}</span>
          </div>
        </div>
        <div class="detail-field">
          <span class="field-icon">🏷️</span>
          <span class="field-label">类别</span>
          <div class="field-value" style="cursor:pointer" @click="editing && (pendingCategory = pendingCategory)">
            {{ pendingCategory }}
            <span v-if="editing" style="color:#C7C7CC; margin-left:4px">›</span>
          </div>
        </div>
        <div class="detail-field" style="border-bottom:none" @click="editing && pickDate()">
          <span class="field-icon">📅</span>
          <span class="field-label">日期</span>
          <div class="field-value">
            {{ pendingDate }}
            <span v-if="editing" style="color:#C7C7CC; margin-left:4px">›</span>
          </div>
        </div>
      </div>
      <div v-if="editing" class="card" style="margin-top:12px; padding:8px">
        <div style="display:flex; flex-wrap:wrap; gap:6px; padding:8px">
          <span
            v-for="c in CATEGORIES"
            :key="c"
            class="chip"
            :style="{
              background: pendingCategory === c ? CATEGORY_COLORS[c] : CATEGORY_COLORS[c] + '20',
              color: pendingCategory === c ? 'white' : CATEGORY_COLORS[c],
            }"
            @click="pendingCategory = c"
          >{{ c }}</span>
        </div>
      </div>
      <button v-if="!editing" class="btn btn-danger" style="margin-top:16px" @click="doDelete">
        删除账单
      </button>
    </div>
  </div>
</template>
