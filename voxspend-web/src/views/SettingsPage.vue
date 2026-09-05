<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import type { ModelConfig, ModelKey } from '../models/ai-config'
import { REPORT_MODELS, PARSE_MODEL_NAME, loadModelConfig, saveModelConfig, getModelName } from '../models/ai-config'
import PageHeader from '../components/PageHeader.vue'

const router = useRouter()
const config = ref<ModelConfig>(loadModelConfig())
const showReportPicker = ref(false)

onMounted(() => {
  config.value = loadModelConfig()
})

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
      <!-- AI 模型 -->
      <div class="settings-section">
        <div class="settings-section-title">AI 模型</div>
        <div class="card">
          <div class="settings-item">
            <span class="icon">🔍</span>
            <span class="label">解析模型</span>
            <span class="value">{{ PARSE_MODEL_NAME }}</span>
            <span class="badge">固定</span>
          </div>
          <button class="settings-item" @click="showReportPicker = true">
            <span class="icon">📊</span>
            <span class="label">周报模型</span>
            <span class="value">{{ getModelName(config.reportModel) }}</span>
            <span class="arrow">›</span>
          </button>
        </div>
      </div>

      <!-- 消费周报 -->
      <div class="settings-section">
        <div class="settings-section-title">消费周报</div>
        <div class="card">
          <button class="settings-item" @click="router.push('/weekly-report-list')">
            <span class="icon">🗂️</span>
            <span class="label">历史周报</span>
            <span class="arrow">›</span>
          </button>
        </div>
      </div>

      <!-- 关于 -->
      <div class="settings-section">
        <div class="settings-section-title">关于</div>
        <div class="card">
          <div class="settings-item">
            <span class="icon">📱</span>
            <span class="label">应用名称</span>
            <span class="value">VoxSpend 记账</span>
          </div>
          <div class="settings-item">
            <span class="icon">🏷️</span>
            <span class="label">版本</span>
            <span class="value">1.0.0</span>
          </div>
        </div>
      </div>

      <p class="settings-footer">
        所有账单数据仅存储在本机，不上传任何服务器。
        AI 服务由商汤日日新提供，API Key 通过环境变量配置。
      </p>
    </div>

    <!-- Report Model Picker -->
    <div v-if="showReportPicker" class="modal-overlay" @click.self="showReportPicker = false">
      <div class="modal-content">
        <div class="modal-header">
          <span class="modal-title">选择周报模型</span>
          <button class="modal-close" @click="showReportPicker = false">✕</button>
        </div>
        <button
          v-for="m in REPORT_MODELS"
          :key="m.key"
          class="settings-item"
          @click="setReportModel(m.key)"
        >
          <span class="label">{{ m.name }}</span>
          <span v-if="config.reportModel === m.key" class="check">✓</span>
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.settings-footer {
  font-size: 12px;
  color: var(--text-secondary);
  line-height: 1.6;
  padding: 0 8px;
  margin-top: 4px;
}
.badge {
  font-size: 11px;
  color: var(--text-secondary);
  background: rgba(118, 118, 128, 0.12);
  padding: 2px 8px;
  border-radius: 8px;
  margin-right: 4px;
  flex-shrink: 0;
}
.check {
  color: var(--primary);
  font-size: 16px;
  font-weight: 600;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  padding: 0 4px;
}
.modal-title {
  font-weight: 600;
  font-size: 16px;
}
.modal-close {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  color: var(--text-secondary);
  padding: 4px;
}
</style>
