// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, type, name, icon, colorValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String type;
  final String name;
  final String icon;
  final int colorValue;
  const Category(
      {required this.id,
      required this.type,
      required this.name,
      required this.icon,
      required this.colorValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color_value'] = Variable<int>(colorValue);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      type: Value(type),
      name: Value(name),
      icon: Value(icon),
      colorValue: Value(colorValue),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'colorValue': serializer.toJson<int>(colorValue),
    };
  }

  Category copyWith(
          {int? id,
          String? type,
          String? name,
          String? icon,
          int? colorValue}) =>
      Category(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        colorValue: colorValue ?? this.colorValue,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, name, icon, colorValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.type == this.type &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.colorValue == this.colorValue);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> colorValue;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorValue = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String name,
    required String icon,
    required int colorValue,
  })  : type = Value(type),
        name = Value(name),
        icon = Value(icon),
        colorValue = Value(colorValue);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? colorValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorValue != null) 'color_value': colorValue,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<String>? name,
      Value<String>? icon,
      Value<int>? colorValue}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('TND'));
  static const VerificationMeta _periodMonthMeta =
      const VerificationMeta('periodMonth');
  @override
  late final GeneratedColumn<int> periodMonth = GeneratedColumn<int>(
      'period_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _periodYearMeta =
      const VerificationMeta('periodYear');
  @override
  late final GeneratedColumn<int> periodYear = GeneratedColumn<int>(
      'period_year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _periodStartMeta =
      const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
      'period_start', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
      'period_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        amountMinor,
        currency,
        periodMonth,
        periodYear,
        periodStart,
        periodEnd
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<Budget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('period_month')) {
      context.handle(
          _periodMonthMeta,
          periodMonth.isAcceptableOrUnknown(
              data['period_month']!, _periodMonthMeta));
    } else if (isInserting) {
      context.missing(_periodMonthMeta);
    }
    if (data.containsKey('period_year')) {
      context.handle(
          _periodYearMeta,
          periodYear.isAcceptableOrUnknown(
              data['period_year']!, _periodYearMeta));
    } else if (isInserting) {
      context.missing(_periodYearMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
          _periodStartMeta,
          periodStart.isAcceptableOrUnknown(
              data['period_start']!, _periodStartMeta));
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      periodMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_month'])!,
      periodYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_year'])!,
      periodStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_start'])!,
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end']),
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final int categoryId;
  final int amountMinor;
  final String currency;
  final int periodMonth;
  final int periodYear;
  final DateTime periodStart;
  final DateTime? periodEnd;
  const Budget(
      {required this.id,
      required this.categoryId,
      required this.amountMinor,
      required this.currency,
      required this.periodMonth,
      required this.periodYear,
      required this.periodStart,
      this.periodEnd});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['period_month'] = Variable<int>(periodMonth);
    map['period_year'] = Variable<int>(periodYear);
    map['period_start'] = Variable<DateTime>(periodStart);
    if (!nullToAbsent || periodEnd != null) {
      map['period_end'] = Variable<DateTime>(periodEnd);
    }
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      periodMonth: Value(periodMonth),
      periodYear: Value(periodYear),
      periodStart: Value(periodStart),
      periodEnd: periodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(periodEnd),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      periodMonth: serializer.fromJson<int>(json['periodMonth']),
      periodYear: serializer.fromJson<int>(json['periodYear']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime?>(json['periodEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'periodMonth': serializer.toJson<int>(periodMonth),
      'periodYear': serializer.toJson<int>(periodYear),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime?>(periodEnd),
    };
  }

  Budget copyWith(
          {int? id,
          int? categoryId,
          int? amountMinor,
          String? currency,
          int? periodMonth,
          int? periodYear,
          DateTime? periodStart,
          Value<DateTime?> periodEnd = const Value.absent()}) =>
      Budget(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        periodMonth: periodMonth ?? this.periodMonth,
        periodYear: periodYear ?? this.periodYear,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd.present ? periodEnd.value : this.periodEnd,
      );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      periodMonth:
          data.periodMonth.present ? data.periodMonth.value : this.periodMonth,
      periodYear:
          data.periodYear.present ? data.periodYear.value : this.periodYear,
      periodStart:
          data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodYear: $periodYear, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, amountMinor, currency,
      periodMonth, periodYear, periodStart, periodEnd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.periodMonth == this.periodMonth &&
          other.periodYear == this.periodYear &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<int> periodMonth;
  final Value<int> periodYear;
  final Value<DateTime> periodStart;
  final Value<DateTime?> periodEnd;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.periodMonth = const Value.absent(),
    this.periodYear = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required int amountMinor,
    this.currency = const Value.absent(),
    required int periodMonth,
    required int periodYear,
    required DateTime periodStart,
    this.periodEnd = const Value.absent(),
  })  : categoryId = Value(categoryId),
        amountMinor = Value(amountMinor),
        periodMonth = Value(periodMonth),
        periodYear = Value(periodYear),
        periodStart = Value(periodStart);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? periodMonth,
    Expression<int>? periodYear,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (periodMonth != null) 'period_month': periodMonth,
      if (periodYear != null) 'period_year': periodYear,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
    });
  }

  BudgetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<int>? periodMonth,
      Value<int>? periodYear,
      Value<DateTime>? periodStart,
      Value<DateTime?>? periodEnd}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (periodMonth.present) {
      map['period_month'] = Variable<int>(periodMonth.value);
    }
    if (periodYear.present) {
      map['period_year'] = Variable<int>(periodYear.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodYear: $periodYear, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _destinationMeta =
      const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
      'destination', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _budgetIdMeta =
      const VerificationMeta('budgetId');
  @override
  late final GeneratedColumn<int> budgetId = GeneratedColumn<int>(
      'budget_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES budgets (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, destination, startDate, endDate, budgetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<Trip> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('destination')) {
      context.handle(
          _destinationMeta,
          destination.isAcceptableOrUnknown(
              data['destination']!, _destinationMeta));
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(_budgetIdMeta,
          budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta));
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      destination: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destination'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      budgetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}budget_id'])!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final int id;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int budgetId;
  const Trip(
      {required this.id,
      required this.destination,
      required this.startDate,
      required this.endDate,
      required this.budgetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['destination'] = Variable<String>(destination);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['budget_id'] = Variable<int>(budgetId);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      destination: Value(destination),
      startDate: Value(startDate),
      endDate: Value(endDate),
      budgetId: Value(budgetId),
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<int>(json['id']),
      destination: serializer.fromJson<String>(json['destination']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      budgetId: serializer.fromJson<int>(json['budgetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'destination': serializer.toJson<String>(destination),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'budgetId': serializer.toJson<int>(budgetId),
    };
  }

  Trip copyWith(
          {int? id,
          String? destination,
          DateTime? startDate,
          DateTime? endDate,
          int? budgetId}) =>
      Trip(
        id: id ?? this.id,
        destination: destination ?? this.destination,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        budgetId: budgetId ?? this.budgetId,
      );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      destination:
          data.destination.present ? data.destination.value : this.destination,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('destination: $destination, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('budgetId: $budgetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, destination, startDate, endDate, budgetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.destination == this.destination &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.budgetId == this.budgetId);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<int> id;
  final Value<String> destination;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int> budgetId;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.destination = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.budgetId = const Value.absent(),
  });
  TripsCompanion.insert({
    this.id = const Value.absent(),
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required int budgetId,
  })  : destination = Value(destination),
        startDate = Value(startDate),
        endDate = Value(endDate),
        budgetId = Value(budgetId);
  static Insertable<Trip> custom({
    Expression<int>? id,
    Expression<String>? destination,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? budgetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (destination != null) 'destination': destination,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (budgetId != null) 'budget_id': budgetId,
    });
  }

  TripsCompanion copyWith(
      {Value<int>? id,
      Value<String>? destination,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<int>? budgetId}) {
    return TripsCompanion(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budgetId: budgetId ?? this.budgetId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<int>(budgetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('destination: $destination, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('budgetId: $budgetId')
          ..write(')'))
        .toString();
  }
}

class $BudgetTransactionsTable extends BudgetTransactions
    with TableInfo<$BudgetTransactionsTable, BudgetTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
      'trip_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES trips (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subcategoryMeta =
      const VerificationMeta('subcategory');
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
      'subcategory', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('TND'));
  static const VerificationMeta _convertedAmountMinorMeta =
      const VerificationMeta('convertedAmountMinor');
  @override
  late final GeneratedColumn<int> convertedAmountMinor = GeneratedColumn<int>(
      'converted_amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exchangeRateMeta =
      const VerificationMeta('exchangeRate');
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
      'exchange_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isPurchasedMeta =
      const VerificationMeta('isPurchased');
  @override
  late final GeneratedColumn<bool> isPurchased = GeneratedColumn<bool>(
      'is_purchased', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_purchased" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        tripId,
        title,
        subcategory,
        amountMinor,
        currency,
        convertedAmountMinor,
        exchangeRate,
        date,
        isPurchased,
        isRecurring,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
          _subcategoryMeta,
          subcategory.isAcceptableOrUnknown(
              data['subcategory']!, _subcategoryMeta));
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('converted_amount_minor')) {
      context.handle(
          _convertedAmountMinorMeta,
          convertedAmountMinor.isAcceptableOrUnknown(
              data['converted_amount_minor']!, _convertedAmountMinorMeta));
    } else if (isInserting) {
      context.missing(_convertedAmountMinorMeta);
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
          _exchangeRateMeta,
          exchangeRate.isAcceptableOrUnknown(
              data['exchange_rate']!, _exchangeRateMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_purchased')) {
      context.handle(
          _isPurchasedMeta,
          isPurchased.isAcceptableOrUnknown(
              data['is_purchased']!, _isPurchasedMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}trip_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      subcategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subcategory']),
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      convertedAmountMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}converted_amount_minor'])!,
      exchangeRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exchange_rate'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      isPurchased: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_purchased'])!,
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $BudgetTransactionsTable createAlias(String alias) {
    return $BudgetTransactionsTable(attachedDatabase, alias);
  }
}

