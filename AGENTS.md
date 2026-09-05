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
| AI | 商汤日日新（`token.sensenova.cn`），OpenAI 兼容协议，前端直连 |
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

`token.sensenova.cn` **不支持浏览器 CORS**（OPTIONS 预检返回 404，浏览器拦截），因此按环境分流（`ai-service.ts`）：

| 环境 | 通道 | URL |
|------|------|-----|
| Android APK（原生） | `CapacitorHttp`（`@capacitor/core` 内置，走原生网络栈，**无 CORS 限制**） | `https://token.sensenova.cn/v1/chat/completions`（`AI_API_URL_NATIVE`） |
| 浏览器开发 | `fetch` + Vite dev proxy | `/api/v1/chat/completions`（`AI_API_URL_WEB`）→ Vite 转发到商汤 |

- 判断方式：`Capacitor.isNativePlatform()`；原生响应 `res.data` 可能是字符串，用 `safeJsonParse()` 兜底
- Vite proxy 配置在 `vite.config.ts`（`/api` → `https://token.sensenova.cn`，rewrite 去掉 `/api` 前缀），**仅 dev server 生效**，与构建产物无关
- 项目**无后端**：不需要 Express，APK 完全独立运行
- API Key 通过 `Authorization: Bearer` 头直接发送（个人应用可接受）

### AI 模型

仅支持商汤日日新，可用模型：
- `sensenova-6.8-flash-lite` — 周报默认模型
- `deepseek-v4-flash` — 解析默认模型（更快更稳）

**思考模式**：`deepseek-v4-flash` 默认启用思考（响应含 `reasoning_content` 字段，拖慢速度）。请求体加 `reasoning_effort: 'none'` 关闭（可选 `low`/`medium`/`high`，默认 `medium`）。`ai-service.ts` 的 `chatCompletion()` 已统一加此参数。

解析和周报使用**不同模型**，可在设置页分别选择，存储在 localStorage（key `voxspend_model_config`）。`ai-config.ts` 中有自动迁移逻辑：旧默认 `sensenova` 解析模型会自动迁移到 `deepseek-v4-flash`（只迁移一次，标记 `voxspend_model_migrated_v2`）。

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
│   ├── components/     # 5 个可复用组件
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
- 关键函数：`getTransactionsByDate`、`addTransactions`（批量，剥离不可克隆属性、不传 id）、`updateTransaction`、`deleteTransaction`、`getAllTransactions`、`searchTransactions`（内存过滤）、`getTransactionsBetween`、`getWeeklyReport`/`saveWeeklyReport`/`getAllWeeklyReports`

## 跨页数据流（重要约定）

- **AI 解析流程**：`AddPage.vue` → `parseTransactions()` → 存 `sessionStorage`（`pending_txs`）→ `ConfirmPage.vue` → `addTransactions()`
- **周报流程**：`HomePage.vue` 周一自动触发 `checkWeeklyReport()` → `generateAiSummary()` → `saveWeeklyReport()` → 跳转 `WeeklyReportPage.vue`（数据经 `route.query` JSON 字符串传递）
- 跨页传数据用 `sessionStorage` 或 `route.query`，**不要**用全局 store（项目无 Pinia）

## 组件与页面约定

- 所有页面用 `<script setup lang="ts">`，结构统一：`.page` → `PageHeader` → `.page-content`
- 可复用组件：`PageHeader`（title/showBack + slots）、`LoadingButton`（loading/disabled/variant）、`TransactionItem`（列表项）、`CategoryPicker`（chips，支持 multiple）、`EmptyState`
- 错误处理用原生 `alert()`/`confirm()`；AI 错误显示 `e.reason`（`ParseException`）
- 搜索用 `searchTransactions()` + 500ms 防抖

## 注意事项

- `npm install` 必须加 `--legacy-peer-deps`
- 构建产物在 `dist/`，通过 `npx cap sync android` 同步进 Android 工程
- 数据仅存本地（IndexedDB），无后端数据库
- AI API 调用 60s 超时（前端 fetch AbortController）
- **AI 解析健壮性**：`ai-service.ts` 的 `extractJsonList()` 有多层兜底（直接解析 → 截取 `[...]` → 截取 `{...}` → 循环解码多段 JSON），兼容中文键名（`描述`/`金额`/`类别`）；解析时每条 `createdAt = baseTime + i` 保证唯一
- **已知坑**：部分组件 scoped style 引用了 `:root` 未定义的 CSS 变量（`--bg-secondary`、`--label-*`、`--system-green`、`--bg-card`），改动样式前先确认变量是否已定义
- **已解决**：Android 原生 WebView 的 AI 调用问题——原生环境用 `CapacitorHttp` 直连商汤（绕过 CORS），浏览器开发用 Vite dev proxy（`/api`）。**教训**：`token.sensenova.cn` 的 OPTIONS 预检虽返回 CORS 头但状态码是 404，浏览器要求预检必须 2xx，所以它**不支持浏览器 CORS**，不能直接 fetch 跨域
