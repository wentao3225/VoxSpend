# AGENTS.md

## 项目概览

VoxSpend — Vue 3 + Vite + TypeScript 记账应用（Capacitor 打包 Android APK），AI 语音/文字记账，离线优先。

## 技术栈

| 层 | 技术 |
|----|------|
| 框架 | Vue 3.5 + TypeScript 6 |
| 构建 | Vite 6 |
| 数据库 | IndexedDB（浏览器） |
| 打包 | Capacitor 8（Android APK） |
| AI | Agnes（`api.agnes-ai.cn`），OpenAI 兼容协议，前端直连 |
| 样式 | 纯 CSS，Cupertino 风格 |

## 命令

```bash
cd voxspend-web
npm install --legacy-peer-deps   # 必须加 --legacy-peer-deps
npm run dev                       # Vite dev server (5173)
npm run build                     # vue-tsc + vite build → dist/
npx vue-tsc --noEmit              # 仅类型检查
```

## 环境配置

- `.env` 文件放 `voxspend-web/` 下，内容：`VITE_AI_API_KEY=sk-xxx`
- `.env.example` 为模板，不含真实密钥
- `.env` 在 `.gitignore` 中，不会提交

## 架构要点

### AI 请求链路（按环境分流）

Agnes API 按环境分流（`ai-service.ts`）：

| 环境 | 通道 | URL |
|------|------|-----|
| Android APK（原生） | `CapacitorHttp`（`@capacitor/core` 内置，走原生网络栈，**无 CORS 限制**） | `https://api.agnes-ai.cn/v1/chat/completions`（`AI_API_URL_NATIVE`） |
| 浏览器开发 | `fetch` + Vite dev proxy | `/api/v1/chat/completions`（`AI_API_URL_WEB`）→ Vite 转发到 Agnes |

- 判断方式：`Capacitor.isNativePlatform()`；原生响应 `res.data` 可能是字符串，用 `safeJsonParse()` 兜底
- Vite proxy 配置在 `vite.config.ts`（`/api` → `https://api.agnes-ai.cn`，rewrite 去掉 `/api` 前缀），**仅 dev server 生效**，与构建产物无关
- 项目**无后端**：不需要 Express，APK 完全独立运行
- API Key 通过 `Authorization: Bearer` 头直接发送（个人应用可接受）

### AI 模型（已定死，不可配置）

模型固定为 **`agnes-2.5-flash`**（Agnes 2.5 Flash，OpenAI 兼容，512K 上下文），**不在设置页展示、不存 localStorage**（`ai-config.ts` 只导出 `PARSE_MODEL`/`REPORT_MODEL` 常量）：

- **记账解析**：关闭思考（`chat_template_kwargs: { enable_thinking: false }`），更快更稳，输出严格 JSON
- **周报总结**：开启思考（`enable_thinking: true`），总结更深入

**思考模式**：Agnes 用 `chat_template_kwargs.enable_thinking` 控制（OpenAI 兼容格式）；开启时响应含 `reasoning_content` 字段，`usage.completion_tokens_details.reasoning_tokens` 计数。文档：`agnes-ai.cn/zh-Hans/docs/agnes-25-flash`

### PWA 已移除

- 原先的 vite-plugin-pwa（Service Worker + manifest）已删除：应用走 Capacitor APK 分发，SW 在 WebView 里只会缓存旧资源导致更新不生效
- `vite.config.ts` 现在只有 `vue()` 插件；`index.html` 无 SW 注册代码

## 项目结构

```
voxspend-web/
├── capacitor.config.ts # Capacitor 8，appId cn.voxspend.app，webDir dist/
├── src/
│   ├── main.ts         # 入口
│   ├── App.vue         # 双 Tab 框架（首页 / 我的），keep-alive 缓存
│   ├── router/index.ts # 8 个路由，全部懒加载
│   ├── models/         # 数据模型 + AI 配置（常量、localStorage）
│   ├── services/       # ai-service.ts（fetch 调用 AI API）
│   ├── db/index.ts     # IndexedDB CRUD
│   ├── views/          # 8 个页面组件
│   ├── components/     # 6 个可复用组件
│   ├── composables/    # 4 个 composable
│   ├── utils/          # format / validation / style
│   └── style.css       # 全局样式（Cupertino 设计令牌）
├── vite.config.ts      # Vite（仅 vue 插件）
├── .env                # API Key（不提交）
└── .env.example        # 模板
```

## 数据模型

**Transaction**（`models/transaction.ts`）：
```ts
{ id?: number, description: string, amount: number, category: string, date: string /* YYYY-MM-DD */, createdAt: number }
```
- `CATEGORIES` = `['餐饮','交通','购物','娱乐','居住','医疗','教育','其他']`，`CATEGORY_COLORS` 为 iOS 系统色
- 非法类别用 `normalizeCategory()` 回退到 `'其他'`；`normalizeDate()` 输出 `YYYY-MM-DD`

**WeeklyReport**（`models/weekly-report.ts`）：
```ts
{ id?: number, weekStartDate: string, weekEndDate: string, totalExpense: number, categoryBreakdown: Record<string, number>, aiSummary: string, generatedAt: number }
```

## IndexedDB（`db/index.ts`）

