import { useRouter } from 'vue-router'
import type { Transaction } from '../models/transaction'

export function useTransactionNavigation() {
  const router = useRouter()

  function goDetail(t: Transaction) {
    router.push({ name: 'transaction-detail', params: { id: t.id } })
  }

  return { goDetail }
}
