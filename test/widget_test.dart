// VoxSpend 单元测试：模型层校验
import 'package:flutter_test/flutter_test.dart';

import 'package:voxspend/models/transaction.dart';

void main() {
  test('Transaction copyWith 保留未修改字段', () {
    final t = Transaction(
      description: '买面包',
      amount: 5.0,
      category: '餐饮',
      date: DateTime(2026, 8, 15),
      createdAt: DateTime(2026, 8, 15),
    );
    final updated = t.copyWith(amount: 6.0);
    expect(updated.amount, 6.0);
    expect(updated.description, '买面包');
    expect(updated.category, '餐饮');
  });

  test('Categories.normalize 非法类别归入其他', () {
    expect(Categories.normalize('未知类别'), '其他');
    expect(Categories.normalize('餐饮'), '餐饮');
    expect(Categories.normalize(null), '其他');
  });
}
