<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { ModelConfig, ModelKey } from '../models/ai-config'
import { PARSE_MODELS, REPORT_MODELS, loadModelConfig, saveModelConfig, getModelName } from '../models/ai-config'
import PageHeader from '../components/PageHeader.vue'

const router = useRouter()
const config = ref<ModelConfig>(loadModelConfig())
const showParsePicker = ref(false)
const showReportPicker = ref(false)

onMounted(() => {
  config.value = loadModelConfig()
})

function setParseModel(key: ModelKey) {
  config.value.parseModel = key
  saveModelConfig(config.value)
  showParsePicker.value = false
}

function setReportModel(key: ModelKey) {
  config.value.reportModel = key
  saveModelConfig(config.value)
  showReportPicker.value = false
}
</script>

<template>
  <div class="page">
    <PageHeader title="我的" />
    <div class="page-content">
      <!-- Model Config -->
      <div class="settings-section">
        <div class="settings-section-title">AI 模型配置</div>
        <div class="card">
          <button class="settings-item" @click="showParsePicker = true">
            <span class="icon">🔍</span>
            <span class="label">解析模型</span>
            <span class="value">{{ getModelName(config.parseModel) }}</span>
            <span class="arrow">›</span>
          </button>
          <button class="settings-item" @click="showReportPicker = true">
            <span class="icon">📊</span>
            <span class="label">周报模型</span>
            <span class="value">{{ getModelName(config.reportModel) }}</span>
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
        AI 服务由商汤日日新提供，API Key 通过环境变量配置。
      </p>
    </div>

    <!-- Parse Model Picker -->
    <div v-if="showParsePicker" class="modal-overlay" @click.self="showParsePicker = false">
      <div class="modal-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px">
          <span style="font-weight:600">选择解析模型</span>
          <button style="background:none; border:none; font-size:20px; cursor:pointer" @click="showParsePicker = false">✕</button>
        </div>
        <button
          v-for="m in PARSE_MODELS"
          :key="m.key"
          class="settings-item"
          @click="setParseModel(m.key)"
        >
          <span class="label">{{ m.name }}</span>
          <span v-if="config.parseModel === m.key" style="color:var(--primary)">✓</span>
        </button>
      </div>
    </div>

    <!-- Report Model Picker -->
    <div v-if="showReportPicker" class="modal-overlay" @click.self="showReportPicker = false">
      <div class="modal-content">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px">
          <span style="font-weight:600">选择周报模型</span>
          <button style="background:none; border:none; font-size:20px; cursor:pointer" @click="showReportPicker = false">✕</button>
        </div>
        <button
          v-for="m in REPORT_MODELS"
          :key="m.key"
          class="settings-item"
          @click="setReportModel(m.key)"
        >
          <span class="label">{{ m.name }}</span>
          <span v-if="config.reportModel === m.key" style="color:var(--primary)">✓</span>
        </button>
      </div>
    </div>
  </div>
</template>
