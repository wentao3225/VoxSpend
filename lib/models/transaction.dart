import 'package:isar/isar.dart';

part 'transaction.g.dart';

/// 账单实体
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  /// 消费内容，如"买面包"
  @Index()
  String description;

  /// 金额，如 5.0
  double amount;

  /// 类别：餐饮/交通/购物/娱乐/居住/医疗/教育/其他
  @Index()
  String category;

  /// 消费日期（归一化到当天 00:00:00）
  @Index()
  DateTime date;

  /// 记录创建时间，用于排序
  DateTime createdAt;

  Transaction({
    this.id = Isar.autoIncrement,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  Transaction copyWith({
    int? id,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 预设类别常量
class Categories {
  static const List<String> all = [
    '餐饮',
    '交通',
    '购物',
    '娱乐',
    '居住',
    '医疗',
    '教育',
    '其他',
  ];

  static const String other = '其他';

  /// 校验类别合法性，非法值归入"其他"
  static String normalize(String? category) {
    if (category == null) return other;
    final trimmed = category.trim();
    return all.contains(trimmed) ? trimmed : other;
  }
}
