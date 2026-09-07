import 'package:drift/drift.dart';

import '../local/database.dart';

class CategorySummary {
  const CategorySummary({
    required this.category,
    required this.budgetMinor,
    required this.spentMinor,
  });

  final Category category;
  final int? budgetMinor;
  final int spentMinor;

  int get remainingMinor => (budgetMinor ?? 0) - spentMinor;
}

class BudgetRepository {
  BudgetRepository(this.database);

  final AppDatabase database;

  Future<List<CategorySummary>> dashboardSummaries(DateTime period) async {
    final allCategories = await database.select(database.categories).get();
    final summaries = <CategorySummary>[];

    for (final category in allCategories) {
      final budgetRows = await (database.select(database.budgets)
            ..where((budget) =>
                budget.categoryId.equals(category.id) &
                budget.periodMonth.equals(period.month) &
                budget.periodYear.equals(period.year)))
          .get();
      final transactions = await (database.select(database.budgetTransactions)
            ..where((transaction) =>
                transaction.categoryId.equals(category.id) &
                transaction.date.isBetweenValues(
                  DateTime(period.year, period.month),
                  DateTime(period.year, period.month + 1),
                )))
          .get();
      summaries.add(CategorySummary(
        category: category,
        budgetMinor: budgetRows.isEmpty ? null : budgetRows.first.amountMinor,
        spentMinor: transactions
            .where((transaction) =>
                category.type != 'special' || transaction.isPurchased)
            .fold(
                0,
                (total, transaction) =>
                    total + transaction.convertedAmountMinor),
      ));
    }
    return summaries;
  }

  Future<List<BudgetTransaction>> monthlyExpenses(DateTime period) {
    return (database.select(database.budgetTransactions)
          ..where((transaction) => transaction.date.isBetweenValues(
                DateTime(period.year, period.month),
                DateTime(period.year, period.month + 1),
              ))
          ..orderBy([(transaction) => OrderingTerm.desc(transaction.date)]))
        .get();
  }

  Future<void> setMonthlyBudget(
      {required int amountMinor, required DateTime period}) async {
    final category = await (database.select(database.categories)
          ..where((category) => category.type.equals('monthly')))
        .getSingle();
    await database.into(database.budgets).insertOnConflictUpdate(
          BudgetsCompanion.insert(
            categoryId: category.id,
            amountMinor: amountMinor,
            periodMonth: period.month,
            periodYear: period.year,
            periodStart: DateTime(period.year, period.month),
          ),
        );
  }

  Future<void> addMonthlyExpense({
    required String title,
    required String subcategory,
    required int amountMinor,
    required DateTime date,
  }) async {
    final category = await (database.select(database.categories)
          ..where((category) => category.type.equals('monthly')))
        .getSingle();
    await database.into(database.budgetTransactions).insert(
          BudgetTransactionsCompanion.insert(
            categoryId: category.id,
            title: title,
            subcategory: Value(subcategory.isEmpty ? null : subcategory),
            amountMinor: amountMinor,
            convertedAmountMinor: amountMinor,
            date: date,
          ),
        );
  }

  Future<void> deleteExpense(int id) {
    return (database.delete(database.budgetTransactions)
          ..where((transaction) => transaction.id.equals(id)))
        .go();
  }
}
