<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAIConfig } from '../composables/useAIConfig'
import { parseTransactions } from '../services/ai-service'
import { formatDateDisplay } from '../utils/format'
import { normalizeDate } from '../models/transaction'
import PageHeader from '../components/PageHeader.vue'
import LoadingButton from '../components/LoadingButton.vue'
import DatePickerPanel from '../components/DatePickerPanel.vue'

const router = useRouter()
const { isReady } = useAIConfig()
const input = ref('')
const selectedDate = ref(new Date())
const showDatePicker = ref(false)
const parsing = ref(false)
const errorMsg = ref('')

function onDatePicked(v: string) {
  selectedDate.value = new Date(v + 'T00:00:00')
}

async function doParse() {
  if (!input.value.trim()) {
    errorMsg.value = '请输入记账描述'
    return
  }
  if (!isReady) {
    errorMsg.value = '请先在 .env 文件中配置 VITE_AI_API_KEY'
    return
  }
  parsing.value = true
  errorMsg.value = ''
  try {
    const txs = await parseTransactions(input.value.trim(), selectedDate.value)
    sessionStorage.setItem('pending_txs', JSON.stringify(txs))
    router.push('/confirm')
  } catch (e: any) {
    errorMsg.value = e.reason || '解析失败，请重试'
  } finally {
    parsing.value = false
  }
}
</script>

<template>
  <div class="page">
    <PageHeader title="记一笔" :show-back="true" />
    <div class="page-content">
      <div class="card" style="padding:14px 16px; margin-bottom:12px; cursor:pointer" @click="showDatePicker = !showDatePicker">
        <div style="display:flex; align-items:center; gap:10px">
          <span style="color:var(--primary)">📅</span>
          <span>记账日期</span>
          <span style="flex:1"></span>
          <span style="color:var(--text-secondary); font-size:14px">{{ formatDateDisplay(selectedDate) }}</span>
          <span style="color:#C7C7CC">›</span>
        </div>
      </div>
      <DatePickerPanel
        v-model:visible="showDatePicker"
        :model-value="normalizeDate(selectedDate)"
        :max="normalizeDate(new Date())"
        @update:model-value="onDatePicked"
      />
      <div class="card" style="padding:14px">
        <textarea
          v-model="input"
          class="input-field"
          rows="5"
          placeholder="用一句话描述你的消费，例如：&#10;买了个面包花了五块，买了包烟花了十元"
          maxlength="500"
        ></textarea>
      </div>
      <p style="text-align:center; color:var(--text-secondary); font-size:12px; margin:12px 0">
        支持多条混合输入，AI 自动识别每笔消费
      </p>
      <p v-if="errorMsg" style="color:var(--expense); font-size:14px; text-align:center; margin-bottom:8px">
        {{ errorMsg }}
      </p>
      <LoadingButton :loading="parsing" text="解 析" @click="doParse" />
    </div>
  </div>
</template>
