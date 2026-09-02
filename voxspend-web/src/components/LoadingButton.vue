<template>
  <button class="btn" :class="btnClass" :disabled="disabled || loading" @click="$emit('click')">
    <span v-if="loading" class="spinner"></span>
    <span v-else><slot>{{ text }}</slot></span>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  loading?: boolean
  disabled?: boolean
  text?: string
  variant?: 'primary' | 'secondary' | 'danger'
}>()

defineEmits<{ click: [] }>()

const btnClass = computed(() => `btn-${props.variant || 'primary'}`)
</script>
