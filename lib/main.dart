import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/database_service.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 预初始化数据库与 AI 配置（冷启动 ≤2s 要求）
  await DatabaseService.init();

  runApp(const ProviderScope(child: VoxSpendApp()));
}

class VoxSpendApp extends ConsumerStatefulWidget {
  const VoxSpendApp({super.key});

  @override
  ConsumerState<VoxSpendApp> createState() => _VoxSpendAppState();
}

class _VoxSpendAppState extends ConsumerState<VoxSpendApp> {
  @override
  void initState() {
    super.initState();
    // 启动时异步加载 AI 配置
    Future.microtask(() {
      ref.read(settingsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'VoxSpend 记账',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      home: RootTabScaffold(),
    );
  }
}

/// 底部双 Tab 结构：首页 / 我的
class RootTabScaffold extends StatefulWidget {
  const RootTabScaffold({super.key});

  @override
  State<RootTabScaffold> createState() => _RootTabScaffoldState();
}

class _RootTabScaffoldState extends State<RootTabScaffold> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: '我的',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 0) {
          return CupertinoTabView(builder: (context) => const HomePage());
        }
        return CupertinoTabView(builder: (context) => const SettingsPage());
      },
    );
  }
}
