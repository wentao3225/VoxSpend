import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_service.dart';
import '../models/transaction.dart';
import 'database_provider.dart';

/// 搜索筛选条件状态
class SearchState {
  /// 搜索关键词
  final String keyword;

  /// 选中的类别（多选）
  final List<String> selectedCategories;

  /// 日期范围
  final DateTime? startDate;
  final DateTime? endDate;

  /// 金额区间
  final double? minAmount;
  final double? maxAmount;

  /// 搜索结果
  final List<Transaction> results;

  const SearchState({
    this.keyword = '',
    this.selectedCategories = const [],
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.results = const [],
  });

  bool get hasActiveFilter =>
      selectedCategories.isNotEmpty ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null;

  SearchState copyWith({
    String? keyword,
    List<String>? selectedCategories,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    double? minAmount,
    bool clearMinAmount = false,
    double? maxAmount,
    bool clearMaxAmount = false,
    List<Transaction>? results,
  }) {
    return SearchState(
      keyword: keyword ?? this.keyword,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      results: results ?? this.results,
    );
  }
}

/// 搜索状态管理（内置 500ms 防抖）
class SearchNotifier extends StateNotifier<SearchState> {
  final DatabaseService db;
  Timer? _debounce;

  SearchNotifier(this.db) : super(const SearchState());

  /// 更新关键词（防抖 500ms 后查询）
  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _search);
  }

  /// 切换类别选中
  void toggleCategory(String category) {
    final list = [...state.selectedCategories];
    if (list.contains(category)) {
      list.remove(category);
    } else {
      list.add(category);
    }
    state = state.copyWith(selectedCategories: list);
    _search();
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date, clearStartDate: date == null);
    _search();
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date, clearEndDate: date == null);
    _search();
  }

  void setMinAmount(double? value) {
    state = state.copyWith(minAmount: value, clearMinAmount: value == null);
    _search();
  }

  void setMaxAmount(double? value) {
    state = state.copyWith(maxAmount: value, clearMaxAmount: value == null);
    _search();
  }

  /// 重置所有条件
  void reset() {
    _debounce?.cancel();
    state = const SearchState();
    _search();
  }

  Future<void> _search() async {
    final results = await db.searchTransactions(
      keyword: state.keyword,
      categories: state.selectedCategories,
      startDate: state.startDate,
      endDate: state.endDate,
      minAmount: state.minAmount,
      maxAmount: state.maxAmount,
    );
    if (mounted) {
      state = state.copyWith(results: results);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// 搜索 Provider
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(databaseProvider));
});
