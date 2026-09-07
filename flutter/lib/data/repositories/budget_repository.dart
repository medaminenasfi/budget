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

class TrendPoint {
  const TrendPoint({required this.month, required this.totals});

  final DateTime month;
  final Map<String, int> totals;
}

class BudgetAlert {
  const BudgetAlert({required this.categoryName, required this.percentUsed});

  final String categoryName;
  final int percentUsed;
}

class BudgetRepository {
  BudgetRepository(this.database);

  final AppDatabase database;

  Future<List<CategorySummary>> dashboardSummaries(DateTime period) async {
    final categoryRows = await (database.select(database.categories)
          ..orderBy([(category) => OrderingTerm.asc(category.id)]))
        .get();
    final allCategories = <Category>[];
    final seenTypes = <String>{};
    for (final category in categoryRows) {
      if (seenTypes.add(category.type)) allCategories.add(category);
    }
    final summaries = <CategorySummary>[];

    for (final category in allCategories) {
      final budgetRows = await (database.select(database.budgets)
            ..where((budget) =>
                budget.categoryId.equals(category.id) &
                budget.periodMonth.equals(period.month) &
                budget.periodYear.equals(period.year)))
          .get();
      final transactionsQuery = database.select(database.budgetTransactions);
      if (category.type == 'savings') {
        transactionsQuery.where(
          (transaction) => transaction.categoryId.equals(category.id),
        );
      } else {
        transactionsQuery.where(
          (transaction) =>
              transaction.categoryId.equals(category.id) &
              transaction.date.isBetweenValues(
                DateTime(period.year, period.month),
                DateTime(period.year, period.month + 1),
              ),
        );
      }
      final transactions = await transactionsQuery.get();
      summaries.add(CategorySummary(
        category: category,
        budgetMinor: budgetRows.isEmpty
            ? null
            : budgetRows.fold<int>(
                0,
                (total, budget) => total + budget.amountMinor,
              ),
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

  Future<List<BudgetAlert>> budgetAlerts(DateTime period) async {
    final summaries = await dashboardSummaries(period);
    return summaries
        .where((summary) =>
            summary.budgetMinor != null &&
            summary.budgetMinor! > 0 &&
            summary.spentMinor * 100 >= summary.budgetMinor! * 80)
        .map((summary) => BudgetAlert(
              categoryName: summary.category.name,
              percentUsed:
                  (summary.spentMinor * 100 / summary.budgetMinor!).round(),
            ))
        .toList();
  }

  Future<List<BudgetTransaction>> monthlyExpenses(DateTime period) {
    return _monthlyExpenses(period);
  }

  Future<List<TrendPoint>> sixMonthTrend(DateTime endMonth) async {
    final categories = await database.select(database.categories).get();
    final startMonth = DateTime(endMonth.year, endMonth.month - 5);
    final transactions = await (database.select(database.budgetTransactions)
          ..where((transaction) => transaction.date.isBetweenValues(
                startMonth,
                DateTime(endMonth.year, endMonth.month + 1),
              )))
        .get();
    final points = <TrendPoint>[];
    for (var offset = 0; offset < 6; offset++) {
      final month = DateTime(startMonth.year, startMonth.month + offset);
      final totals = <String, int>{};
      for (final category in categories) {
        final total = transactions
            .where((transaction) =>
                transaction.categoryId == category.id &&
                transaction.date.year == month.year &&
                transaction.date.month == month.month &&
                (category.type != 'special' || transaction.isPurchased))
            .fold<int>(0,
                (sum, transaction) => sum + transaction.convertedAmountMinor);
        totals[category.type] = total;
      }
      points.add(TrendPoint(month: month, totals: totals));
    }
    return points;
  }

  Future<List<BudgetTransaction>> _monthlyExpenses(DateTime period) async {
    final category = await _category('monthly');
    return (database.select(database.budgetTransactions)
          ..where((transaction) =>
              transaction.categoryId.equals(category.id) &
              transaction.date.isBetweenValues(
                DateTime(period.year, period.month),
                DateTime(period.year, period.month + 1),
              ))
          ..orderBy([(transaction) => OrderingTerm.desc(transaction.date)]))
        .get();
  }

  Future<void> setMonthlyBudget(
      {required int amountMinor, required DateTime period}) async {
    await setCategoryBudget(
      type: 'monthly',
      amountMinor: amountMinor,
      period: period,
    );
  }

  Future<void> setCategoryBudget({
    required String type,
    required int amountMinor,
    required DateTime period,
  }) async {
    final category = await _category(type);
    final existingRows = await (database.select(database.budgets)
          ..where((budget) =>
              budget.categoryId.equals(category.id) &
              budget.periodMonth.equals(period.month) &
              budget.periodYear.equals(period.year) &
              budget.scopeId.equals(0))
          ..orderBy([(budget) => OrderingTerm.asc(budget.id)]))
        .get();
    final existing = existingRows.isEmpty ? null : existingRows.first;

    if (existing == null) {
      await database.into(database.budgets).insert(
            BudgetsCompanion.insert(
              categoryId: category.id,
              amountMinor: amountMinor,
              periodMonth: period.month,
              periodYear: period.year,
              periodStart: DateTime(period.year, period.month),
              scopeId: const Value(0),
            ),
          );
    } else {
      await (database.update(database.budgets)
            ..where((budget) => budget.id.equals(existing.id)))
          .write(
        BudgetsCompanion(
          amountMinor: Value(amountMinor),
          periodStart: Value(DateTime(period.year, period.month)),
        ),
      );
    }
  }

  Future<void> addMonthlyExpense({
    required String title,
    required String subcategory,
    required int amountMinor,
    required String currency,
    required DateTime date,
    String? receiptPhotoPath,
  }) async {
    final category = await _category('monthly');
    final rate = await exchangeRate(currency);
    await database.into(database.budgetTransactions).insert(
          BudgetTransactionsCompanion.insert(
            categoryId: category.id,
            title: title,
            subcategory: Value(subcategory.isEmpty ? null : subcategory),
            amountMinor: amountMinor,
            currency: Value(currency),
            convertedAmountMinor:
                convertToTndMinor(amountMinor, currency, rate),
            exchangeRate: Value(rate),
            date: date,
            receiptPhotoPath: Value(receiptPhotoPath),
          ),
        );
  }

  Future<void> updateMonthlyExpense({
    required int id,
    required String title,
    required String subcategory,
    required int amountMinor,
    required String currency,
    String? receiptPhotoPath,
  }) async {
    final rate = await exchangeRate(currency);
    await (database.update(database.budgetTransactions)
          ..where((transaction) => transaction.id.equals(id)))
        .write(
      BudgetTransactionsCompanion(
        title: Value(title),
        subcategory: Value(subcategory.isEmpty ? null : subcategory),
        amountMinor: Value(amountMinor),
        currency: Value(currency),
        convertedAmountMinor:
            Value(convertToTndMinor(amountMinor, currency, rate)),
        exchangeRate: Value(rate),
        receiptPhotoPath: Value(receiptPhotoPath),
      ),
    );
  }

  Future<void> deleteExpense(int id) {
    return (database.delete(database.budgetTransactions)
          ..where((transaction) => transaction.id.equals(id)))
        .go();
  }

  Future<Category> _category(String type) async {
    final rows = await (database.select(database.categories)
          ..where((category) => category.type.equals(type))
          ..orderBy([(category) => OrderingTerm.asc(category.id)])
          ..limit(1))
        .get();
    if (rows.isEmpty) throw StateError('Category not found: $type');
    return rows.first;
  }

  Future<List<BudgetTransaction>> specialPurchases(DateTime period) async {
    final category = await _category('special');
    return (database.select(database.budgetTransactions)
          ..where((item) =>
              item.categoryId.equals(category.id) &
              item.date.isBetweenValues(
                DateTime(period.year, period.month),
                DateTime(period.year, period.month + 1),
              ))
          ..orderBy([(item) => OrderingTerm.desc(item.date)]))
        .get();
  }

  Future<void> addSpecialPurchase({
    required String title,
    required int amountMinor,
    required String currency,
    required bool purchased,
  }) async {
    final category = await _category('special');
    final rate = await exchangeRate(currency);
    await database.into(database.budgetTransactions).insert(
          BudgetTransactionsCompanion.insert(
            categoryId: category.id,
            title: title,
            amountMinor: amountMinor,
            currency: Value(currency),
            convertedAmountMinor:
                convertToTndMinor(amountMinor, currency, rate),
            exchangeRate: Value(rate),
            isPurchased: Value(purchased),
            date: DateTime.now(),
          ),
        );
  }

  Future<void> toggleSpecialPurchase(BudgetTransaction item) async {
    await (database.update(database.budgetTransactions)
          ..where((transaction) => transaction.id.equals(item.id)))
        .write(
      BudgetTransactionsCompanion(isPurchased: Value(!item.isPurchased)),
    );
  }

  Future<List<Trip>> trips() {
    return (database.select(database.trips)
          ..orderBy([(trip) => OrderingTerm.desc(trip.startDate)]))
        .get();
  }

  Future<void> addTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required int budgetMinor,
  }) async {
    final category = await _category('travel');
    final budgetId = await database.into(database.budgets).insert(
          BudgetsCompanion.insert(
            categoryId: category.id,
            amountMinor: budgetMinor,
            periodMonth: startDate.month,
            periodYear: startDate.year,
            periodStart: startDate,
            periodEnd: Value(endDate),
            scopeId: Value(startDate.microsecondsSinceEpoch),
          ),
        );
    await database.into(database.trips).insert(
          TripsCompanion.insert(
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            budgetId: budgetId,
          ),
        );
  }

  Future<void> updateSpecialPurchase({
    required int id,
    required String title,
    required int amountMinor,
    required String currency,
    required bool purchased,
  }) async {
    final rate = await exchangeRate(currency);
    await (database.update(database.budgetTransactions)
          ..where((item) => item.id.equals(id)))
        .write(
      BudgetTransactionsCompanion(
        title: Value(title),
        amountMinor: Value(amountMinor),
        currency: Value(currency),
        convertedAmountMinor:
            Value(convertToTndMinor(amountMinor, currency, rate)),
        exchangeRate: Value(rate),
        isPurchased: Value(purchased),
      ),
    );
  }

  Future<void> deleteSpecialPurchase(int id) {
    return (database.delete(database.budgetTransactions)
          ..where((item) => item.id.equals(id)))
        .go();
  }

  Future<List<BudgetTransaction>> travelExpenses(int tripId) {
    return (database.select(database.budgetTransactions)
          ..where((item) => item.tripId.equals(tripId))
          ..orderBy([(item) => OrderingTerm.desc(item.date)]))
        .get();
  }

  Future<void> addTravelExpense({
    required int tripId,
    required String title,
    required String subcategory,
    required int amountMinor,
    required String currency,
  }) async {
    final category = await _category('travel');
    final rate = await exchangeRate(currency);
    await database.into(database.budgetTransactions).insert(
          BudgetTransactionsCompanion.insert(
            categoryId: category.id,
            tripId: Value(tripId),
            title: title,
            subcategory: Value(subcategory.isEmpty ? null : subcategory),
            amountMinor: amountMinor,
            currency: Value(currency),
            convertedAmountMinor:
                convertToTndMinor(amountMinor, currency, rate),
            exchangeRate: Value(rate),
            date: DateTime.now(),
          ),
        );
  }

  Future<void> updateTravelExpense({
    required int id,
    required String title,
    required String subcategory,
    required int amountMinor,
    required String currency,
  }) async {
    final rate = await exchangeRate(currency);
    await (database.update(database.budgetTransactions)
          ..where((item) => item.id.equals(id)))
        .write(
      BudgetTransactionsCompanion(
        title: Value(title),
        subcategory: Value(subcategory.isEmpty ? null : subcategory),
        amountMinor: Value(amountMinor),
        currency: Value(currency),
        convertedAmountMinor:
            Value(convertToTndMinor(amountMinor, currency, rate)),
        exchangeRate: Value(rate),
      ),
    );
  }

  Future<void> deleteTravelExpense(int id) {
    return (database.delete(database.budgetTransactions)
          ..where((item) => item.id.equals(id)))
        .go();
  }

  Future<void> deleteTrip(Trip trip) async {
    await (database.delete(database.budgetTransactions)
          ..where((item) => item.tripId.equals(trip.id)))
        .go();
    await (database.delete(database.trips)
          ..where((item) => item.id.equals(trip.id)))
        .go();
    await (database.delete(database.budgets)
          ..where((item) => item.id.equals(trip.budgetId)))
        .go();
  }

  Future<void> updateTrip({
    required Trip trip,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required int budgetMinor,
  }) async {
    await (database.update(database.trips)
          ..where((item) => item.id.equals(trip.id)))
        .write(
      TripsCompanion(
        destination: Value(destination),
        startDate: Value(startDate),
        endDate: Value(endDate),
      ),
    );
    await (database.update(database.budgets)
          ..where((item) => item.id.equals(trip.budgetId)))
        .write(
      BudgetsCompanion(
        amountMinor: Value(budgetMinor),
        periodMonth: Value(startDate.month),
        periodYear: Value(startDate.year),
        periodStart: Value(startDate),
        periodEnd: Value(endDate),
      ),
    );
  }

  Future<CategorySummary> savingsSummary() async {
    final category = await _category('savings');
    final goals = await (database.select(database.budgets)
          ..where((budget) => budget.categoryId.equals(category.id))
          ..orderBy([(budget) => OrderingTerm.desc(budget.id)]))
        .get();
    final records = await (database.select(database.budgetTransactions)
          ..where((item) => item.categoryId.equals(category.id)))
        .get();
    return CategorySummary(
      category: category,
      budgetMinor: goals.isEmpty ? null : goals.first.amountMinor,
      spentMinor: records.fold(
        0,
        (total, record) => total + record.convertedAmountMinor,
      ),
    );
  }

  Future<List<BudgetTransaction>> savingsRecords() async {
    final category = await _category('savings');
    return (database.select(database.budgetTransactions)
          ..where((item) => item.categoryId.equals(category.id))
          ..orderBy([(item) => OrderingTerm.desc(item.date)]))
        .get();
  }

  Future<void> addSaving(int amountMinor, {required String currency}) async {
    final category = await _category('savings');
    final rate = await exchangeRate(currency);
    await database.into(database.budgetTransactions).insert(
          BudgetTransactionsCompanion.insert(
            categoryId: category.id,
            title: 'Saving',
            amountMinor: amountMinor,
            currency: Value(currency),
            convertedAmountMinor:
                convertToTndMinor(amountMinor, currency, rate),
            exchangeRate: Value(rate),
            date: DateTime.now(),
          ),
        );
  }

  Future<void> updateSaving({
    required int id,
    required int amountMinor,
    required String currency,
  }) async {
    final rate = await exchangeRate(currency);
    await (database.update(database.budgetTransactions)
          ..where((item) => item.id.equals(id)))
        .write(
      BudgetTransactionsCompanion(
        amountMinor: Value(amountMinor),
        currency: Value(currency),
        convertedAmountMinor:
            Value(convertToTndMinor(amountMinor, currency, rate)),
        exchangeRate: Value(rate),
      ),
    );
  }

  Future<void> deleteSaving(int id) {
    return (database.delete(database.budgetTransactions)
          ..where((item) => item.id.equals(id)))
        .go();
  }

  Future<List<Debt>> debts({bool settled = false}) {
    return (database.select(database.debts)
          ..where((debt) => debt.settled.equals(settled))
          ..orderBy([(debt) => OrderingTerm.desc(debt.dateCreated)]))
        .get();
  }

  Future<void> addDebt({
    required String personName,
    required String direction,
    required int amountMinor,
    required String currency,
    DateTime? dueDate,
    String? notes,
  }) async {
    final rate = await exchangeRate(currency);
    await database.into(database.debts).insert(
          DebtsCompanion.insert(
            personName: personName,
            direction: direction,
            amountMinor: amountMinor,
            currency: Value(currency),
            convertedAmountMinor: convertToTndMinor(
              amountMinor,
              currency,
              rate,
            ),
            exchangeRate: Value(rate),
            dateCreated: DateTime.now(),
            dueDate: Value(dueDate),
            notes: Value(notes),
          ),
        );
  }

  Future<void> settleDebt(int id) async {
    await (database.update(database.debts)..where((debt) => debt.id.equals(id)))
        .write(const DebtsCompanion(settled: Value(true)));
  }

  Future<void> deleteDebt(int id) {
    return (database.delete(database.debts)
          ..where((debt) => debt.id.equals(id)))
        .go();
  }

  Future<List<ExchangeRate>> exchangeRates() {
    return database.select(database.exchangeRates).get();
  }

  Future<double> exchangeRate(String currency) async {
    if (currency == 'TND') return 1;
    final rows = await (database.select(database.exchangeRates)
          ..where((rate) => rate.targetCurrency.equals(currency))
          ..orderBy([(rate) => OrderingTerm.desc(rate.updatedAt)])
          ..limit(1))
        .get();
    return rows.isEmpty ? 1 : rows.first.rate;
  }

  Future<void> setExchangeRate({
    required String currency,
    required double rate,
  }) async {
    final existing = await (database.select(database.exchangeRates)
          ..where((item) => item.targetCurrency.equals(currency))
          ..limit(1))
        .get();
    final companion = ExchangeRatesCompanion(
      baseCurrency: const Value('TND'),
      targetCurrency: Value(currency),
      rate: Value(rate),
      updatedAt: Value(DateTime.now()),
    );
    if (existing.isEmpty) {
      await database.into(database.exchangeRates).insert(companion);
    } else {
      await (database.update(database.exchangeRates)
            ..where((item) => item.id.equals(existing.first.id)))
          .write(companion);
    }
  }

  int convertToTndMinor(int amountMinor, String currency, double rate) {
    if (currency == 'TND') return amountMinor;
    return (amountMinor * rate * 10).round();
  }

  Future<List<RecurringRule>> recurringRules() {
    return (database.select(database.recurringRules)
          ..where((rule) => rule.active.equals(true))
          ..orderBy([(rule) => OrderingTerm.asc(rule.nextDueDate)]))
        .get();
  }

  Future<void> addRecurringRule({
    required String title,
    required String categoryType,
    required String subcategory,
    required int amountMinor,
    required String currency,
    required String frequency,
    required DateTime nextDueDate,
  }) async {
    final category = await _category(categoryType);
    final rate = await exchangeRate(currency);
    await database.into(database.recurringRules).insert(
          RecurringRulesCompanion.insert(
            title: title,
            categoryId: category.id,
            subcategory: Value(subcategory.isEmpty ? null : subcategory),
            amountMinor: amountMinor,
            currency: Value(currency),
            exchangeRate: Value(rate),
            frequency: frequency,
            nextDueDate: nextDueDate,
          ),
        );
  }

  Future<int> processDueRecurringRules(DateTime now) async {
    final rules = await (database.select(database.recurringRules)
          ..where((rule) =>
              rule.active.equals(true) &
              rule.nextDueDate.isSmallerOrEqualValue(now)))
        .get();
    var inserted = 0;
    for (final rule in rules) {
      final converted = convertToTndMinor(
        rule.amountMinor,
        rule.currency,
        rule.exchangeRate,
      );
      await database.into(database.budgetTransactions).insert(
            BudgetTransactionsCompanion.insert(
              categoryId: rule.categoryId,
              title: rule.title,
              subcategory: Value(rule.subcategory),
              amountMinor: rule.amountMinor,
              currency: Value(rule.currency),
              convertedAmountMinor: converted,
              exchangeRate: Value(rule.exchangeRate),
              date: rule.nextDueDate,
              isRecurring: const Value(true),
            ),
          );
      await (database.update(database.recurringRules)
            ..where((item) => item.id.equals(rule.id)))
          .write(
        RecurringRulesCompanion(
            nextDueDate: Value(_advance(rule.nextDueDate, rule.frequency))),
      );
      inserted++;
    }
    return inserted;
  }

  Future<void> deactivateRecurringRule(int id) async {
    await (database.update(database.recurringRules)
          ..where((rule) => rule.id.equals(id)))
        .write(const RecurringRulesCompanion(active: Value(false)));
  }

  DateTime _advance(DateTime date, String frequency) {
    switch (frequency) {
      case 'weekly':
        return date.add(const Duration(days: 7));
      case 'yearly':
        return DateTime(date.year + 1, date.month, date.day);
      default:
        return DateTime(date.year, date.month + 1, date.day);
    }
  }
}
