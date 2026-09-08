import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/database.dart';
import '../data/models/default_categories.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Core infrastructure
// ---------------------------------------------------------------------------

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

final localAuthRepositoryProvider = Provider<LocalAuthRepository>((ref) {
  return LocalAuthRepository(
    ref.watch(databaseProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final googleAuthRepositoryProvider = Provider<GoogleAuthRepository>((ref) {
  return GoogleAuthRepository(
    ref.watch(databaseProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final biometricRepositoryProvider = Provider<BiometricRepository>((ref) {
  return BiometricRepository();
});

// ---------------------------------------------------------------------------
// Auth & Session
// ---------------------------------------------------------------------------

/// Holds the currently authenticated user profile. Null means not logged in.
final currentUserProvider = StateProvider<UserProfile?>((ref) => null);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  return ref.watch(biometricRepositoryProvider).isAvailable();
});

// ---------------------------------------------------------------------------
// Currency — global setting that drives all formatAmount() calls
// ---------------------------------------------------------------------------

/// Holds the active display currency (e.g. "TND", "EUR").
/// Backed by SharedPreferences via SettingsRepository.
class _CurrencyNotifier extends StateNotifier<String> {
  _CurrencyNotifier() : super('TND') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('app_currency') ?? 'TND';
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_currency', currency);
    state = currency;
  }
}

final appCurrencyProvider =
    StateNotifierProvider<_CurrencyNotifier, String>((ref) {
  return _CurrencyNotifier();
});

// ---------------------------------------------------------------------------
// Month selector — drives all monthly expense queries
// ---------------------------------------------------------------------------

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// ---------------------------------------------------------------------------
// Dashboard & budget alerts (use current real month always)
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Monthly expenses (drive by selectedMonthProvider)
// ---------------------------------------------------------------------------

final monthlySummaryProvider =
    FutureProvider.autoDispose<CategorySummary>((ref) async {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();

  // Get the monthly category
  final categories = await (database.select(database.categories)
        ..where((c) => c.type.equals('monthly'))
        ..limit(1))
      .get();
  if (categories.isEmpty) throw StateError('Monthly category not found');
  final category = categories.first;

  // Get budget for selected month
  final budgetRows = await (database.select(database.budgets)
        ..where((b) =>
            b.categoryId.equals(category.id) &
            b.periodMonth.equals(selectedMonth.month) &
            b.periodYear.equals(selectedMonth.year)))
      .get();

  // Get transactions for selected month
  final transactions = await (database.select(database.budgetTransactions)
        ..where((t) =>
            t.categoryId.equals(category.id) &
            t.date.isBetweenValues(
              DateTime(selectedMonth.year, selectedMonth.month),
              DateTime(selectedMonth.year, selectedMonth.month + 1),
            )))
      .get();

  return CategorySummary(
    category: category,
    budgetMinor: budgetRows.isEmpty
        ? null
        : budgetRows.fold<int>(0, (total, b) => total + b.amountMinor),
    spentMinor: transactions.fold<int>(
        0, (total, t) => total + t.convertedAmountMinor),
  );
});

final monthlyExpensesProvider =
    FutureProvider.autoDispose<List<BudgetTransaction>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  await database.seedCategories();
  return repository.monthlyExpenses(selectedMonth);
});

// ---------------------------------------------------------------------------
// Filter state
// ---------------------------------------------------------------------------

final filterVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);
final monthlySearchProvider = StateProvider.autoDispose<String>((ref) => '');
final monthlyCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final monthlyMinAmountProvider =
    StateProvider.autoDispose<String>((ref) => '');
final monthlyMaxAmountProvider =
    StateProvider.autoDispose<String>((ref) => '');
final monthlyDateRangeProvider =
    StateProvider.autoDispose<DateTimeRange?>((ref) => null);
final monthlyTypeFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null); // 'expense'|'income'|null

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

// ---------------------------------------------------------------------------
// Special, travel, savings, debts — unchanged
// ---------------------------------------------------------------------------

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

final sixMonthTrendProvider =
    FutureProvider.autoDispose<List<TrendPoint>>((ref) async {
  final repository = ref.watch(budgetRepositoryProvider);
  final database = ref.watch(databaseProvider);
  await database.seedCategories();
  return repository.sixMonthTrend(DateTime.now());
});

// ---------------------------------------------------------------------------
// Currency-aware formatting helpers
// ---------------------------------------------------------------------------

/// Formats [minorUnits] (stored as TND millis × 1000) in the given [currency].
/// When currency == TND: divide by 1000 with 3 decimal places.
/// When currency == other: convert via exchange rate, divide by 100 with 2 dp.
///
/// For simple display (no conversion), use [formatAmount] with [minorUnits]
/// already in TND millis.
String formatAmount(int minorTnd, String currency,
    {double exchangeRate = 1.0}) {
  if (currency == 'TND') {
    final sign = minorTnd < 0 ? '-' : '';
    final absolute = minorTnd.abs();
    return '$sign${(absolute / 1000).toStringAsFixed(3)} TND';
  }
  // Convert TND millis to foreign currency
  final converted = minorTnd / 1000 / exchangeRate;
  final sign = converted < 0 ? '-' : '';
  final symbol = _currencySymbol(currency);
  return '$sign${converted.abs().toStringAsFixed(2)} $symbol';
}

/// Legacy alias — formats TND millis with TND symbol.
String formatTnd(int minorUnits) => formatAmount(minorUnits, 'TND');

String _currencySymbol(String currency) {
  const symbols = {
    'TND': 'TND',
    'EUR': '€',
    'USD': '\$',
    'GBP': '£',
    'MAD': 'MAD',
    'DZD': 'DZD',
    'SAR': 'SAR',
    'AED': 'AED',
    'JPY': '¥',
    'CNY': '¥',
  };
  return symbols[currency] ?? currency;
}

int? parseTnd(String value) {
  final amount = double.tryParse(value.replaceAll(',', '.'));
  return amount == null ? null : (amount * 1000).round();
}
