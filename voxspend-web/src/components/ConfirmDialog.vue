<template>
  <div v-if="visible" class="dialog-overlay" @click.self="onCancel">
    <div class="dialog">
      <div class="dialog-title">{{ title }}</div>
      <div class="dialog-body">{{ message }}</div>
      <div class="dialog-actions">
        <button @click="onCancel">{{ cancelText }}</button>
        <button
          class="bold"
          :class="{ destructive }"
          @click="onConfirm"
        >{{ confirmText }}</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{
  visible: boolean
  title?: string
  message?: string
  confirmText?: string
  cancelText?: string
  destructive?: boolean
}>(), {
  title: '确认',
  message: '',
  confirmText: '确定',
  cancelText: '取消',
  destructive: true,
})

const emit = defineEmits<{
  (e: 'update:visible', value: boolean): void
  (e: 'confirm'): void
  (e: 'cancel'): void
}>()

function onCancel() {
  emit('update:visible', false)
  emit('cancel')
}

function onConfirm() {
  emit('update:visible', false)
  emit('confirm')
}
</script>