# AI 智能记账助手 — 详细设计书（Technical Design Document）

**技术栈**：Flutter 3.19+ / Dart 3.x  
**状态管理**：flutter_riverpod  
**本地数据库**：Isar 3.x  
**本地 KV/加密**：flutter_secure_storage  
**图表**：fl_chart  
**网络**：dart:http

---

## 1. 系统架构

采用 **纯客户端分层架构**，无后端服务：

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Cupertino Widgets + Riverpod Hooks)   │
├─────────────────────────────────────────┤
│           State Management              │
│      (Riverpod Providers/Notifiers)     │
├─────────────────────────────────────────┤
│           Business Logic                │
│  (AIService / WeeklyReportService)      │
├─────────────────────────────────────────┤
│           Data Access Layer             │
│  (Isar DatabaseService / SecureStorage) │
├─────────────────────────────────────────┤
│           Platform Layer                │
│      (Android / iOS 本地存储)            │
└─────────────────────────────────────────┘
```

---

## 2. 项目目录结构

```
lib/
├── main.dart                    # 入口：ProviderScope + CupertinoTabScaffold
├── theme/
│   └── app_theme.dart           # AppColors + 分类色常量
├── models/
│   ├── transaction.dart         # Isar @collection
│   ├── weekly_report.dart       # Isar @collection
│   └── ai_config.dart           # 普通 Dart 类（JSON 序列化）
├── database/
│   └── database_service.dart    # Isar 单例 + CRUD
├── services/
│   ├── ai_service.dart          # 抽象接口 + 工厂
│   ├── parse_exception.dart     # 自定义异常
│   ├── weekly_report_service.dart # 周报生成逻辑
│   └── ai_providers/            # 各平台实现
│       ├── deepseek_provider.dart
│       ├── bailian_provider.dart
│       ├── sensechat_provider.dart
│       └── custom_provider.dart
├── providers/
│   ├── database_provider.dart   # 账单状态管理
│   ├── search_provider.dart     # 筛选条件状态
│   ├── weekly_report_provider.dart # 周报状态
│   └── settings_provider.dart   # 设置状态
├── pages/
│   ├── home_page.dart
│   ├── add_page.dart
│   ├── confirm_page.dart
│   ├── search_page.dart
│   ├── transaction_detail_page.dart
│   ├── weekly_report_page.dart
│   ├── weekly_report_list_page.dart
│   └── settings_page.dart
└── widgets/
    ├── transaction_card.dart
    ├── category_chip.dart
    └── empty_state.dart
```

---

## 3. 数据模型设计

### 3.1 Transaction（账单）

```dart
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index()
  String description;      // 消费内容，如"买面包"

  double amount;           // 金额，如 5.0

  @Index()
  String category;         // 枚举字符串：餐饮/交通/购物/娱乐/居住/医疗/教育/其他

  @Index()
  DateTime date;           // 消费日期（只用到年月日，时分为 00:00）

  DateTime createdAt;      // 记录创建时间，用于排序
}
```

**索引策略：**
- `category` + `date` 组合索引：加速按类别和日期的筛选查询
- `date` 单索引：加速首页"今日"查询

### 3.2 WeeklyReport（周报）

```dart
@collection
class WeeklyReport {
  Id id = Isar.autoIncrement;

  @Index(unique: true)    // 每周只生成一份
  DateTime weekStartDate;  // 周一 00:00:00

  DateTime weekEndDate;    // 周日 23:59:59

  double totalExpense;

  String categoryBreakdownJson;  // Map<String, double> 的 JSON 序列化（Isar 不支持 Map 原生类型）

  String aiSummary;        // AI 生成的文字总结

  DateTime generatedAt;    // 生成时间
}
```

### 3.3 AIConfig（AI 配置）

非 Isar 模型，以 JSON 字符串存储于 `FlutterSecureStorage`。

```dart
class AIConfig {
  final String provider;    // "deepseek" | "bailian" | "sensechat" | "custom"
  final String apiKey;
  final String modelName;   // 如 "deepseek-chat"
  final String? apiUrl;     // 自定义时必填，如 "https://api.xxx.com/v1"

