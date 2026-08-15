import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

/// 类别筛选标签（可选中态）
class CategoryChip extends StatelessWidget {
  final String category;
  final bool selected;
  final Color? color;
  final ValueChanged<String>? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.categoryColor(category);
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c : c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: selected ? CupertinoColors.white : c,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
