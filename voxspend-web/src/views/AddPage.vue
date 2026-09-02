<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { normalizeDate } from '../models/transaction'
import { loadAIConfig } from '../db'
import { parseTransactions } from '../services/ai-service'

const router = useRouter()
const input = ref('')
const selectedDate = ref(new Date())
const parsing = ref(false)
const errorMsg = ref('')

function formatDate(d: Date) {
  const today = new Date()
  const isToday = normalizeDate(d) === normalizeDate(today)
  const yesterday = new Date(today)
  yesterday.setDate(today.getDate() - 1)
  const isYesterday = normalizeDate(d) === normalizeDate(yesterday)
  const base = normalizeDate(d)
  if (isToday) return `今天 (${base})`
  if (isYesterday) return `昨天 (${base})`
  return base
}

function pickDate() {
  // simple date input
  const el = document.createElement('input')
  el.type = 'date'
  el.value = normalizeDate(selectedDate.value)
  el.max = normalizeDate(new Date())
  el.onchange = () => {
    if (el.value) selectedDate.value = new Date(el.value + 'T00:00:00')
  }
  el.click()
}

async function doParse() {
  if (!input.value.trim()) {
    errorMsg.value = '请输入记账描述'
    return
  }
  const config = loadAIConfig()
  if (!config?.apiKey) {
    errorMsg.value = '请先在「我的」页面配置 AI 服务'
    return
  }
  parsing.value = true
  errorMsg.value = ''
  try {
    const txs = await parseTransactions(input.value.trim(), selectedDate.value, config)
    // store in sessionStorage for confirm page
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
    <div class="page-header">
      <button class="back-btn" @click="router.back()">← 返回</button>
      <h1>记一笔</h1>
      <div style="width:50px"></div>
    </div>
    <div class="page-content">
      <div class="card" style="padding:14px 16px; margin-bottom:16px; cursor:pointer" @click="pickDate">
        <div style="display:flex; align-items:center; gap:10px">
          <span style="color:var(--primary)">📅</span>
          <span>记账日期</span>
          <span style="flex:1"></span>
          <span style="color:var(--text-secondary); font-size:14px">{{ formatDate(selectedDate) }}</span>
          <span style="color:#C7C7CC">›</span>
        </div>
      </div>
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
      <button class="btn btn-primary" :disabled="parsing" @click="doParse">
        <span v-if="parsing" class="spinner"></span>
        <span v-else>解 析</span>
      </button>
    </div>
  </div>
</template>
