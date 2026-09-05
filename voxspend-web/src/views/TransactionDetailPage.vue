<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import type { Transaction } from '../models/transaction'
import { getAllTransactions, updateTransaction, deleteTransaction } from '../db'
import { formatCurrency } from '../utils/format'
import { normalizeDate } from '../models/transaction'
import { useAsyncAction } from '../composables/useAsyncAction'
import { getCategoryStyle } from '../utils/style'
import PageHeader from '../components/PageHeader.vue'
import CategoryPicker from '../components/CategoryPicker.vue'
import DatePickerPanel from '../components/DatePickerPanel.vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'

const router = useRouter()
const route = useRoute()
const { loading: saving, execute } = useAsyncAction()
const current = ref<Transaction | null>(null)
const editing = ref(false)
const desc = ref('')
const amountStr = ref('')
const pendingCategory = ref('')
const pendingDate = ref('')
const showDatePicker = ref(false)
const showDeleteDialog = ref(false)

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
  await execute(async () => {
    await updateTransaction({
      ...current.value!,
      description: desc.value.trim(),
      amount,
      category: pendingCategory.value,
      date: pendingDate.value,
    })
    editing.value = false
    current.value = {
      ...current.value!,
      description: desc.value.trim(),
      amount,
      category: pendingCategory.value,
      date: pendingDate.value,
    }
  })
}

async function doDelete() {
  if (!current.value?.id) return
  await deleteTransaction(current.value.id)
  router.back()
}

function openDatePicker() {
  showDatePicker.value = !showDatePicker.value
}

function onDatePicked(v: string) {
  pendingDate.value = v
}
</script>

<template>
  <div class="page" v-if="current">
    <PageHeader :title="editing ? '编辑账单' : '账单详情'" :show-back="true">
      <template #right>
        <button v-if="editing" class="back-btn" style="font-weight:600" @click="save">
          {{ saving ? '...' : '完成' }}
        </button>
        <button v-else class="back-btn" style="font-weight:600" @click="toggleEdit">编辑</button>
      </template>
    </PageHeader>
    <div class="page-content">
      <div class="detail-amount-card">
        <div class="detail-amount">{{ formatCurrency(current.amount) }}</div>
        <div style="margin-top:8px">
          <span
            class="category-badge"
            :style="getCategoryStyle(pendingCategory)"
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
            <span v-else>{{ formatCurrency(current.amount) }}</span>
          </div>
        </div>
        <div class="detail-field">
          <span class="field-icon">🏷️</span>
          <span class="field-label">类别</span>
          <div class="field-value" style="cursor:pointer">
            {{ pendingCategory }}
            <span v-if="editing" style="color:#C7C7CC; margin-left:4px">›</span>
          </div>
        </div>
        <div class="detail-field" style="border-bottom:none" @click="editing && openDatePicker()">
          <span class="field-icon">📅</span>
          <span class="field-label">日期</span>
          <div class="field-value">
            {{ pendingDate }}
            <span v-if="editing" style="color:#C7C7CC; margin-left:4px">›</span>
          </div>
        </div>
      </div>
      <DatePickerPanel
        v-if="editing"
        v-model:visible="showDatePicker"
        :model-value="pendingDate"
        :max="normalizeDate(new Date())"
        @update:model-value="onDatePicked"
      />
      <div v-if="editing" class="card" style="margin-top:12px; padding:8px">
        <CategoryPicker v-model="pendingCategory" />
      </div>
      <button v-if="!editing" class="btn btn-danger" style="margin-top:16px" @click="showDeleteDialog = true">
        删除账单
      </button>
    </div>

    <ConfirmDialog
      v-model:visible="showDeleteDialog"
      title="删除账单"
      message="确定要删除这条账单吗？删除后无法恢复。"
      confirm-text="删除"
      destructive
      @confirm="doDelete"
    />
  </div>
</template>
