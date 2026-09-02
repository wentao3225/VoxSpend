<template>
  <div class="page-header">
    <div class="left">
      <button v-if="showBack" class="back-btn" @click="goBack">← 返回</button>
      <slot name="left" />
    </div>
    <h1>{{ title }}</h1>
    <div class="right">
      <slot name="right" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

defineProps<{
  title: string
  showBack?: boolean
}>()

const router = useRouter()
function goBack() {
  router.back()
}
</script>

<style scoped>
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: var(--bg-secondary);
  border-bottom: 0.5px solid var(--separator);
  position: sticky;
  top: 0;
  z-index: 100;
}
.left, .right {
  width: 60px;
  display: flex;
  align-items: center;
}
.right {
  justify-content: flex-end;
}
h1 {
  font-size: 17px;
  font-weight: 600;
  text-align: center;
  flex: 1;
  margin: 0;
}
.back-btn {
  background: none;
  border: none;
  color: var(--primary);
  font-size: 17px;
  padding: 0;
}
</style>
