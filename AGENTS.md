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
- `sensenova-6.8-flash-lite` — 默认解析模型
- `deepseek-v4-flash` — 备选

解析和周报使用**不同模型**，可在设置页分别选择，存储在 localStorage。

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
├── src/
│   ├── main.ts         # 入口
│   ├── App.vue         # 双 Tab 框架
│   ├── router/index.ts # 8 个路由
│   ├── models/         # 数据模型 + AI 配置（常量、localStorage）
│   ├── services/       # ai-service.ts（fetch 调用 AI API）
│   ├── db/index.ts     # IndexedDB CRUD
│   ├── views/          # 8 个页面组件
│   ├── components/     # 5 个可复用组件
│   ├── composables/    # 4 个 composable
│   ├── utils/          # format / validation / style
│   └── style.css       # 全局样式（~645 行）
├── vite.config.ts      # Vite + PWA + dev proxy
├── .env                # API Key（不提交）
└── .env.example        # 模板
```

## 注意事项

- `npm install` 必须加 `--legacy-peer-deps`
- 构建产物在 `dist/`，部署到任意静态服务器 + Express 即可
- PWA 图标需在 `public/` 下放 `pwa-192x192.png` 和 `pwa-512x512.png`
- 数据仅存本地（IndexedDB），无后端数据库
- AI API 调用 60s 超时（前端 + Express 均为 60s）
