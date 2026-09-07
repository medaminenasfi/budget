import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/repositories/budget_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(databaseProvider));
});

final dashboardProvider =
    FutureProvider.autoDispose<List<CategorySummary>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.dashboardSummaries(DateTime.now());
});

final monthlyExpensesProvider =
    FutureProvider.autoDispose<List<BudgetTransaction>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.monthlyExpenses(DateTime.now());
});

String formatTnd(int minorUnits) {
  final sign = minorUnits < 0 ? '-' : '';
  final absolute = minorUnits.abs();
  return '$sign${(absolute / 1000).toStringAsFixed(3)} TND';
}
