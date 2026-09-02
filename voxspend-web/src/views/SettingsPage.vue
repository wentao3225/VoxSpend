<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { AIConfig } from '../models/ai-config'
import { AI_PROVIDERS, getDefaultConfig, getProviderInfo } from '../models/ai-config'
import { loadAIConfig, saveAIConfig } from '../db'

const router = useRouter()
const config = ref<AIConfig>(getDefaultConfig())
const showProviderPicker = ref(false)
const editingField = ref<string | null>(null)
const editValue = ref('')

onMounted(() => {
  const saved = loadAIConfig()
  if (saved) config.value = saved
})

function maskKey(key: string) {
  if (key.length <= 8) return '****'
  return `${key.slice(0, 4)}****${key.slice(-4)}`
}

function changeProvider(p: string) {
  const info = getProviderInfo(p)
  config.value.provider = p
  config.value.modelName = info.defaultModel
  if (p !== 'custom') config.value.apiUrl = undefined
  save()
  showProviderPicker.value = false
}

function editField(field: string) {
  editingField.value = field
  editValue.value = (config.value as any)[field] ?? ''
}

function saveEdit() {
  if (editingField.value) {
    (config.value as any)[editingField.value] = editValue.value
    save()
  }
  editingField.value = null
}

function save() {
  saveAIConfig(config.value)
}
</script>

<template>
  <div class="page">
    <div class="page-header">
      <h1>我的</h1>
    </div>
    <div class="page-content">
      <!-- AI Config -->
      <div class="settings-section">
        <div class="settings-section-title">AI 服务配置</div>
        <div class="card">
          <button class="settings-item" @click="showProviderPicker = true">
            <span class="icon">✨</span>
            <span class="label">AI 平台</span>
            <span class="value">{{ getProviderInfo(config.provider).name }}</span>
            <span class="arrow">›</span>
          </button>
          <button class="settings-item" @click="editField('apiKey')">
            <span class="icon">🔒</span>
            <span class="label">API Key</span>
            <span class="value">{{ config.apiKey ? maskKey(config.apiKey) : '未设置' }}</span>
            <span class="arrow">›</span>
          </button>
          <button class="settings-item" @click="editField('modelName')">
            <span class="icon">📦</span>
            <span class="label">模型名称</span>
            <span class="value">{{ config.modelName || '未设置' }}</span>
            <span class="arrow">›</span>
          </button>
          <button v-if="config.provider === 'custom'" class="settings-item" @click="editField('apiUrl')">
            <span class="icon">🔗</span>
            <span class="label">API 地址</span>
            <span class="value">{{ config.apiUrl || '未设置' }}</span>
            <span class="arrow">›</span>
          </button>
        </div>
      </div>

      <!-- Weekly Report -->
      <div class="settings-section">
        <div class="settings-section-title">消费周报</div>
        <div class="card">
          <button class="settings-item" @click="router.push('/weekly-report-list')">
            <span class="icon">📊</span>
            <span class="label">历史周报</span>
            <span class="arrow">›</span>
          </button>
        </div>
      </div>

      <!-- About -->
      <div class="settings-section">
        <div class="settings-section-title">关于</div>
        <div class="card">
          <div class="settings-item">
            <span class="icon">ℹ️</span>
            <span class="label">应用名称</span>
            <span class="value">VoxSpend 记账</span>
          </div>
          <div class="settings-item">
            <span class="icon">#</span>
            <span class="label">版本</span>
            <span class="value">1.0.0</span>
          </div>
        </div>
      </div>

      <p style="font-size:12px; color:var(--text-secondary); line-height:1.6; padding:0 8px">
        所有账单数据仅存储在本机，不上传任何服务器。
        AI 解析与周报生成会将脱敏文本发送至你配置的 AI 服务。
      </p>
    </div>

    <!-- Provider Picker Modal -->
    <div v-if="showProviderPicker" class="modal-overlay" @click.self="showProviderPicker = false">
      <div class="modal-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px">
          <span style="font-weight:600">选择 AI 平台</span>
          <button style="background:none; border:none; font-size:20px; cursor:pointer" @click="showProviderPicker = false">✕</button>
        </div>
        <button
          v-for="p in AI_PROVIDERS"
          :key="p.key"
          class="settings-item"
          @click="changeProvider(p.key)"
        >
          <span class="label">{{ p.name }}</span>
          <span v-if="config.provider === p.key" style="color:var(--primary)">✓</span>
        </button>
      </div>
    </div>

    <!-- Edit Dialog -->
    <div v-if="editingField" class="dialog-overlay" @click.self="editingField = null">
      <div class="dialog">
        <div class="dialog-title">
          {{ editingField === 'apiKey' ? 'API Key' : editingField === 'modelName' ? '模型名称' : 'API 地址' }}
        </div>
        <div class="dialog-body">
          <input
            v-model="editValue"
            :type="editingField === 'apiKey' ? 'password' : 'text'"
            :placeholder="editingField === 'apiUrl' ? 'https://api.example.com/v1/chat/completions' : ''"
            style="width:100%; padding:8px; border:1px solid var(--separator); border-radius:8px; font-size:14px; outline:none"
            @keyup.enter="saveEdit"
          />
        </div>
        <div class="dialog-actions">
          <button @click="editingField = null">取消</button>
          <button class="bold" @click="saveEdit">保存</button>
        </div>
      </div>
    </div>
  </div>
</template>
