import type { Transaction } from '../models/transaction'
import type { WeeklyReport } from '../models/weekly-report'

const DB_NAME = 'voxspend'
const DB_VERSION = 1
let dbInstance: IDBDatabase | null = null

function openDB(): Promise<IDBDatabase> {
  if (dbInstance) return Promise.resolve(dbInstance)
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION)
    req.onupgradeneeded = () => {
      const db = req.result
      if (!db.objectStoreNames.contains('transactions')) {
        const store = db.createObjectStore('transactions', { keyPath: 'id', autoIncrement: true })
        store.createIndex('date', 'date', { unique: false })
        store.createIndex('category', 'category', { unique: false })
        store.createIndex('createdAt', 'createdAt', { unique: false })
      }
      if (!db.objectStoreNames.contains('weeklyReports')) {
        const store = db.createObjectStore('weeklyReports', { keyPath: 'id', autoIncrement: true })
        store.createIndex('weekStartDate', 'weekStartDate', { unique: true })
      }
    }
    req.onsuccess = () => { dbInstance = req.result; resolve(req.result) }
    req.onerror = () => reject(req.error)
  })
}

// ==================== Transaction CRUD ====================

export async function getTransactionsByDate(dateStr: string): Promise<Transaction[]> {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('transactions', 'readonly')
    const idx = tx.objectStore('transactions').index('date')
    const req = idx.getAll(dateStr)
    req.onsuccess = () => {
      const list = req.result as Transaction[]
      list.sort((a, b) => b.createdAt - a.createdAt)
      resolve(list)
    }
    req.onerror = () => reject(req.error)
  })
}

export async function addTransactions(items: Transaction[]): Promise<Transaction[]> {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('transactions', 'readwrite')
    const store = tx.objectStore('transactions')
    const results: Transaction[] = []
    for (const item of items) {
      // 确保对象是纯数据对象，移除可能的不可克隆属性
      // 注意：添加新记录时不传 id，让 IndexedDB 自动生成
      const cleanItem = {
        description: String(item.description ?? ''),
        amount: Number(item.amount ?? 0),
        category: String(item.category ?? '其他'),
        date: String(item.date ?? ''),
        createdAt: Number(item.createdAt ?? Date.now()),
      }
      const req = store.add(cleanItem)
      req.onsuccess = () => { 
        const savedItem = { ...cleanItem, id: req.result as number }
        results.push(savedItem)
      }
    }
    tx.oncomplete = () => resolve(results)
    tx.onerror = () => reject(tx.error)
  })
}

export async function updateTransaction(item: Transaction): Promise<void> {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('transactions', 'readwrite')
    tx.objectStore('transactions').put(item)
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error)
  })
}

export async function deleteTransaction(id: number): Promise<void> {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('transactions', 'readwrite')
    tx.objectStore('transactions').delete(id)
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error)
  })
}

export async function getAllTransactions(): Promise<Transaction[]> {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const req = db.transaction('transactions', 'readonly').objectStore('transactions').getAll()
    req.onsuccess = () => {
      const list = req.result as Transaction[]
      list.sort((a, b) => b.createdAt - a.createdAt)
      resolve(list)
    }
    req.onerror = () => reject(req.error)
  })
}

export async function searchTransactions(opts: {
  keyword?: string
  categories?: string[]
  startDate?: string
  endDate?: string
  minAmount?: number
  maxAmount?: number
}): Promise<Transaction[]> {
  const all = await getAllTransactions()
  let result = all
  if (opts.keyword) {
    const kw = opts.keyword.trim()
    if (kw) result = result.filter(t => t.description.includes(kw))
  }
  if (opts.categories?.length) {
    result = result.filter(t => opts.categories!.includes(t.category))
  }
  if (opts.startDate) {
    result = result.filter(t => t.date >= opts.startDate!)
  }
  if (opts.endDate) {
    result = result.filter(t => t.date <= opts.endDate!)
  }
  if (opts.minAmount != null) {
    result = result.filter(t => t.amount >= opts.minAmount!)
  }
  if (opts.maxAmount != null) {
    result = result.filter(t => t.amount <= opts.maxAmount!)
  }
  return result
}

export async function getTransactionsBetween(start: string, end: string): Promise<Transaction[]> {
  const all = await getAllTransactions()
  return all.filter(t => t.date >= start && t.date <= end)
}

// ==================== WeeklyReport CRUD ====================

export async function getWeeklyReport(weekStartDate: string): Promise<WeeklyReport | null> {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const idx = db.transaction('weeklyReports', 'readonly').objectStore('weeklyReports').index('weekStartDate')
    const req = idx.get(weekStartDate)
    req.onsuccess = () => resolve(req.result ?? null)
    req.onerror = () => reject(req.error)
  })
}

export async function saveWeeklyReport(report: WeeklyReport): Promise<void> {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction('weeklyReports', 'readwrite')
    const store = tx.objectStore('weeklyReports')
    if (report.id) {
      store.put(report)
    } else {
      store.add(report)
    }
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error)
  })
}

export async function getAllWeeklyReports(): Promise<WeeklyReport[]> {
  const db = await openDB()
  return new Promise((resolve, reject) => {
    const req = db.transaction('weeklyReports', 'readonly').objectStore('weeklyReports').getAll()
    req.onsuccess = () => {
      const list = req.result as WeeklyReport[]
      list.sort((a, b) => b.weekStartDate.localeCompare(a.weekStartDate))
      resolve(list)
    }
    req.onerror = () => reject(req.error)
  })
}

// Settings (removed - API key via .env, model config in ai-config.ts)
