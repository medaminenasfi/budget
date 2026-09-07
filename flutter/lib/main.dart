import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/budget_repository.dart';
import 'logic/budget_providers.dart';

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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Budget'),
        actions: [
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
    final isMonthly = summary.category.type == 'monthly';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: color.withAlpha(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isMonthly
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MonthlyExpensesScreen(),
                  ),
                )
            : null,
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
              if (isMonthly) const Icon(Icons.chevron_right),
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
    final expenses = ref.watch(monthlyExpensesProvider);
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
      body: expenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load expenses: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No expenses yet. Add your first one.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Dismissible(
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
                      ref.invalidate(dashboardProvider);
                    },
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(item.title),
                      subtitle: Text(item.subcategory ?? 'General'),
                      trailing: Text(formatTnd(item.amountMinor)),
                    ),
                  );
                },
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

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
    if (titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      return;
    }
    await ref.read(budgetRepositoryProvider).addMonthlyExpense(
          title: titleController.text.trim(),
          subcategory: categoryController.text.trim(),
          amountMinor: (amount * 1000).round(),
          date: DateTime.now(),
        );
    ref.invalidate(monthlyExpensesProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount (TND)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
    default:
      return Icons.calendar_month;
  }
}
