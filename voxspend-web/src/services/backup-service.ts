import { Capacitor } from '@capacitor/core'
import { Filesystem, Directory, Encoding } from '@capacitor/filesystem'
import { Share } from '@capacitor/share'
import { FilePicker } from '@capawesome/capacitor-file-picker'
import type { Transaction } from '../models/transaction'
import type { WeeklyReport } from '../models/weekly-report'
import { getAllTransactions, addTransactions, getAllWeeklyReports, saveWeeklyReport } from '../db'

const BACKUP_VERSION = 1
const BACKUP_FILENAME = `voxspend-backup-${new Date().toISOString().slice(0, 10)}.json`

export interface BackupData {
  version: number
  exportedAt: number
  transactions: Transaction[]
  weeklyReports: WeeklyReport[]
}

export async function buildBackupData(): Promise<BackupData> {
  const [transactions, weeklyReports] = await Promise.all([
    getAllTransactions(),
    getAllWeeklyReports(),
  ])
  return { version: BACKUP_VERSION, exportedAt: Date.now(), transactions, weeklyReports }
}

/** 导出备份：原生环境写文件 + 拉起系统分享；浏览器环境触发下载 */
export async function exportBackup(): Promise<string> {
  const data = await buildBackupData()
  if (!data.transactions.length && !data.weeklyReports.length) {
    throw new Error('没有可备份的数据')
  }
  const json = JSON.stringify(data, null, 2)

  if (Capacitor.isNativePlatform()) {
    // 先写入缓存目录，再通过系统分享面板发出去（微信/网盘/蓝牙等）
    const result = await Filesystem.writeFile({
      path: BACKUP_FILENAME,
      data: json,
      directory: Directory.Cache,
      encoding: Encoding.UTF8,
    })
    await Share.share({
      title: BACKUP_FILENAME,
      url: result.uri,
      dialogTitle: '分享备份文件',
    })
    return `${data.transactions.length} 笔账单、${data.weeklyReports.length} 份周报`
  }

  // 浏览器开发环境：Blob 下载
  const blob = new Blob([json], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = BACKUP_FILENAME
  a.click()
  URL.revokeObjectURL(url)
  return `${data.transactions.length} 笔账单、${data.weeklyReports.length} 份周报`
}

/** 导入备份：选择 JSON 文件，返回解析后的数据（不写库，由调用方确认后写入） */
export async function pickBackupFile(): Promise<BackupData> {
  let content: string

  if (Capacitor.isNativePlatform()) {
    const result = await FilePicker.pickFiles({
      types: ['application/json'],
      readData: true,
    })
    const file = result.files[0]
    if (!file?.data) throw new Error('未选择文件')
    // readData 返回 base64。atob 只能解出单字节字符串，中文（UTF-8 占 3 字节）会乱码，
    // 必须先转字节数组再用 TextDecoder 按 UTF-8 解码
    const bin = atob(file.data)
    const bytes = new Uint8Array(bin.length)
    for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i)
    content = new TextDecoder('utf-8').decode(bytes)
  } else {
    // 浏览器开发环境：input[type=file]
    content = await new Promise<string>((resolve, reject) => {
      const input = document.createElement('input')
      input.type = 'file'
      input.accept = '.json,application/json'
      input.onchange = () => {
        const file = input.files?.[0]
        if (!file) { reject(new Error('未选择文件')); return }
        const reader = new FileReader()
        reader.onload = () => resolve(String(reader.result))
        reader.onerror = () => reject(new Error('读取文件失败'))
        reader.readAsText(file)
      }
      input.click()
    })
  }

  return parseBackupData(content)
}

export function parseBackupData(content: string): BackupData {
  let raw: any
  try {
    raw = JSON.parse(content)
  } catch {
    throw new Error('文件不是有效的 JSON')
  }
  if (!raw || typeof raw !== 'object' || !Array.isArray(raw.transactions)) {
    throw new Error('不是 VoxSpend 备份文件')
  }
  // 逐条清洗，防止脏数据写库
  const transactions: Transaction[] = raw.transactions
    .filter((t: any) => t && typeof t === 'object')
    .map((t: any) => ({
      description: String(t.description ?? '').slice(0, 100),
      amount: Number(t.amount) || 0,
      category: String(t.category ?? '其他'),
      date: String(t.date ?? ''),
      createdAt: Number(t.createdAt) || Date.now(),
    }))
    .filter((t: Transaction) => t.description && t.amount > 0 && /^\d{4}-\d{2}-\d{2}$/.test(t.date))

  const weeklyReports: WeeklyReport[] = Array.isArray(raw.weeklyReports)
    ? raw.weeklyReports
        .filter((r: any) => r && typeof r === 'object')
        .map((r: any) => ({
          weekStartDate: String(r.weekStartDate ?? ''),
          weekEndDate: String(r.weekEndDate ?? ''),
          totalExpense: Number(r.totalExpense) || 0,
          categoryBreakdown: typeof r.categoryBreakdown === 'object' && r.categoryBreakdown ? r.categoryBreakdown : {},
          aiSummary: String(r.aiSummary ?? ''),
          generatedAt: Number(r.generatedAt) || Date.now(),
        }))
        .filter((r: WeeklyReport) => /^\d{4}-\d{2}-\d{2}$/.test(r.weekStartDate))
    : []

  if (!transactions.length && !weeklyReports.length) {
    throw new Error('备份文件中没有有效数据')
  }
  return { version: Number(raw.version) || 1, exportedAt: Number(raw.exportedAt) || Date.now(), transactions, weeklyReports }
}

/** 把备份写入数据库（合并模式：直接追加，IndexedDB 自增 id 不会冲突） */
export async function restoreBackup(data: BackupData): Promise<{ txCount: number; reportCount: number }> {
  if (data.transactions.length) {
    await addTransactions(data.transactions.map(t => ({
      description: t.description,
      amount: t.amount,
      category: t.category,
      date: t.date,
      createdAt: t.createdAt,
    })))
  }
  for (const r of data.weeklyReports) {
    // weeklyReports 的 weekStartDate 有 unique 索引，已存在则跳过（put 会带旧 id，add 会冲突）
    await saveWeeklyReport({ ...r, id: undefined as unknown as number })
  }
  return { txCount: data.transactions.length, reportCount: data.weeklyReports.length }
}