class BudgetTransaction extends DataClass
    implements Insertable<BudgetTransaction> {
  final int id;
  final int categoryId;
  final int? tripId;
  final String title;
  final String? subcategory;
  final int amountMinor;
  final String currency;
  final int convertedAmountMinor;
  final double exchangeRate;
  final DateTime date;
  final bool isPurchased;
  final bool isRecurring;
  final String? notes;
  const BudgetTransaction(
      {required this.id,
      required this.categoryId,
      this.tripId,
      required this.title,
      this.subcategory,
      required this.amountMinor,
      required this.currency,
      required this.convertedAmountMinor,
      required this.exchangeRate,
      required this.date,
      required this.isPurchased,
      required this.isRecurring,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['converted_amount_minor'] = Variable<int>(convertedAmountMinor);
    map['exchange_rate'] = Variable<double>(exchangeRate);
    map['date'] = Variable<DateTime>(date);
    map['is_purchased'] = Variable<bool>(isPurchased);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BudgetTransactionsCompanion toCompanion(bool nullToAbsent) {
    return BudgetTransactionsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      tripId:
          tripId == null && nullToAbsent ? const Value.absent() : Value(tripId),
      title: Value(title),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      convertedAmountMinor: Value(convertedAmountMinor),
      exchangeRate: Value(exchangeRate),
      date: Value(date),
      isPurchased: Value(isPurchased),
      isRecurring: Value(isRecurring),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory BudgetTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetTransaction(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      title: serializer.fromJson<String>(json['title']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      convertedAmountMinor:
          serializer.fromJson<int>(json['convertedAmountMinor']),
      exchangeRate: serializer.fromJson<double>(json['exchangeRate']),
      date: serializer.fromJson<DateTime>(json['date']),
      isPurchased: serializer.fromJson<bool>(json['isPurchased']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'tripId': serializer.toJson<int?>(tripId),
      'title': serializer.toJson<String>(title),
      'subcategory': serializer.toJson<String?>(subcategory),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'convertedAmountMinor': serializer.toJson<int>(convertedAmountMinor),
      'exchangeRate': serializer.toJson<double>(exchangeRate),
      'date': serializer.toJson<DateTime>(date),
      'isPurchased': serializer.toJson<bool>(isPurchased),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BudgetTransaction copyWith(
          {int? id,
          int? categoryId,
          Value<int?> tripId = const Value.absent(),
          String? title,
          Value<String?> subcategory = const Value.absent(),
          int? amountMinor,
          String? currency,
          int? convertedAmountMinor,
          double? exchangeRate,
          DateTime? date,
          bool? isPurchased,
          bool? isRecurring,
          Value<String?> notes = const Value.absent()}) =>
      BudgetTransaction(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        tripId: tripId.present ? tripId.value : this.tripId,
        title: title ?? this.title,
        subcategory: subcategory.present ? subcategory.value : this.subcategory,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        convertedAmountMinor: convertedAmountMinor ?? this.convertedAmountMinor,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        date: date ?? this.date,
        isPurchased: isPurchased ?? this.isPurchased,
        isRecurring: isRecurring ?? this.isRecurring,
        notes: notes.present ? notes.value : this.notes,
      );
  BudgetTransaction copyWithCompanion(BudgetTransactionsCompanion data) {
    return BudgetTransaction(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      title: data.title.present ? data.title.value : this.title,
      subcategory:
          data.subcategory.present ? data.subcategory.value : this.subcategory,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      convertedAmountMinor: data.convertedAmountMinor.present
          ? data.convertedAmountMinor.value
          : this.convertedAmountMinor,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      date: data.date.present ? data.date.value : this.date,
      isPurchased:
          data.isPurchased.present ? data.isPurchased.value : this.isPurchased,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetTransaction(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('subcategory: $subcategory, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('convertedAmountMinor: $convertedAmountMinor, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('date: $date, ')
          ..write('isPurchased: $isPurchased, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      categoryId,
      tripId,
      title,
      subcategory,
      amountMinor,
      currency,
      convertedAmountMinor,
      exchangeRate,
      date,
      isPurchased,
      isRecurring,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetTransaction &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.tripId == this.tripId &&
          other.title == this.title &&
          other.subcategory == this.subcategory &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.convertedAmountMinor == this.convertedAmountMinor &&
          other.exchangeRate == this.exchangeRate &&
          other.date == this.date &&
          other.isPurchased == this.isPurchased &&
          other.isRecurring == this.isRecurring &&
          other.notes == this.notes);
}

class BudgetTransactionsCompanion extends UpdateCompanion<BudgetTransaction> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<int?> tripId;
  final Value<String> title;
  final Value<String?> subcategory;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<int> convertedAmountMinor;
  final Value<double> exchangeRate;
  final Value<DateTime> date;
  final Value<bool> isPurchased;
  final Value<bool> isRecurring;
  final Value<String?> notes;
  const BudgetTransactionsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.title = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.convertedAmountMinor = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.date = const Value.absent(),
    this.isPurchased = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.notes = const Value.absent(),
  });
  BudgetTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    this.tripId = const Value.absent(),
    required String title,
    this.subcategory = const Value.absent(),
    required int amountMinor,
    this.currency = const Value.absent(),
    required int convertedAmountMinor,
    this.exchangeRate = const Value.absent(),
    required DateTime date,
    this.isPurchased = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.notes = const Value.absent(),
  })  : categoryId = Value(categoryId),
        title = Value(title),
        amountMinor = Value(amountMinor),
        convertedAmountMinor = Value(convertedAmountMinor),
        date = Value(date);
  static Insertable<BudgetTransaction> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<int>? tripId,
    Expression<String>? title,
    Expression<String>? subcategory,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? convertedAmountMinor,
    Expression<double>? exchangeRate,
    Expression<DateTime>? date,
    Expression<bool>? isPurchased,
    Expression<bool>? isRecurring,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (tripId != null) 'trip_id': tripId,
      if (title != null) 'title': title,
      if (subcategory != null) 'subcategory': subcategory,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (convertedAmountMinor != null)
        'converted_amount_minor': convertedAmountMinor,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (date != null) 'date': date,
      if (isPurchased != null) 'is_purchased': isPurchased,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (notes != null) 'notes': notes,
    });
  }

  BudgetTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<int?>? tripId,
      Value<String>? title,
      Value<String?>? subcategory,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<int>? convertedAmountMinor,
      Value<double>? exchangeRate,
      Value<DateTime>? date,
      Value<bool>? isPurchased,
      Value<bool>? isRecurring,
      Value<String?>? notes}) {
    return BudgetTransactionsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      subcategory: subcategory ?? this.subcategory,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      convertedAmountMinor: convertedAmountMinor ?? this.convertedAmountMinor,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      date: date ?? this.date,
      isPurchased: isPurchased ?? this.isPurchased,
      isRecurring: isRecurring ?? this.isRecurring,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (convertedAmountMinor.present) {
      map['converted_amount_minor'] = Variable<int>(convertedAmountMinor.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isPurchased.present) {
      map['is_purchased'] = Variable<bool>(isPurchased.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('subcategory: $subcategory, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('convertedAmountMinor: $convertedAmountMinor, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('date: $date, ')
          ..write('isPurchased: $isPurchased, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $BudgetTransactionsTable budgetTransactions =
      $BudgetTransactionsTable(this);
  late final Index budgetPeriodUnique = Index('budget_period_unique',
      'CREATE UNIQUE INDEX budget_period_unique ON budgets (category_id, period_month, period_year)');
  late final Index transactionsCategoryDate = Index(
      'transactions_category_date',
      'CREATE INDEX transactions_category_date ON transactions (category_id, date)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        budgets,
        trips,
        budgetTransactions,
        budgetPeriodUnique,
        transactionsCategoryDate
      ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String type,
  required String name,
  required String icon,
  required int colorValue,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<String> name,
  Value<String> icon,
  Value<int> colorValue,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.budgets,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.budgets.categoryId));

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager($_db, $_db.budgets)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BudgetTransactionsTable, List<BudgetTransaction>>
      _budgetTransactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.budgetTransactions,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.budgetTransactions.categoryId));

  $$BudgetTransactionsTableProcessedTableManager get budgetTransactionsRefs {
    final manager =
        $$BudgetTransactionsTableTableManager($_db, $_db.budgetTransactions)
            .filter((f) => f.categoryId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_budgetTransactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  Expression<bool> budgetsRefs(
      Expression<bool> Function($$BudgetsTableFilterComposer f) f) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableFilterComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> budgetTransactionsRefs(
      Expression<bool> Function($$BudgetTransactionsTableFilterComposer f) f) {
    final $$BudgetTransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgetTransactions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetTransactionsTableFilterComposer(
              $db: $db,
              $table: $db.budgetTransactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  Expression<T> budgetsRefs<T extends Object>(
      Expression<T> Function($$BudgetsTableAnnotationComposer a) f) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> budgetTransactionsRefs<T extends Object>(
      Expression<T> Function($$BudgetTransactionsTableAnnotationComposer a) f) {
    final $$BudgetTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.budgetTransactions,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BudgetTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.budgetTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool budgetsRefs, bool budgetTransactionsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            type: type,
            name: name,
            icon: icon,
            colorValue: colorValue,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required String name,
            required String icon,
            required int colorValue,
          }) =>
              CategoriesCompanion.insert(
            id: id,
            type: type,
            name: name,
            icon: icon,
            colorValue: colorValue,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {budgetsRefs = false, budgetTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (budgetsRefs) db.budgets,
                if (budgetTransactionsRefs) db.budgetTransactions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (budgetsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._budgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .budgetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (budgetTransactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._budgetTransactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .budgetTransactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool budgetsRefs, bool budgetTransactionsRefs})>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  Value<int> id,
  required int categoryId,
  required int amountMinor,
  Value<String> currency,
  required int periodMonth,
  required int periodYear,
  required DateTime periodStart,
  Value<DateTime?> periodEnd,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<int> id,
  Value<int> categoryId,
  Value<int> amountMinor,
  Value<String> currency,
  Value<int> periodMonth,
  Value<int> periodYear,
  Value<DateTime> periodStart,
  Value<DateTime?> periodEnd,
});

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.budgets.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TripsTable, List<Trip>> _tripsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.trips,
          aliasName: $_aliasNameGenerator(db.budgets.id, db.trips.budgetId));

  $$TripsTableProcessedTableManager get tripsRefs {
    final manager = $$TripsTableTableManager($_db, $_db.trips)
        .filter((f) => f.budgetId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_tripsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodMonth => $composableBuilder(
      column: $table.periodMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get periodYear => $composableBuilder(
      column: $table.periodYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> tripsRefs(
      Expression<bool> Function($$TripsTableFilterComposer f) f) {
    final $$TripsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.trips,
        getReferencedColumn: (t) => t.budgetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableFilterComposer(
              $db: $db,
              $table: $db.trips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodMonth => $composableBuilder(
      column: $table.periodMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get periodYear => $composableBuilder(
      column: $table.periodYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get periodMonth => $composableBuilder(
      column: $table.periodMonth, builder: (column) => column);

  GeneratedColumn<int> get periodYear => $composableBuilder(
      column: $table.periodYear, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> tripsRefs<T extends Object>(
      Expression<T> Function($$TripsTableAnnotationComposer a) f) {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.trips,
        getReferencedColumn: (t) => t.budgetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableAnnotationComposer(
              $db: $db,
              $table: $db.trips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, $$BudgetsTableReferences),
    Budget,
    PrefetchHooks Function({bool categoryId, bool tripsRefs})> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> periodMonth = const Value.absent(),
            Value<int> periodYear = const Value.absent(),
            Value<DateTime> periodStart = const Value.absent(),
            Value<DateTime?> periodEnd = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            categoryId: categoryId,
            amountMinor: amountMinor,
            currency: currency,
            periodMonth: periodMonth,
            periodYear: periodYear,
            periodStart: periodStart,
            periodEnd: periodEnd,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            required int periodMonth,
            required int periodYear,
            required DateTime periodStart,
            Value<DateTime?> periodEnd = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            amountMinor: amountMinor,
            currency: currency,
            periodMonth: periodMonth,
            periodYear: periodYear,
            periodStart: periodStart,
            periodEnd: periodEnd,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BudgetsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false, tripsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tripsRefs) db.trips],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$BudgetsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$BudgetsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tripsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$BudgetsTableReferences._tripsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BudgetsTableReferences(db, table, p0).tripsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.budgetId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTable,
    Budget,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (Budget, $$BudgetsTableReferences),
    Budget,
    PrefetchHooks Function({bool categoryId, bool tripsRefs})>;
typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  Value<int> id,
  required String destination,
  required DateTime startDate,
  required DateTime endDate,
  required int budgetId,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<int> id,
  Value<String> destination,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<int> budgetId,
});

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, Trip> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BudgetsTable _budgetIdTable(_$AppDatabase db) => db.budgets
      .createAlias($_aliasNameGenerator(db.trips.budgetId, db.budgets.id));

  $$BudgetsTableProcessedTableManager get budgetId {
    final manager = $$BudgetsTableTableManager($_db, $_db.budgets)
        .filter((f) => f.id($_item.budgetId));
    final item = $_typedResult.readTableOrNull(_budgetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BudgetTransactionsTable, List<BudgetTransaction>>
      _budgetTransactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.budgetTransactions,
              aliasName: $_aliasNameGenerator(
                  db.trips.id, db.budgetTransactions.tripId));

  $$BudgetTransactionsTableProcessedTableManager get budgetTransactionsRefs {
    final manager =
        $$BudgetTransactionsTableTableManager($_db, $_db.budgetTransactions)
            .filter((f) => f.tripId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_budgetTransactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  $$BudgetsTableFilterComposer get budgetId {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableFilterComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> budgetTransactionsRefs(
      Expression<bool> Function($$BudgetTransactionsTableFilterComposer f) f) {
    final $$BudgetTransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgetTransactions,
        getReferencedColumn: (t) => t.tripId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetTransactionsTableFilterComposer(
              $db: $db,
              $table: $db.budgetTransactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  $$BudgetsTableOrderingComposer get budgetId {
    final $$BudgetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableOrderingComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$BudgetsTableAnnotationComposer get budgetId {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> budgetTransactionsRefs<T extends Object>(
      Expression<T> Function($$BudgetTransactionsTableAnnotationComposer a) f) {
    final $$BudgetTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.budgetTransactions,
            getReferencedColumn: (t) => t.tripId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BudgetTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.budgetTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TripsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TripsTable,
    Trip,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (Trip, $$TripsTableReferences),
    Trip,
    PrefetchHooks Function({bool budgetId, bool budgetTransactionsRefs})> {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> destination = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<int> budgetId = const Value.absent(),
          }) =>
              TripsCompanion(
            id: id,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            budgetId: budgetId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String destination,
            required DateTime startDate,
            required DateTime endDate,
            required int budgetId,
          }) =>
              TripsCompanion.insert(
            id: id,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            budgetId: budgetId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TripsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {budgetId = false, budgetTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (budgetTransactionsRefs) db.budgetTransactions
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (budgetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.budgetId,
                    referencedTable: $$TripsTableReferences._budgetIdTable(db),
                    referencedColumn:
                        $$TripsTableReferences._budgetIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (budgetTransactionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TripsTableReferences
                            ._budgetTransactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TripsTableReferences(db, table, p0)
                                .budgetTransactionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tripId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TripsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TripsTable,
    Trip,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (Trip, $$TripsTableReferences),
    Trip,
    PrefetchHooks Function({bool budgetId, bool budgetTransactionsRefs})>;
typedef $$BudgetTransactionsTableCreateCompanionBuilder
    = BudgetTransactionsCompanion Function({
  Value<int> id,
  required int categoryId,
  Value<int?> tripId,
  required String title,
  Value<String?> subcategory,
  required int amountMinor,
  Value<String> currency,
  required int convertedAmountMinor,
  Value<double> exchangeRate,
  required DateTime date,
  Value<bool> isPurchased,
  Value<bool> isRecurring,
  Value<String?> notes,
});
typedef $$BudgetTransactionsTableUpdateCompanionBuilder
    = BudgetTransactionsCompanion Function({
  Value<int> id,
  Value<int> categoryId,
  Value<int?> tripId,
  Value<String> title,
  Value<String?> subcategory,
  Value<int> amountMinor,
  Value<String> currency,
  Value<int> convertedAmountMinor,
  Value<double> exchangeRate,
  Value<DateTime> date,
  Value<bool> isPurchased,
  Value<bool> isRecurring,
  Value<String?> notes,
});

final class $$BudgetTransactionsTableReferences extends BaseReferences<
    _$AppDatabase, $BudgetTransactionsTable, BudgetTransaction> {
  $$BudgetTransactionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.budgetTransactions.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
      $_aliasNameGenerator(db.budgetTransactions.tripId, db.trips.id));

  $$TripsTableProcessedTableManager? get tripId {
    if ($_item.tripId == null) return null;
    final manager = $$TripsTableTableManager($_db, $_db.trips)
        .filter((f) => f.id($_item.tripId!));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BudgetTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetTransactionsTable> {
  $$BudgetTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get convertedAmountMinor => $composableBuilder(
      column: $table.convertedAmountMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPurchased => $composableBuilder(
      column: $table.isPurchased, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.trips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableFilterComposer(
              $db: $db,
              $table: $db.trips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetTransactionsTable> {
  $$BudgetTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get convertedAmountMinor => $composableBuilder(
      column: $table.convertedAmountMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPurchased => $composableBuilder(
      column: $table.isPurchased, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.trips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableOrderingComposer(
              $db: $db,
              $table: $db.trips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetTransactionsTable> {
  $$BudgetTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get convertedAmountMinor => $composableBuilder(
      column: $table.convertedAmountMinor, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
      column: $table.exchangeRate, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isPurchased => $composableBuilder(
      column: $table.isPurchased, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tripId,
        referencedTable: $db.trips,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TripsTableAnnotationComposer(
              $db: $db,
              $table: $db.trips,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetTransactionsTable,
    BudgetTransaction,
    $$BudgetTransactionsTableFilterComposer,
    $$BudgetTransactionsTableOrderingComposer,
    $$BudgetTransactionsTableAnnotationComposer,
    $$BudgetTransactionsTableCreateCompanionBuilder,
    $$BudgetTransactionsTableUpdateCompanionBuilder,
    (BudgetTransaction, $$BudgetTransactionsTableReferences),
    BudgetTransaction,
    PrefetchHooks Function({bool categoryId, bool tripId})> {
  $$BudgetTransactionsTableTableManager(
      _$AppDatabase db, $BudgetTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int?> tripId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> subcategory = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> convertedAmountMinor = const Value.absent(),
            Value<double> exchangeRate = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> isPurchased = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              BudgetTransactionsCompanion(
            id: id,
            categoryId: categoryId,
            tripId: tripId,
            title: title,
            subcategory: subcategory,
            amountMinor: amountMinor,
            currency: currency,
            convertedAmountMinor: convertedAmountMinor,
            exchangeRate: exchangeRate,
            date: date,
            isPurchased: isPurchased,
            isRecurring: isRecurring,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            Value<int?> tripId = const Value.absent(),
            required String title,
            Value<String?> subcategory = const Value.absent(),
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            required int convertedAmountMinor,
            Value<double> exchangeRate = const Value.absent(),
            required DateTime date,
            Value<bool> isPurchased = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              BudgetTransactionsCompanion.insert(
            id: id,
            categoryId: categoryId,
            tripId: tripId,
            title: title,
            subcategory: subcategory,
            amountMinor: amountMinor,
            currency: currency,
            convertedAmountMinor: convertedAmountMinor,
            exchangeRate: exchangeRate,
            date: date,
            isPurchased: isPurchased,
            isRecurring: isRecurring,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BudgetTransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false, tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable: $$BudgetTransactionsTableReferences
                        ._categoryIdTable(db),
                    referencedColumn: $$BudgetTransactionsTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (tripId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tripId,
                    referencedTable:
                        $$BudgetTransactionsTableReferences._tripIdTable(db),
                    referencedColumn:
                        $$BudgetTransactionsTableReferences._tripIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BudgetTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetTransactionsTable,
    BudgetTransaction,
    $$BudgetTransactionsTableFilterComposer,
    $$BudgetTransactionsTableOrderingComposer,
    $$BudgetTransactionsTableAnnotationComposer,
    $$BudgetTransactionsTableCreateCompanionBuilder,
    $$BudgetTransactionsTableUpdateCompanionBuilder,
    (BudgetTransaction, $$BudgetTransactionsTableReferences),
    BudgetTransaction,
    PrefetchHooks Function({bool categoryId, bool tripId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$BudgetTransactionsTableTableManager get budgetTransactions =>
      $$BudgetTransactionsTableTableManager(_db, _db.budgetTransactions);
}