  Map<String, dynamic> toJson() => ...;
  factory AIConfig.fromJson(...) => ...;
}
```

---

## 4. 数据库设计（Isar）

### 4.1 Schema 定义

```dart
// 注册到 Isar.open()
final isar = await Isar.open(
  [TransactionSchema, WeeklyReportSchema],
  directory: dir.path,
);
```

### 4.2 核心查询方法

| 方法 | 实现逻辑 |
|------|----------|
| `getTransactionsByDate(DateTime date)` | 将输入日期归一化为 `yyyy-MM-dd 00:00:00`，查询 `date` 字段等于该值，按 `createdAt` 倒序 |
| `searchTransactions({...})` | 动态构建 Isar Query：关键词用 `descriptionContains`；类别用 `categoryEqualTo` 多次 `.or()`；日期用 `dateBetween`；金额用 `amountBetween` |
| `getWeeklyReport(DateTime weekStart)` | 直接按 `weekStartDateEqualTo` 查询 |
| `getAllWeeklyReports()` | 全表查询，按 `weekStartDate` 倒序 |

---

## 5. 模块详细设计

### 5.1 核心流程：记账流程

```
用户打开 App
    ↓
进入首页（自动加载今日账单）
    ↓
点击「记一笔」
    ↓
进入 AddPage → 选择日期（默认今天）→ 输入自然语言
    ↓
点击「解析」→ 显示 Loading
    ↓
调用 AIService.parseTransactions(input, selectedDate, config)
    ↓
[成功] → 跳转 ConfirmPage，展示解析列表
    ↓
用户确认/修改每条记录的描述、金额、类别
    ↓
点击「保存」→ DatabaseService.addAll() → Riverpod 刷新 → 返回首页
    ↓
[失败] → 弹出 CupertinoAlertDialog，显示 ParseException.reason
```

### 5.2 核心流程：周报生成流程

```
用户打开 App（首页 initState）
    ↓
检查今天是否周一？且上周是否有账单？且本周报未生成？
    ↓
[条件满足] → 显示全屏 Loading → 调用 WeeklyReportService.generateWeeklyReport(lastMonday)
    ↓
查询上周所有 Transaction → 聚合 totalExpense + categoryBreakdown
    ↓
构造 Prompt 调用 AI → 获取 aiSummary
    ↓
组装 WeeklyReport → 存入 Isar
    ↓
关闭 Loading → 弹窗/全屏展示周报
    ↓
[条件不满足] → 静默跳过，正常展示首页
```

---

## 6. AI 服务设计

### 6.1 适配器模式

采用 **Strategy + Factory** 模式统一多平台调用：

```dart
abstract class AiParser {
  Future<List<Transaction>> parse(String input, DateTime date, AIConfig config);
}

class AIService {
  static AiParser _getProvider(String provider) {
    switch(provider) {
      case 'deepseek': return DeepSeekProvider();
      case 'bailian': return BailianProvider();
      case 'sensechat': return SenseChatProvider();
      case 'custom': return CustomProvider();
      default: throw UnsupportedError('Unknown provider');
    }
  }

  static Future<List<Transaction>> parseTransactions(...) async {
    final parser = _getProvider(config.provider);
    return parser.parse(input, date, config);
  }
}
```

### 6.2 HTTP 统一规范

所有 Provider 均遵循 OpenAI 兼容格式：

```dart
final response = await http.post(
  Uri.parse(config.apiUrl ?? defaultUrl),
  headers: {
    'Authorization': 'Bearer ${config.apiKey}',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'model': config.modelName,
    'messages': [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt}
    ],
    'temperature': 0.2,  // 低温度确保格式稳定
  }),
);
```

### 6.3 Prompt 工程

**System Prompt：**

```
你是一个记账助手。请将用户的口语化记账描述解析成结构化数据。
规则：
1. 输入可能是多条记录，用自然语言描述，没有固定分隔符
2. 你必须识别出每一条独立的消费记录
3. 每条记录必须包含：description（消费内容，简短）、amount（金额数字）、category（必须从以下类别中选择：餐饮、交通、购物、娱乐、居住、医疗、教育、其他）
4. 如果用户没有明确日期，使用提供的默认日期（忽略时分秒）
5. 如果某条记录缺少金额或缺少消费内容，该条标记为解析失败
6. 输出必须是严格的 JSON 数组格式，不要有任何 markdown 代码块标记，不要解释
7. 金额统一为数字（元），不要带单位

