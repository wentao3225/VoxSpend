# AGENTS.md

## 项目概览

VoxSpend — Vue 3 + Vite + TypeScript PWA 记账应用，离线优先，数据 100% 本地。

## 技术栈

| 层 | 技术 |
|----|------|
| 框架 | Vue 3 + TypeScript |
| 构建 | Vite 6 |
| 状态管理 | Vue Router（轻量路由，无重度状态库） |
| 数据库 | IndexedDB（浏览器内置） |
| PWA | vite-plugin-pwa（Service Worker + Manifest） |
| 样式 | 纯 CSS，Cupertino 风格 |

## 命令

```bash
cd voxspend-web
npm install --legacy-peer-deps  # 安装依赖（peer deps 冲突用此参数）
npm run dev                     # 本地开发
npm run build                   # 打包 dist/
npm run preview                 # 预览构建产物
npx vue-tsc --noEmit            # 类型检查
```

## 项目结构

```
voxspend-web/
├── src/
│   ├── main.ts                 # 入口
│   ├── App.vue                 # 双 Tab 框架
│   ├── router/index.ts         # 路由配置
│   ├── models/                 # 数据模型（TS 接口）
│   │   ├── transaction.ts      # 账单 + 类别常量
│   │   ├── weekly-report.ts    # 周报
│   │   └── ai-config.ts        # AI 配置
│   ├── db/index.ts             # IndexedDB 封装 + localStorage 设置
│   ├── services/
│   │   └── ai-service.ts       # AI 解析（fetch 直接调用）
│   ├── views/                  # 页面组件
│   └── style.css               # 全局样式
├── vite.config.ts              # Vite + PWA 插件配置
└── package.json
```

## 架构要点

- **入口**: `main.ts` → Vue Router → `App.vue`（双 Tab：首页 / 我的）
- **存储**: IndexedDB 存账单/周报，localStorage 存 AI 配置
- **AI 服务**: 4 个平台（DeepSeek / 百炼 / 商汤 / 自定义），统一 OpenAI 兼容协议
- **PWA**: `vite-plugin-pwa` 自动生成 Service Worker，支持离线使用

## 注意事项

- `npm install` 必须加 `--legacy-peer-deps`（vite-plugin-pwa peer dep 冲突）
- 构建产物在 `dist/`，部署到任意静态服务器即可
- PWA 图标需在 `public/` 下放置 `pwa-192x192.png` 和 `pwa-512x512.png`
- 数据仅存本地，无后端
