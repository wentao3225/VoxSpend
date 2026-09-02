<template>
  <div class="tx-item" @click="$emit('click')">
    <div class="tx-icon" :style="iconStyle">{{ icon }}</div>
    <div class="tx-info">
      <div class="tx-desc">{{ description }}</div>
      <div class="tx-meta">{{ meta }}</div>
    </div>
    <div class="tx-amount" :class="{ 'tx-income': amount > 0 }">
      {{ formatCurrency(amount) }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { formatCurrency } from '../utils/format'
import { getCategoryStyle } from '../utils/style'

const props = defineProps<{
  category: string
  icon: string
  description: string
  meta: string
  amount: number
}>()

defineEmits<{ click: [] }>()

const iconStyle = computed(() => getCategoryStyle(props.category))
</script>

<style scoped>
.tx-item {
  display: flex;
  align-items: center;
  padding: 14px 16px;
  gap: 12px;
  background: var(--bg-card);
  border-bottom: 0.5px solid var(--separator);
}
.tx-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
}
.tx-info {
  flex: 1;
  min-width: 0;
}
.tx-desc {
  font-size: 17px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.tx-meta {
  font-size: 13px;
  color: var(--label-secondary);
  margin-top: 2px;
}
.tx-amount {
  font-size: 17px;
  font-weight: 600;
  flex-shrink: 0;
}
.tx-income {
  color: var(--system-green);
}
</style>
