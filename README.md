# VoxSpend - AI 智能记账助手

一款离线优先的个人记账应用：用一句自然语言记录多笔消费，AI 自动解析为结构化账单。数据 100% 存储于本地。

## 功能特性

- 🗣 **自然语言记账**：口语化输入，如"买了个面包花了五块，买了包烟花了十元"，AI 自动拆分为多笔账单
- 📅 **补录历史**：记账时可选择过去日期
- ✅ **解析确认**：AI 结果先进入确认页，逐条修改后再入库
- 🔍 **多维检索**：关键词（500ms 防抖）+ 类别多选 + 日期范围 + 金额区间
- 📊 **每周周报**：周一自动生成上周消费周报（AI 总结 + 分类占比饼图），支持历史回看
- 🔐 **本地隐私**：账单数据存 Isar 本地库；API Key 存 SecureStorage 加密
- 🤖 **多 AI 平台**：DeepSeek / 阿里云百炼 / 商汤日日新 / 自定义 OpenAI 兼容接口

## 技术栈

| 层 | 技术 |
|----|------|
| UI | Flutter (Cupertino 风格) |
| 状态管理 | flutter_riverpod |
| 数据库 | Isar 3.x |
| 加密存储 | flutter_secure_storage |
| 图表 | fl_chart |
| 网络 | dart:http |

## 环境要求

- Flutter 3.19+（Dart 3.x）
- Android 8.0+ 设备或模拟器

## 快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 生成 Isar 代码
dart run build_runner build

# 3. 运行
flutter run
```

## 项目结构

```
lib/
├── main.dart                 # 入口 + 双 Tab 框架
├── theme/app_theme.dart      # 主题常量
├── models/                   # 数据模型（Isar 集合）
├── database/                 # Isar 单例 + CRUD
├── services/                 # AI 解析 / 周报生成
│   └── ai_providers/         # 各平台适配器
├── providers/                # Riverpod 状态管理
├── pages/                    # 8 个页面
└── widgets/                  # 通用组件
```

## 使用说明

1. 首次使用请进入「我的 → AI 服务配置」，选择平台并填写 API Key
2. 点击首页「记一笔」，输入口语化描述后点「解析」
3. 在确认页检查/修改每笔账单后保存
4. 每周一打开 App 自动弹出上周周报（也可在「我的 → 历史周报」回看）
