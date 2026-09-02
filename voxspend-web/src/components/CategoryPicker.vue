<template>
  <div class="chip-wrap">
    <span
      v-for="c in categories"
      :key="c"
      class="chip"
      :style="getCategoryStyle(c, isSelected(c))"
      @click="toggle(c)"
    >{{ c }}</span>
  </div>
</template>

<script setup lang="ts">
import { CATEGORIES } from '../models/transaction'
import { getCategoryStyle } from '../utils/style'

const props = defineProps<{
  modelValue: string | string[]
  multiple?: boolean
}>()

const emit = defineEmits<{ 'update:modelValue': [value: string | string[]] }>()

const categories = CATEGORIES

function isSelected(c: string) {
  if (props.multiple) return (props.modelValue as string[]).includes(c)
  return props.modelValue === c
}

function toggle(c: string) {
  if (props.multiple) {
    const arr = [...(props.modelValue as string[])]
    const idx = arr.indexOf(c)
    if (idx >= 0) arr.splice(idx, 1)
    else arr.push(c)
    emit('update:modelValue', arr)
  } else {
    emit('update:modelValue', c)
  }
}
</script>

<style scoped>
.chip-wrap {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  padding: 8px;
}
.chip {
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 15px;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
  user-select: none;
}
</style>
