import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/budget_providers.dart';

class RecurringRulesScreen extends ConsumerWidget {
  const RecurringRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(recurringRulesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Expenses'),
        actions: [
          IconButton(
            tooltip: 'Process due rules',
            onPressed: () async {
              await ref
                  .read(budgetRepositoryProvider)
                  .processDueRecurringRules(DateTime.now());
              ref.invalidate(recurringRulesProvider);
              ref.invalidate(dashboardProvider);
            },
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: rules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load recurring rules: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No recurring expenses configured.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: items
                    .map(
                      (rule) => Card(
                        elevation: 0,
                        child: ListTile(
                          leading:
                              const CircleAvatar(child: Icon(Icons.repeat)),
                          title: Text(rule.title),
                          subtitle: Text(
                            '${rule.frequency} · Next ${phaseFiveShortDate(rule.nextDueDate)}',
                          ),
                          trailing: Consumer(builder: (context, ref, _) {
                            final curr = ref.watch(appCurrencyProvider);
                            return Text(formatAmount(rule.amountMinor, curr));
                          }),
                          onLongPress: () async {
                            await ref
                                .read(budgetRepositoryProvider)
                                .deactivateRecurringRule(rule.id);
                            ref.invalidate(recurringRulesProvider);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add recurring expense',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AddRecurringRuleDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddRecurringRuleDialog extends ConsumerStatefulWidget {
  const AddRecurringRuleDialog({super.key});

  @override
  ConsumerState<AddRecurringRuleDialog> createState() =>
      _AddRecurringRuleDialogState();
}

class _AddRecurringRuleDialogState
    extends ConsumerState<AddRecurringRuleDialog> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String category = 'monthly';
  String frequency = 'monthly';
  String currency = 'TND';
  DateTime nextDueDate = DateTime.now();

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = phaseFiveParseCurrencyMinor(amountController.text, currency);
    if (titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      return;
    }
    await ref.read(budgetRepositoryProvider).addRecurringRule(
          title: titleController.text.trim(),
          categoryType: category,
          subcategory: '',
          amountMinor: amount,
          currency: currency,
          frequency: frequency,
          nextDueDate: nextDueDate,
        );
    ref.invalidate(recurringRulesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add recurring expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount ($currency)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(
                    value: 'monthly', child: Text('Monthly Expenses')),
                DropdownMenuItem(
                    value: 'special', child: Text('Special Purchases')),
                DropdownMenuItem(value: 'travel', child: Text('Travel')),
              ],
              onChanged: (value) =>
                  setState(() => category = value ?? 'monthly'),
            ),
            DropdownButtonFormField<String>(
              value: frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: const [
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (value) =>
                  setState(() => frequency = value ?? 'monthly'),
            ),
            DropdownButtonFormField<String>(
              value: currency,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: const [
                DropdownMenuItem(value: 'TND', child: Text('TND')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
              ],
              onChanged: (value) => setState(() => currency = value ?? 'TND'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: nextDueDate,
                );
                if (date != null) setState(() => nextDueDate = date);
              },
              icon: const Icon(Icons.event),
              label: Text('Next due ${phaseFiveShortDate(nextDueDate)}'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(onPressed: save, child: const Text('Save')),
      ],
    );
  }
}

int? phaseFiveParseCurrencyMinor(String value, String currency) {
  final amount = double.tryParse(value.replaceAll(',', '.'));
  if (amount == null) return null;
  return (amount * (currency == 'TND' ? 1000 : 100)).round();
}

String phaseFiveShortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
