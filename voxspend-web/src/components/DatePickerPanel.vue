<script setup lang="ts">
// 内嵌日期选择面板：真实的 <input type="date"> 在 DOM 中，
// 点击可可靠唤起原生日历（脱离 DOM 的 input.click() 无法唤起选择器）。
// 选择日期后立即应用并收起面板。
defineProps<{
  visible: boolean
  modelValue: string // YYYY-MM-DD
  min?: string
  max?: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
  'update:visible': [value: boolean]
}>()

function onChange(e: Event) {
  const v = (e.target as HTMLInputElement).value
  if (v) {
    emit('update:modelValue', v)
    emit('update:visible', false)
  }
}
</script>

<template>
  <div v-if="visible" class="date-picker-panel">
    <input
      :value="modelValue"
      class="filter-date-input"
      type="date"
      :min="min"
      :max="max"
      @change="onChange"
    />
    <button class="date-picker-cancel" @click="$emit('update:visible', false)">取消</button>
  </div>
</template>
