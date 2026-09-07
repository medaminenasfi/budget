import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get colorValue => integer()();
}

@TableIndex(
  name: 'budget_period_unique',
  columns: {#categoryId, #periodMonth, #periodYear},
  unique: true,
)
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('TND'))();
  IntColumn get periodMonth => integer()();
  IntColumn get periodYear => integer()();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime().nullable()();
}

class Trips extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get destination => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  IntColumn get budgetId => integer().references(Budgets, #id)();
}

@TableIndex(name: 'transactions_category_date', columns: {#categoryId, #date})
class BudgetTransactions extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get tripId => integer().nullable().references(Trips, #id)();
  TextColumn get title => text()();
  TextColumn get subcategory => text().nullable()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('TND'))();
  IntColumn get convertedAmountMinor => integer()();
  RealColumn get exchangeRate => real().withDefault(const Constant(1.0))();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isPurchased => boolean().withDefault(const Constant(false))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
}

@DriftDatabase(tables: [Categories, Budgets, Trips, BudgetTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> seedCategories() async {
    if (await select(categories).get().then((rows) => rows.isNotEmpty)) {
      return;
    }

    await batch((batch) {
      batch.insertAll(categories, [
        CategoriesCompanion.insert(
          type: 'monthly',
          name: 'Monthly Expenses',
          icon: 'calendar_month',
          colorValue: 0xFFEF8354,
        ),
        CategoriesCompanion.insert(
          type: 'special',
          name: 'Special Purchases',
          icon: 'shopping_bag',
          colorValue: 0xFF5B8E7D,
        ),
        CategoriesCompanion.insert(
          type: 'travel',
          name: 'Travel',
          icon: 'flight_takeoff',
          colorValue: 0xFF3D6D9C,
        ),
        CategoriesCompanion.insert(
          type: 'savings',
          name: 'Savings',
          icon: 'savings',
          colorValue: 0xFFB38B59,
        ),
      ]);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'smart_budget_manager.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
