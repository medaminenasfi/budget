import 'package:flutter/material.dart';
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

final budgetAlertsProvider =
    FutureProvider.autoDispose<List<BudgetAlert>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  await ref.watch(databaseProvider).seedCategories();
  return repository.budgetAlerts(DateTime.now());
});

final monthlySummaryProvider =
    FutureProvider.autoDispose<CategorySummary>((ref) async {
  final summaries = await ref.watch(dashboardProvider.future);
  return summaries.firstWhere((summary) => summary.category.type == 'monthly');
});

final monthlyExpensesProvider =
    FutureProvider.autoDispose<List<BudgetTransaction>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.monthlyExpenses(DateTime.now());
});

final monthlySearchProvider = StateProvider.autoDispose<String>((ref) => '');
final monthlyCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final monthlyMinAmountProvider = StateProvider.autoDispose<String>((ref) => '');
final monthlyMaxAmountProvider = StateProvider.autoDispose<String>((ref) => '');
final monthlyDateRangeProvider =
    StateProvider.autoDispose<DateTimeRange?>((ref) => null);

final filteredMonthlyExpensesProvider =
    FutureProvider.autoDispose<List<BudgetTransaction>>((ref) async {
  final items = await ref.watch(monthlyExpensesProvider.future);
  final query = ref.watch(monthlySearchProvider).trim().toLowerCase();
  final category = ref.watch(monthlyCategoryProvider);
  final minAmount = int.tryParse(ref.watch(monthlyMinAmountProvider));
  final maxAmount = int.tryParse(ref.watch(monthlyMaxAmountProvider));
  final dateRange = ref.watch(monthlyDateRangeProvider);
  return items
      .where(
        (item) =>
            (query.isEmpty ||
                item.title.toLowerCase().contains(query) ||
                (item.subcategory?.toLowerCase().contains(query) ?? false)) &&
            (category == null || item.subcategory == category) &&
            (minAmount == null || item.amountMinor >= minAmount) &&
            (maxAmount == null || item.amountMinor <= maxAmount) &&
            (dateRange == null ||
                (!item.date.isBefore(dateRange.start) &&
                    item.date
                        .isBefore(dateRange.end.add(const Duration(days: 1))))),
      )
      .toList();
});

final sixMonthTrendProvider =
    FutureProvider.autoDispose<List<TrendPoint>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.sixMonthTrend(DateTime.now());
});

final specialPurchasesProvider =
    FutureProvider.autoDispose<List<BudgetTransaction>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.specialPurchases(DateTime.now());
});
final specialSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final specialSummaryProvider =
    FutureProvider.autoDispose<CategorySummary>((ref) async {
  final summaries = await ref.watch(dashboardProvider.future);
  return summaries.firstWhere((summary) => summary.category.type == 'special');
});

final tripsProvider = FutureProvider.autoDispose<List<Trip>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.trips();
});

final travelExpensesProvider = FutureProvider.autoDispose
    .family<List<BudgetTransaction>, int>((ref, tripId) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.travelExpenses(tripId);
});
final travelSearchProvider =
    StateProvider.autoDispose.family<String, int>((ref, tripId) => '');

final tripBudgetProvider =
    FutureProvider.autoDispose.family<Budget, int>((ref, budgetId) async {
  final database = ref.watch(databaseProvider);
  final rows = await (database.select(database.budgets)
        ..where((budget) => budget.id.equals(budgetId))
        ..limit(1))
      .get();
  if (rows.isEmpty) throw StateError('Trip budget not found');
  return rows.first;
});

final savingsSummaryProvider =
    FutureProvider.autoDispose<CategorySummary>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.savingsSummary();
});

final savingsRecordsProvider =
    FutureProvider.autoDispose<List<BudgetTransaction>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.savingsRecords();
});
final savingsSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final debtsProvider = FutureProvider.autoDispose<List<Debt>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.debts();
});

final settledDebtsProvider =
    FutureProvider.autoDispose<List<Debt>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.debts(settled: true);
});

final exchangeRatesProvider =
    FutureProvider.autoDispose<List<ExchangeRate>>((ref) async {
  return ref.watch(budgetRepositoryProvider).exchangeRates();
});

final recurringRulesProvider =
    FutureProvider.autoDispose<List<RecurringRule>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  await repository.processDueRecurringRules(DateTime.now());
  return repository.recurringRules();
});

String formatTnd(int minorUnits) {
  final sign = minorUnits < 0 ? '-' : '';
  final absolute = minorUnits.abs();
  return '$sign${(absolute / 1000).toStringAsFixed(3)} TND';
}
