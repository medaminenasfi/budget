import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'data/local/database.dart';
import 'data/repositories/budget_repository.dart';
import 'logic/budget_providers.dart';
import 'presentation/phase_two_screens.dart';
import 'presentation/phase_three_widgets.dart';
import 'presentation/phase_four_screens.dart';
import 'presentation/phase_five_screens.dart';

void main() {
  runApp(const ProviderScope(child: SmartBudgetApp()));
}

class SmartBudgetApp extends StatelessWidget {
  const SmartBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Budget Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6690),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5F0),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class _MonthlyBudgetSummary extends StatelessWidget {
  const _MonthlyBudgetSummary({required this.summary});

  final CategorySummary summary;

  @override
  Widget build(BuildContext context) {
    final remaining = summary.remainingMinor;
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_monthName(DateTime.now().month)} ${DateTime.now().year}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _BudgetMetric(
                  label: 'Budget',
                  value: summary.budgetMinor == null
                      ? 'Not set'
                      : formatTnd(summary.budgetMinor!),
                ),
                _BudgetMetric(
                  label: 'Spent',
                  value: formatTnd(summary.spentMinor),
                ),
                _BudgetMetric(
                  label: 'Remaining',
                  value: summary.budgetMinor == null
                      ? 'Not set'
                      : formatTnd(remaining),
                  valueColor: remaining < 0 ? Colors.red.shade700 : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

String _monthName(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return names[month - 1];
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final trend = ref.watch(sixMonthTrendProvider);
    final alerts = ref.watch(budgetAlertsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Budget'),
        actions: [
          IconButton(
            tooltip: 'Recurring expenses',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecurringRulesScreen()),
            ),
            icon: const Icon(Icons.repeat),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load budget: $error')),
        data: (summaries) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            children: [
              Text(
                'Your budget summary',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'This month in TND',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 22),
              ...summaries.map((summary) => _SummaryCard(summary: summary)),
              alerts.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : Card(
                        color: Colors.amber.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.warning_amber),
                          title: const Text('Budget alerts'),
                          subtitle: Text(items
                              .map((item) =>
                                  '${item.categoryName}: ${item.percentUsed}% used')
                              .join('\n')),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              trend.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (points) => SixMonthTrendChart(points: points),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MonthlyExpensesScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final CategorySummary summary;

  @override
  Widget build(BuildContext context) {
    final color = Color(summary.category.colorValue);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: color.withAlpha(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openCategory(context, summary.category.type),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                foregroundColor: Colors.white,
                child: Icon(_iconFor(summary.category.icon)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.category.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Spent ${formatTnd(summary.spentMinor)}'),
                    Text(
                      summary.budgetMinor == null
                          ? 'No budget set'
                          : 'Remaining ${formatTnd(summary.remainingMinor)}',
                      style: TextStyle(
                        color: summary.remainingMinor < 0
                            ? Colors.red.shade700
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class MonthlyExpensesScreen extends ConsumerWidget {
  const MonthlyExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthlySummaryProvider);
    final expenses = ref.watch(filteredMonthlyExpensesProvider);
    final allExpenses = ref.watch(monthlyExpensesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expenses'),
        actions: [
          IconButton(
            tooltip: 'Set monthly budget',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const SetBudgetDialog(),
            ),
            icon: const Icon(Icons.account_balance_wallet_outlined),
          ),
        ],
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load monthly budget: $error')),
        data: (monthlySummary) => expenses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Could not load expenses: $error')),
          data: (items) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MonthlyBudgetSummary(summary: monthlySummary),
              const SizedBox(height: 18),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search expenses',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ref.watch(monthlySearchProvider).isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () => ref
                              .read(monthlySearchProvider.notifier)
                              .state = '',
                          icon: const Icon(Icons.clear),
                        ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    ref.read(monthlySearchProvider.notifier).state = value,
              ),
              const SizedBox(height: 18),
              _MonthlyFilterBar(
                allItems: allExpenses.valueOrNull ?? const [],
              ),
              const SizedBox(height: 18),
              SpendingPieChart(items: items),
              if (items.isNotEmpty) const SizedBox(height: 18),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('No expenses yet. Add your first one.'),
                  ),
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ValueKey(item.id),
                      background: Container(
                        color: Colors.red.shade100,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_outline),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) async {
                        await ref
                            .read(budgetRepositoryProvider)
                            .deleteExpense(item.id);
                        ref.invalidate(monthlyExpensesProvider);
                        ref.invalidate(monthlySummaryProvider);
                        ref.invalidate(dashboardProvider);
                      },
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Text(item.title),
                        subtitle: Text(item.subcategory ?? 'General'),
                        trailing: Text(formatTnd(item.amountMinor)),
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (_) => AddExpenseDialog(initial: item),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add expense',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AddExpenseDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MonthlyFilterBar extends StatelessWidget {
  const _MonthlyFilterBar({required this.allItems});

  final List<BudgetTransaction> allItems;

  @override
  Widget build(BuildContext context) {
    final categories = allItems
        .map((item) => item.subcategory)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return Consumer(
      builder: (context, ref, child) {
        final selected = ref.watch(monthlyCategoryProvider);
        final dateRange = ref.watch(monthlyDateRangeProvider);
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min TND',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => ref
                        .read(monthlyMinAmountProvider.notifier)
                        .state = parseTnd(value)?.toString() ?? '',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max TND',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => ref
                        .read(monthlyMaxAmountProvider.notifier)
                        .state = parseTnd(value)?.toString() ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selected,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All categories'),
                      ),
                      ...categories.map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      ),
                    ],
                    onChanged: (value) => ref
                        .read(monthlyCategoryProvider.notifier)
                        .state = value,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selectedRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(DateTime.now().year - 2),
                      lastDate: DateTime.now(),
                      initialDateRange: dateRange,
                    );
                    if (selectedRange != null) {
                      ref.read(monthlyDateRangeProvider.notifier).state =
                          selectedRange;
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    dateRange == null
                        ? 'Dates'
                        : '${shortDate(dateRange.start)} - ${shortDate(dateRange.end)}',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key, this.initial});

  final BudgetTransaction? initial;

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final amountController = TextEditingController();
  String currency = 'TND';
  double rate = 1;
  String? receiptPhotoPath;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      currency = initial.currency;
      receiptPhotoPath = initial.receiptPhotoPath;
      titleController.text = initial.title;
      categoryController.text = initial.subcategory ?? '';
      amountController.text =
          (initial.amountMinor / (currency == 'TND' ? 1000 : 100))
              .toStringAsFixed(2);
    }
    _loadRate();
  }

  Future<void> _loadRate() async {
    final loadedRate =
        await ref.read(budgetRepositoryProvider).exchangeRate(currency);
    if (mounted) setState(() => rate = loadedRate);
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amountMinor = parseCurrencyMinor(amountController.text, currency);
    if (titleController.text.trim().isEmpty ||
        amountMinor == null ||
        amountMinor <= 0) {
      return;
    }
    final repository = ref.read(budgetRepositoryProvider);
    if (widget.initial == null) {
      await repository.addMonthlyExpense(
        title: titleController.text.trim(),
        subcategory: categoryController.text.trim(),
        amountMinor: amountMinor,
        currency: currency,
        receiptPhotoPath: receiptPhotoPath,
        date: DateTime.now(),
      );
    } else {
      await repository.updateMonthlyExpense(
        id: widget.initial!.id,
        title: titleController.text.trim(),
        subcategory: categoryController.text.trim(),
        amountMinor: amountMinor,
        currency: currency,
        receiptPhotoPath: receiptPhotoPath,
      );
    }
    ref.invalidate(monthlyExpensesProvider);
    ref.invalidate(monthlySummaryProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add expense' : 'Edit expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
            ),
            DropdownButtonFormField<String>(
              value: currency,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: const [
                DropdownMenuItem(value: 'TND', child: Text('TND')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
              ],
              onChanged: (value) {
                setState(() => currency = value ?? 'TND');
                _loadRate();
              },
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount ($currency)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            Text(
                'Converted preview: ${formatTnd(((parseCurrencyMinor(amountController.text, currency) ?? 0) * rate * (currency == 'TND' ? 1 : 10)).round())}'),
            OutlinedButton.icon(
              onPressed: () async {
                final file = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (file != null) setState(() => receiptPhotoPath = file.path);
              },
              icon: const Icon(Icons.receipt_long),
              label: Text(receiptPhotoPath == null
                  ? 'Attach receipt'
                  : 'Receipt attached'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: save, child: const Text('Save')),
      ],
    );
  }
}

class SetBudgetDialog extends ConsumerStatefulWidget {
  const SetBudgetDialog({super.key});

  @override
  ConsumerState<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends ConsumerState<SetBudgetDialog> {
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;
    await ref.read(budgetRepositoryProvider).setMonthlyBudget(
          amountMinor: (amount * 1000).round(),
          period: DateTime.now(),
        );
    ref.invalidate(monthlySummaryProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set monthly budget'),
      content: TextField(
        controller: amountController,
        decoration: const InputDecoration(labelText: 'Budget (TND)'),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: save, child: const Text('Save')),
      ],
    );
  }
}

IconData _iconFor(String icon) {
  switch (icon) {
    case 'shopping_bag':
      return Icons.shopping_bag_outlined;
    case 'flight_takeoff':
      return Icons.flight_takeoff;
    case 'savings':
      return Icons.savings_outlined;
    case 'account_balance':
      return Icons.account_balance_outlined;
    default:
      return Icons.calendar_month;
  }
}

void _openCategory(BuildContext context, String type) {
  final Widget screen;
  switch (type) {
    case 'special':
      screen = const SpecialPurchasesScreen();
      break;
    case 'travel':
      screen = const TravelScreen();
      break;
    case 'savings':
      screen = const SavingsScreen();
      break;
    case 'debt':
      screen = const DebtTrackerScreen();
      break;
    default:
      screen = const MonthlyExpensesScreen();
  }
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}
