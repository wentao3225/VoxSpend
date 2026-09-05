<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import PageHeader from '../components/PageHeader.vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'
import { exportBackup, pickBackupFile, restoreBackup, type BackupData } from '../services/backup-service'

const router = useRouter()
const exporting = ref(false)
const importing = ref(false)
const toast = ref('')
let toastTimer: any = null

function showToast(msg: string) {
  toast.value = msg
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => { toast.value = '' }, 3000)
}

async function doExport() {
  if (exporting.value) return
  exporting.value = true
  try {
    const summary = await exportBackup()
    showToast(`已导出 ${summary}，请在分享面板选择保存位置`)
  } catch (e: any) {
    // 用户取消分享面板不算错误
    if (e?.message?.includes('cancel')) return
    showToast(e?.message || '导出失败，请重试')
  } finally {
    exporting.value = false
  }
}

// 导入两步走：先选文件预览数量，确认后再写库
const showImportDialog = ref(false)
const pendingImport = ref<BackupData | null>(null)

async function doPickImport() {
  if (importing.value) return
  importing.value = true
  try {
    pendingImport.value = await pickBackupFile()
    showImportDialog.value = true
  } catch (e: any) {
    if (e?.message?.includes('cancel') || e?.message?.includes('未选择')) return
    showToast(e?.message || '导入失败，请重试')
  } finally {
    importing.value = false
  }
}

async function confirmImport() {
  if (!pendingImport.value) return
  try {
    const { txCount, reportCount } = await restoreBackup(pendingImport.value)
    showToast(`已导入 ${txCount} 笔账单、${reportCount} 份周报`)
  } catch (e: any) {
    showToast(e?.message || '导入失败，请重试')
  } finally {
    pendingImport.value = null
  }
}
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

      <!-- 数据备份 -->
      <div class="settings-section">
        <div class="settings-section-title">数据备份</div>
        <div class="card">
          <button class="settings-item" :disabled="exporting" @click="doExport">
            <span class="icon">📤</span>
            <span class="label">导出数据</span>
            <span class="value">{{ exporting ? '导出中…' : '' }}</span>
            <span class="arrow">›</span>
          </button>
          <button class="settings-item" :disabled="importing" @click="doPickImport">
            <span class="icon">📥</span>
            <span class="label">导入数据</span>
            <span class="value">{{ importing ? '读取中…' : '' }}</span>
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
        换机或卸载前请先「导出数据」备份。
        AI 服务由 Agnes 提供，API Key 通过环境变量配置。
      </p>

      <div v-if="toast" class="backup-toast">{{ toast }}</div>
    </div>

    <!-- 导入确认 -->
    <ConfirmDialog
      v-model:visible="showImportDialog"
      title="导入数据"
      :message="`将导入 ${pendingImport?.transactions.length ?? 0} 笔账单、${pendingImport?.weeklyReports.length ?? 0} 份周报，与现有数据合并。确定继续吗？`"
      confirm-text="导入"
      @confirm="confirmImport"
    />
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
.backup-toast {
  position: fixed;
  left: 50%;
  bottom: 120px;
  transform: translateX(-50%);
  background: rgba(0, 0, 0, 0.75);
  color: #fff;
  font-size: 13px;
  padding: 10px 18px;
  border-radius: 20px;
  max-width: 80vw;
  text-align: center;
  z-index: 400;
}
</style>
