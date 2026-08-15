import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// App 主题常量
class AppColors {
  /// 主色调
  static const Color primary = Color(0xFF007AFF);

  /// 背景色
  static const Color background = Color(0xFFF2F2F7);

  /// 卡片背景
  static const Color card = Colors.white;

  /// 支出金额色
  static const Color expense = Color(0xFFFF3B30);

  /// 主要文本
  static const Color textPrimary = Color(0xFF1C1C1E);

  /// 次要文本
  static const Color textSecondary = Color(0xFF8E8E93);

  /// 分隔线
  static const Color separator = Color(0xFFE5E5EA);

  /// 分类色映射
  static const Map<String, Color> categoryColors = {
    '餐饮': Color(0xFFFF9500),
    '交通': Color(0xFF5856D6),
    '购物': Color(0xFFFF2D55),
    '娱乐': Color(0xFFAF52DE),
    '居住': Color(0xFF34C759),
    '医疗': Color(0xFFFF3B30),
    '教育': Color(0xFF5AC8FA),
    '其他': Color(0xFF8E8E93),
  };

  /// 获取分类颜色，未知类别返回灰色
  static Color categoryColor(String category) {
    return categoryColors[category] ?? textSecondary;
  }
}

/// 卡片圆角与阴影规范
class AppStyle {
  static const double cardRadius = 12;
  static const double largeRadius = 16;

  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ];
}

/// Cupertino 风格主题
class AppTheme {
  static const CupertinoThemeData cupertinoTheme = CupertinoThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: CupertinoColors.white,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.primary,
    ),
  );
}
