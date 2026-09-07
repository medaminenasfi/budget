import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../logic/budget_providers.dart';

class DebtTrackerScreen extends ConsumerWidget {
  const DebtTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Tracker'),
        actions: [
          IconButton(
            tooltip: 'Exchange rates',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const ExchangeRateDialog(),
            ),
            icon: const Icon(Icons.currency_exchange),
          ),
        ],
      ),
      body: debts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load debts: $error')),
        data: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DebtTotals(items: items),
            const SizedBox(height: 18),
            if (items.isEmpty)
              const Center(child: Text('No active debts.'))
            else
              ...items.map(
                (debt) => Dismissible(
                  key: ValueKey(debt.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red.shade100,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline),
                  ),
                  onDismissed: (_) async {
                    await ref
                        .read(budgetRepositoryProvider)
                        .deleteDebt(debt.id);
                    ref.invalidate(debtsProvider);
                  },
                  child: Card(
                    elevation: 0,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(debt.direction == 'i_owe'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward),
                      ),
                      title: Text(debt.personName),
                      subtitle: Text(
                        debt.direction == 'i_owe'
                            ? 'I owe${debt.dueDate == null ? '' : ' · Due ${debtShortDate(debt.dueDate!)}'}'
                            : 'Owed to me${debt.dueDate == null ? '' : ' · Due ${debtShortDate(debt.dueDate!)}'}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatDebtAmount(debt)),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(budgetRepositoryProvider)
                                  .settleDebt(debt.id);
                              ref.invalidate(debtsProvider);
                              ref.invalidate(settledDebtsProvider);
                            },
                            child: const Text('Settle'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add debt',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AddDebtDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DebtTotals extends StatelessWidget {
  const _DebtTotals({required this.items});

  final List<Debt> items;

  @override
  Widget build(BuildContext context) {
    final owe = items
        .where((debt) => debt.direction == 'i_owe')
        .fold<int>(0, (sum, debt) => sum + debt.convertedAmountMinor);
    final owed = items
        .where((debt) => debt.direction == 'owed_to_me')
        .fold<int>(0, (sum, debt) => sum + debt.convertedAmountMinor);
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(child: _metric('I owe', owe)),
            Expanded(child: _metric('Owed to me', owed)),
            Expanded(child: _metric('Net', owe - owed)),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, int amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(formatTnd(amount),
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class AddDebtDialog extends ConsumerStatefulWidget {
  const AddDebtDialog({super.key});

  @override
  ConsumerState<AddDebtDialog> createState() => _AddDebtDialogState();
}

class _AddDebtDialogState extends ConsumerState<AddDebtDialog> {
  final personController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  String direction = 'i_owe';
  String currency = 'TND';
  DateTime? dueDate;

  @override
  void dispose() {
    personController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = parseCurrencyMinor(amountController.text, currency);
    if (personController.text.trim().isEmpty || amount == null || amount <= 0) {
      return;
    }
    await ref.read(budgetRepositoryProvider).addDebt(
          personName: personController.text.trim(),
          direction: direction,
          amountMinor: amount,
          currency: currency,
          dueDate: dueDate,
          notes: notesController.text.trim().isEmpty
              ? null
              : notesController.text.trim(),
        );
    ref.invalidate(debtsProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add debt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: personController,
              decoration: const InputDecoration(labelText: 'Person'),
            ),
            DropdownButtonFormField<String>(
              value: direction,
              decoration: const InputDecoration(labelText: 'Direction'),
              items: const [
                DropdownMenuItem(value: 'i_owe', child: Text('I owe')),
                DropdownMenuItem(
                    value: 'owed_to_me', child: Text('Owed to me')),
              ],
              onChanged: (value) =>
                  setState(() => direction = value ?? 'i_owe'),
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
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount ($currency)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: dueDate ?? DateTime.now(),
                );
                if (selected != null) setState(() => dueDate = selected);
              },
              icon: const Icon(Icons.event),
              label:
                  Text(dueDate == null ? 'Due date' : debtShortDate(dueDate!)),
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

class ExchangeRateDialog extends ConsumerStatefulWidget {
  const ExchangeRateDialog({super.key});

  @override
  ConsumerState<ExchangeRateDialog> createState() => _ExchangeRateDialogState();
}

class _ExchangeRateDialogState extends ConsumerState<ExchangeRateDialog> {
  final rateController = TextEditingController();
  String currency = 'EUR';

  @override
  void dispose() {
    rateController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final rate = double.tryParse(rateController.text.replaceAll(',', '.'));
    if (rate == null || rate <= 0) return;
    await ref.read(budgetRepositoryProvider).setExchangeRate(
          currency: currency,
          rate: rate,
        );
    ref.invalidate(exchangeRatesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set exchange rate'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: currency,
            items: const [
              DropdownMenuItem(value: 'EUR', child: Text('EUR to TND')),
              DropdownMenuItem(value: 'USD', child: Text('USD to TND')),
            ],
            onChanged: (value) => setState(() => currency = value ?? 'EUR'),
          ),
          TextField(
            controller: rateController,
            decoration: const InputDecoration(labelText: '1 currency = TND'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
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

int? parseCurrencyMinor(String value, String currency) {
  final amount = double.tryParse(value.replaceAll(',', '.'));
  if (amount == null) return null;
  return (amount * (currency == 'TND' ? 1000 : 100)).round();
}

String formatDebtAmount(Debt debt) {
  final divisor = debt.currency == 'TND' ? 1000 : 100;
  return '${(debt.amountMinor / divisor).toStringAsFixed(2)} ${debt.currency}';
}

String debtShortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
