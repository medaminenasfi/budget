import 'package:drift/drift.dart';

import 'database_connection.dart';

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
  columns: {#categoryId, #periodMonth, #periodYear, #scopeId},
  unique: true,
)
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('TND'))();
  IntColumn get periodMonth => integer()();
  IntColumn get periodYear => integer()();
  IntColumn get scopeId => integer().withDefault(const Constant(0))();
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
  TextColumn get receiptPhotoPath => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class ExchangeRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get baseCurrency => text().withDefault(const Constant('TND'))();
  TextColumn get targetCurrency => text()();
  RealColumn get rate => real()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get personName => text()();
  TextColumn get direction => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('TND'))();
  IntColumn get convertedAmountMinor => integer()();
  RealColumn get exchangeRate => real().withDefault(const Constant(1.0))();
  DateTimeColumn get dateCreated => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get settled => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
}

class RecurringRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get subcategory => text().nullable()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('TND'))();
  RealColumn get exchangeRate => real().withDefault(const Constant(1.0))();
  TextColumn get frequency => text()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// User profile stored locally — used for auth and display.
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get region => text().withDefault(const Constant('Tunisia'))();
  TextColumn get avatarPath => text().nullable()();
  BoolColumn get isGoogleAccount =>
      boolean().withDefault(const Constant(false))();
  TextColumn get googleId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Key-value store for application settings (currency, biometrics, etc.).
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
}

@DriftDatabase(
  tables: [
    Categories,
    Budgets,
    Trips,
    BudgetTransactions,
    ExchangeRates,
    Debts,
    RecurringRules,
    UserProfiles,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(budgets, budgets.scopeId);
            await customStatement('DROP INDEX IF EXISTS budget_period_unique');
            await customStatement(
              'CREATE UNIQUE INDEX budget_period_unique '
              'ON budgets (category_id, period_month, period_year, scope_id)',
            );
          }
          if (from < 3) {
            await m.createTable(exchangeRates);
            await m.createTable(debts);
          }
          if (from < 4) {
            await m.createTable(recurringRules);
          }
          if (from < 5) {
            await m.addColumn(
                budgetTransactions, budgetTransactions.receiptPhotoPath);
          }
          if (from < 6) {
            await m.createTable(userProfiles);
            await m.createTable(appSettings);
          }
        },
      );

  Future<void> seedCategories() async {
    const definitions = [
      ('monthly', 'Monthly Expenses', 'calendar_month', 0xFFEF8354),
      ('special', 'Special Purchases', 'shopping_bag', 0xFF5B8E7D),
      ('travel', 'Travel', 'flight_takeoff', 0xFF3D6D9C),
      ('savings', 'Savings', 'savings', 0xFFB38B59),
      ('debt', 'Debt Tracker', 'account_balance', 0xFF9B5DE5),
    ];
    for (final definition in definitions) {
      final exists = await (select(categories)
            ..where((category) => category.type.equals(definition.$1))
            ..limit(1))
          .get();
      if (exists.isEmpty) {
        await into(categories).insert(
          CategoriesCompanion.insert(
            type: definition.$1,
            name: definition.$2,
            icon: definition.$3,
            colorValue: definition.$4,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // AppSettings helpers
  // ---------------------------------------------------------------------------

  Future<String?> getSetting(String key) async {
    final rows = await (select(appSettings)
          ..where((s) => s.key.equals(key))
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }
}
