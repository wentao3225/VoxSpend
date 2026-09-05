<script setup lang="ts">
import { useRouter } from 'vue-router'
import PageHeader from '../components/PageHeader.vue'

const router = useRouter()
</script>

<template>
  <div class="page">
    <PageHeader title="我的" />
    <div class="page-content">
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
        AI 服务由 Agnes 提供，API Key 通过环境变量配置。
      </p>
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
</style>
