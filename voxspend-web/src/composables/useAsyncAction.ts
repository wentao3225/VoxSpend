import { ref } from 'vue'

export function useAsyncAction() {
  const loading = ref(false)

  async function execute(action: () => Promise<void>) {
    loading.value = true
    try {
      await action()
    } finally {
      loading.value = false
    }
  }

  return { loading, execute }
}