示例输出：
[{"description":"买面包","amount":5.0,"category":"餐饮"},{"description":"打车回家","amount":35.0,"category":"交通"}]
```

**User Prompt：**

```
记账描述：{userInput}
默认日期：{yyyy-MM-dd}
```

### 6.4 响应解析与校验

```dart
try {
  final jsonList = jsonDecode(responseBody) as List;
  final transactions = jsonList.map((e) => ...).toList();

  // 校验：每条必须有 description 和 amount
  for (final t in transactions) {
    if (t.description.isEmpty || t.amount <= 0) {
      throw ParseException('第 $i 条记录缺少金额或消费内容');
    }
  }
  return transactions;
} on FormatException catch (_) {
  throw ParseException('AI 返回格式错误，请重试');
}
```

---

## 7. UI 架构设计

### 7.1 导航结构

```
CupertinoTabScaffold
├── Tab 1: 首页 (HomePage)
│   └── 子页面栈（Navigation）：
│       ├── AddPage（记一笔）
│       ├── ConfirmPage（确认账单）
│       └── SearchPage（搜索/筛选）
│           └── TransactionDetailPage（详情/编辑）
├── Tab 2: 我的 (SettingsPage)
    └── 子页面栈：
        ├── WeeklyReportListPage（历史周报）
        └── WeeklyReportPage（周报详情）
```

### 7.2 主题规范

| 元素 | 值 |
|------|-----|
| 主色调 | `Color(0xFF007AFF)` |
| 背景色 | `Color(0xFFF2F2F7)` |
| 卡片背景 | `Colors.white` |
| 支出金额色 | `Color(0xFFFF3B30)` |
| 分类色 | 餐饮#FF9500, 交通#5856D6, 购物#FF2D55, 娱乐#AF52DE, 居住#34C759, 医疗#FF3B30, 教育#5AC8FA, 其他#8E8E93 |
| 圆角 | 12px（卡片）/ 16px（大卡片/弹窗） |
| 阴影 | `BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))` |

---

## 8. 状态管理设计（Riverpod）

| Provider | 类型 | 职责 |
|----------|------|------|
| `databaseProvider` | `StateNotifierProvider<TransactionNotifier, List<Transaction>>` | 管理当前展示的账单列表，支持 loadToday、addAll、update、delete |
| `searchProvider` | `StateNotifierProvider<SearchNotifier, SearchState>` | 管理搜索关键词、筛选条件，自动触发查询并更新结果列表 |
| `weeklyReportProvider` | `StateNotifierProvider<WeeklyReportNotifier, AsyncValue<WeeklyReport?>>` | 管理当前周报的生成与展示状态 |
| `settingsProvider` | `FutureProvider<AIConfig>` | 异步读取 SecureStorage 中的配置，全局共享 |

---

## 9. 安全设计

| 项目 | 方案 |
|------|------|
| API Key 存储 | `flutter_secure_storage`（iOS: Keychain / Android: Keystore） |
| 数据存储 | Isar 本地数据库文件，无加密（个人设备级安全，如需可开启 Isar 加密） |
| 网络传输 | HTTPS 强制（各 AI 平台均支持） |
| 输入校验 | 金额字段限制数字与小数点；日期字段使用 DatePicker 防止非法输入 |

---

## 10. 错误处理与边界情况

| 场景 | 处理策略 |
|------|----------|
| AI 解析返回非 JSON | 捕获 `FormatException`，弹框提示"AI 返回格式错误，请重试" |
| AI 解析部分成功（部分缺字段） | 整体视为失败，提示具体哪条记录缺少什么信息 |
| 网络超时（>10s） | 捕获 `SocketException`，提示"网络连接超时，请检查网络后重试" |
| API Key 无效（401） | 捕获 HTTP 401，提示"API Key 无效，请检查设置" |
| 周一打开 App 但上周无账单 | 跳过周报生成，不弹窗，静默执行 |
| 删除最后一条账单 | 列表变空，自动展示 EmptyState 组件 |
| 搜索无结果 | 显示"未找到相关账单"提示 |
