# AGENTS.md

## 项目概览

VoxSpend — Vue 3 + Vite + TypeScript PWA 记账应用，AI 语音/文字记账，离线优先。

## 技术栈

| 层 | 技术 |
|----|------|
| 框架 | Vue 3.5 + TypeScript 6 |
| 构建 | Vite 6 |
| 数据库 | IndexedDB（浏览器） |
| PWA | vite-plugin-pwa（Service Worker） |
| 后端 | Express 5（`server.cjs`，代理 AI API） |
| AI | 商汤日日新（`token.sensenova.cn`），OpenAI 兼容协议 |
| 样式 | 纯 CSS，Cupertino 风格 |

## 命令

```bash
cd voxspend-web
npm install --legacy-peer-deps   # 必须加 --legacy-peer-deps
npm run dev                       # 同时启动 Express(3000) + Vite(5173)
npm run build                     # vue-tsc + vite build → dist/
npm run start                     # 生产模式：Express 3000 提供 dist/ + 代理 AI API
npx vue-tsc --noEmit              # 仅类型检查
```

## 环境配置

- `.env` 文件放 `voxspend-web/` 下，内容：`VITE_AI_API_KEY=sk-xxx`
- `.env.example` 为模板，不含真实密钥
- `.env` 在 `.gitignore` 中，不会提交

## 架构要点

### 双启动模式

| 模式 | 命令 | Express | Vite | 用途 |
|------|------|---------|------|------|
| 开发 | `npm run dev` | `localhost:3000`（API 代理） | `localhost:5173`（HMR） | 开发调试 |
| 生产 | `npm run start` | `localhost:3000`（静态文件 + API） | 无 | 部署运行 |

### AI 请求链路

```
浏览器 → fetch('/api/v1/chat/completions')
       → Vite dev proxy (开发) 或 Express (生产)
       → token.sensenova.cn (服务端，无 CORS 问题)
```

`token.sensenova.cn` **不支持浏览器 CORS**，必须通过 Express 代理。`vite.config.ts` 中配置了 `/api` → `localhost:3000` 的 dev proxy。

### AI 模型

仅支持商汤日日新，可用模型：
- `sensenova-6.8-flash-lite` — 周报默认模型
- `deepseek-v4-flash` — 解析默认模型（更快更稳）

解析和周报使用**不同模型**，可在设置页分别选择，存储在 localStorage（key `voxspend_model_config`）。`ai-config.ts` 中有自动迁移逻辑：旧默认 `sensenova` 解析模型会自动迁移到 `deepseek-v4-flash`（只迁移一次，标记 `voxspend_model_migrated_v2`）。

### PWA Service Worker

- workbox 配置中 `/api/` 路径设为 `NetworkOnly`，**不缓存 AI 请求**
- 如果浏览器缓存了旧的失败响应，需手动清除：DevTools → Application → Service Workers → Unregister

### Express 5 注意

SPA fallback 路由必须用 `app.get('/{*splat}')`，不能用 `app.get('*')`（Express 5 breaking change）。

## 项目结构

```
voxspend-web/
├── server.cjs          # Express：静态文件 + API 代理（端口 3000）
├── dev.cjs             # 开发启动器：同时启 Express + Vite
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
├── vite.config.ts      # Vite + PWA + dev proxy
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
- 构建产物在 `dist/`，部署到任意静态服务器 + Express 即可
- PWA 图标需在 `public/` 下放 `pwa-192x192.png` 和 `pwa-512x512.png`
- 数据仅存本地（IndexedDB），无后端数据库
- AI API 调用 60s 超时（前端 + Express 均为 60s）
- **AI 解析健壮性**：`ai-service.ts` 的 `extractJsonList()` 有多层兜底（直接解析 → 截取 `[...]` → 截取 `{...}` → 循环解码多段 JSON），兼容中文键名（`描述`/`金额`/`类别`）；解析时每条 `createdAt = baseTime + i` 保证唯一
- **已知坑**：部分组件 scoped style 引用了 `:root` 未定义的 CSS 变量（`--bg-secondary`、`--label-*`、`--system-green`、`--bg-card`），改动样式前先确认变量是否已定义
- **已知坑**：Android 原生 WebView 中 `/api` 相对路径不走 Vite dev proxy 或 Express 代理，AI 调用在原生环境可能失效（除非配置服务器地址）