- DB `voxspend` v1，单例 `dbInstance`
- **transactions** store：keyPath `id`（autoIncrement），索引 `date`/`category`/`createdAt`
- **weeklyReports** store：keyPath `id`（autoIncrement），索引 `weekStartDate`（**unique**）
- 关键函数：`getTransactionsByDate`、`addTransactions`（批量，剥离不可克隆属性、不传 id）、`updateTransaction`、`deleteTransaction`、`getAllTransactions`、`searchTransactions`（内存过滤）、`getTransactionsBetween`、`getWeeklyReport`/`saveWeeklyReport`/`getAllWeeklyReports`/`deleteWeeklyReport`

## 数据备份（`services/backup-service.ts`）

- **导出**：IndexedDB 全量（账单+周报）序列化为 JSON → 原生写 Cache 目录 + `Share.share()` 拉起系统分享面板；浏览器走 Blob 下载。文件名 `voxspend-backup-YYYY-MM-DD.json`
- **导入**：原生 `FilePicker.pickFiles({ readData: true })`（**base64 → `atob` → `Uint8Array` → `TextDecoder('utf-8')` 三步解码，直接 `atob` 中文必乱码**）；浏览器走 `input[type=file]`。`parseBackupData()` 逐条清洗（描述/金额/日期格式校验），确认弹窗后 `restoreBackup()` 写库
- **合并模式**：导入是追加不是覆盖（transactions 自增 id 不冲突；weeklyReports 的 `weekStartDate` unique 索引，写入时置 `id: undefined` 走 add，重复周报会静默失败但不影响账单）
- 插件：`@capacitor/filesystem`、`@capacitor/share`、`@capawesome/capacitor-file-picker`（均需 `npx cap sync android`）
- 入口在设置页「数据备份」区块，结果用页面内 toast 提示（非 alert）

## 跨页数据流（重要约定）

- **AI 解析流程**：`AddPage.vue` → `parseTransactions()` → 存 `sessionStorage`（`pending_txs`）→ `ConfirmPage.vue` → `addTransactions()`
- **周报流程**：`HomePage.vue` 周一自动触发 `checkWeeklyReport()` → `generateAiSummary()` → `saveWeeklyReport()` → 跳转 `WeeklyReportPage.vue`（数据经 `route.query` JSON 字符串传递）
- 跨页传数据用 `sessionStorage` 或 `route.query`，**不要**用全局 store（项目无 Pinia）

## 组件与页面约定

- 首页（`HomePage.vue`）支持**按天浏览**：`viewDate` 状态 + `‹`/`›` 箭头切换前一天/后一天（不能切到未来），今天显示「今日账单/今日支出」，历史日期显示「账单明细/当日支出」；keep-alive 下用 `onActivated` 刷新当前查看日期的数据
- **keep-alive 注意**：`App.vue` 把所有路由包在 `<keep-alive>` 里，组件实例跨路由复用、`onMounted` 只触发一次。依赖路由参数的页面（如 `TransactionDetailPage`）必须 `watch(() => route.params.id)` 重新加载；依赖 sessionStorage/外部数据的页面（如 `ConfirmPage`）必须用 `onActivated` 重读数据，否则会出现"点 A 显示 B"的脏数据。**已修复的页面**：详情页（watch id）、ConfirmPage（onActivated 重读 sessionStorage）、SearchPage（onActivated 重跑搜索，处理详情页删除/编辑后的过期结果）、WeeklyReportListPage（onActivated 刷新列表）、AddPage（解析成功后清空输入框，防止返回时残留旧描述重复记账）；HomePage（onActivated 刷新当日数据）
- 所有页面用 `<script setup lang="ts">`，结构统一：`.page` → `PageHeader` → `.page-content`
- 可复用组件：`PageHeader`（title/showBack + slots）、`LoadingButton`（loading/disabled/variant）、`TransactionItem`（列表项）、`CategoryPicker`（chips，支持 multiple）、`EmptyState`、`ConfirmDialog`（确认弹窗，`v-model:visible` + `@confirm`/`@cancel`，`destructive` 红色确认按钮）
- 错误处理用原生 `alert()`；**删除/危险操作确认用 `ConfirmDialog` 组件**（不要用原生 `confirm()`，避免浏览器原生弹窗）
- 搜索用 `searchTransactions()` + 500ms 防抖

## 注意事项

- `npm install` 必须加 `--legacy-peer-deps`
- 构建产物在 `dist/`，通过 `npx cap sync android` 同步进 Android 工程
- 数据仅存本地（IndexedDB），无后端数据库
- AI API 调用 60s 超时（前端 fetch AbortController）
- **AI 解析健壮性**：`ai-service.ts` 的 `extractJsonList()` 有多层兜底（直接解析 → 截取 `[...]` → 截取 `{...}` → 循环解码多段 JSON），兼容中文键名（`描述`/`金额`/`类别`）；解析时每条 `createdAt = baseTime + i` 保证唯一
- **已知坑**：部分组件 scoped style 引用了 `:root` 未定义的 CSS 变量（`--bg-secondary`、`--label-*`、`--system-green`、`--bg-card`），改动样式前先确认变量是否已定义
- **已解决**：Android 原生 WebView 的 AI 调用问题——原生环境用 `CapacitorHttp` 直连商汤（绕过 CORS），浏览器开发用 Vite dev proxy（`/api`）。**教训**：`token.sensenova.cn` 的 OPTIONS 预检虽返回 CORS 头但状态码是 404，浏览器要求预检必须 2xx，所以它**不支持浏览器 CORS**，不能直接 fetch 跨域
