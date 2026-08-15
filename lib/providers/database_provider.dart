import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_service.dart';
import '../models/transaction.dart';

/// 账单列表状态管理
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final DatabaseService db;

  TransactionNotifier(this.db) : super([]) {
    loadToday();
  }

  /// 加载今日账单
  Future<void> loadToday() async {
    state = await db.getTransactionsByDate(DateTime.now());
  }

  /// 加载指定日期账单
  Future<void> loadByDate(DateTime date) async {
    state = await db.getTransactionsByDate(date);
  }

  /// 批量新增并刷新
  Future<void> addAll(List<Transaction> transactions) async {
    await db.addAll(transactions);
    await loadToday();
  }

  /// 更新并刷新
  Future<void> update(Transaction transaction) async {
    await db.update(transaction);
    await loadToday();
  }

  /// 删除并刷新
  Future<void> delete(int id) async {
    await db.delete(id);
    await loadToday();
  }
}

/// 数据库服务 Provider（main 中预初始化后立即可用）
final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// 账单列表 Provider
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier(ref.watch(databaseProvider));
});
