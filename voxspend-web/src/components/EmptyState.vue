<template>
  <div class="empty-state">
    <div class="icon">{{ icon }}</div>
    <div class="title">{{ title }}</div>
    <div class="subtitle">{{ subtitle }}</div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  icon?: string
  title?: string
  subtitle?: string
}>()
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 40px;
  text-align: center;
}
.empty-state .icon {
  font-size: 48px;
  margin-bottom: 16px;
}
.empty-state .title {
  font-size: 18px;
  font-weight: 600;
  color: var(--label-primary);
  margin-bottom: 8px;
}
.empty-state .subtitle {
  font-size: 14px;
  color: var(--label-tertiary);
}
</style>
