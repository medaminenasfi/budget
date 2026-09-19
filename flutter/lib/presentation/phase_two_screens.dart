import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/repositories/budget_repository.dart';
import '../logic/budget_providers.dart';
import 'phase_three_widgets.dart';
import 'phase_four_screens.dart';

class SpecialPurchasesScreen extends ConsumerWidget {
  const SpecialPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(specialSummaryProvider);
    final items = ref.watch(specialPurchasesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Special Purchases')),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load purchases: $error')),
        data: (purchaseSummary) => items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Could not load items: $error')),
          data: (list) {
            final query = ref.watch(specialSearchProvider).toLowerCase();
            final visible = list
                .where((item) =>
                    query.isEmpty || item.title.toLowerCase().contains(query))
                .toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PhaseTwoSummary(
                  summary: purchaseSummary,
                  budgetLabel: 'Target',
                  spentLabel: 'Funded',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add an item and its price, then add money until you reach the full amount.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search purchases',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      ref.read(specialSearchProvider.notifier).state = value,
                ),
                const SizedBox(height: 18),
                if (visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                        child: Text('No special purchases yet. Add one.')),
                  )
                else
                  ...visible.map(
                    (item) => Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: _deleteBackground(),
                      onDismissed: (_) async {
                        await ref
                            .read(budgetRepositoryProvider)
                            .deleteSpecialPurchase(item.id);
                        ref.invalidate(specialPurchasesProvider);
                        ref.invalidate(specialSummaryProvider);
                        ref.invalidate(dashboardProvider);
                      },
                      child: _FundingItemCard(
                        item: item,
                        onAddMoney: () => showDialog<void>(
                          context: context,
                          builder: (_) => ContributeDialog(
                            item: item,
                            title: 'Add money to ${item.title}',
                            onSave: (amount) async {
                              await ref
                                  .read(budgetRepositoryProvider)
                                  .contributeToSpecialPurchase(
                                    item: item,
                                    addMinor: amount,
                                  );
                              ref.invalidate(specialPurchasesProvider);
                              ref.invalidate(specialSummaryProvider);
                              ref.invalidate(dashboardProvider);
                            },
                          ),
                        ),
                        onEdit: () => showDialog<void>(
                          context: context,
                          builder: (_) =>
                              AddSpecialPurchaseDialog(initial: item),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add special purchase',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AddSpecialPurchaseDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add purchase'),
      ),
    );
  }
}

class AddSpecialPurchaseDialog extends ConsumerStatefulWidget {
  const AddSpecialPurchaseDialog({super.key, this.initial});

  final BudgetTransaction? initial;

  @override
  ConsumerState<AddSpecialPurchaseDialog> createState() =>
      _AddSpecialPurchaseDialogState();
}

class _AddSpecialPurchaseDialogState
    extends ConsumerState<AddSpecialPurchaseDialog> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String currency = 'TND';
  double rate = 1;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      titleController.text = initial.title;
      currency = initial.currency;
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
    amountController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = parseCurrencyMinor(amountController.text, currency);
    if (titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      return;
    }
    final repository = ref.read(budgetRepositoryProvider);
    if (widget.initial == null) {
      await repository.addSpecialPurchase(
        title: titleController.text.trim(),
        amountMinor: amount,
        currency: currency,
      );
    } else {
      await repository.updateSpecialPurchase(
        id: widget.initial!.id,
        title: titleController.text.trim(),
        amountMinor: amount,
        currency: currency,
      );
    }
    ref.invalidate(specialPurchasesProvider);
    ref.invalidate(specialSummaryProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final preview =
        parseCurrencyMinor(amountController.text, currency) ?? 0;
    return AlertDialog(
      title: Text(widget.initial == null
          ? 'Add special purchase'
          : 'Edit purchase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Item name'),
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
            controller: amountController,
            decoration:
                InputDecoration(labelText: 'Target price ($currency)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Consumer(builder: (context, ref, _) {
            final appCurr = ref.watch(appCurrencyProvider);
            return Text(
              'Preview: ${formatAmount(convertPreview(preview, currency, rate), appCurr)}',
              style: const TextStyle(color: Colors.black54),
            );
          }),
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

int convertPreview(int amountMinor, String currency, double rate) {
  if (currency == 'TND') return amountMinor;
  return (amountMinor * rate * 10).round();
}

class ContributeDialog extends ConsumerStatefulWidget {
  const ContributeDialog({
    required this.item,
    required this.title,
    required this.onSave,
    super.key,
  });

  final BudgetTransaction item;
  final String title;
  final Future<void> Function(int addMinor) onSave;

  @override
  ConsumerState<ContributeDialog> createState() => _ContributeDialogState();
}

class _ContributeDialogState extends ConsumerState<ContributeDialog> {
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount =
        parseCurrencyMinor(amountController.text, widget.item.currency);
    if (amount == null || amount <= 0) return;
    await widget.onSave(amount);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final saved = fundedAmount(
      widget.item.notes,
      targetMinor: widget.item.amountMinor,
      completed: widget.item.isPurchased,
    );
    final remaining = (widget.item.amountMinor - saved).clamp(0, 1 << 30);
    final curr = widget.item.currency;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target ${formatAmount(widget.item.amountMinor, curr)} · '
            'Saved ${formatAmount(saved, curr)} · '
            'Remaining ${formatAmount(remaining, curr)}',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Add money ($curr)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: save, child: const Text('Add')),
      ],
    );
  }
}

class _FundingItemCard extends ConsumerWidget {
  const _FundingItemCard({
    required this.item,
    required this.onAddMoney,
    required this.onEdit,
  });

  final BudgetTransaction item;
  final VoidCallback onAddMoney;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(appCurrencyProvider);
    final saved = fundedAmount(
      item.notes,
      targetMinor: item.amountMinor,
      completed: item.isPurchased,
    );
    final remaining = item.amountMinor - saved;
    final progress =
        item.amountMinor == 0 ? 0.0 : (saved / item.amountMinor).clamp(0.0, 1.0);
    final done = item.isPurchased || remaining <= 0;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              done
                  ? 'Completed ${formatAmount(item.amountMinor, currency)}'
                  : 'Saved ${formatAmount(saved, currency)} · Remaining ${formatAmount(remaining, currency)}',
              style: TextStyle(
                color: done ? Colors.green.shade700 : Colors.black54,
              ),
            ),
            if (!done)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onAddMoney,
                  icon: const Icon(Icons.add),
                  label: const Text('Add money'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TravelScreen extends ConsumerWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Travel')),
      body: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load trips: $error')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('No trips yet. Add your first trip.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final progress = list[index];
                  final trip = progress.trip;
                  return Dismissible(
                    key: ValueKey(trip.id),
                    direction: DismissDirection.endToStart,
                    background: _deleteBackground(),
                    onDismissed: (_) async {
                      await ref.read(budgetRepositoryProvider).deleteTrip(trip);
                      ref.invalidate(tripsProvider);
                      ref.invalidate(dashboardProvider);
                    },
                    child: Card(
                      elevation: 0,
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.flight)),
                        title: Text(trip.destination),
                        subtitle: Consumer(builder: (context, ref, _) {
                          final curr = ref.watch(appCurrencyProvider);
                          return Text(
                            '${shortDate(trip.startDate)} - ${shortDate(trip.endDate)}\n'
                            'Budget ${formatAmount(progress.budgetMinor, curr)} · '
                            'Remaining ${formatAmount(progress.remainingMinor, curr)}',
                          );
                        }),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Edit trip',
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => AddTripDialog(initial: trip),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TripDetailsScreen(trip: trip),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add trip',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AddTripDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTripDialog extends ConsumerStatefulWidget {
  const AddTripDialog({super.key, this.initial});

  final Trip? initial;

  @override
  ConsumerState<AddTripDialog> createState() => _AddTripDialogState();
}

class _AddTripDialogState extends ConsumerState<AddTripDialog> {
  final destinationController = TextEditingController();
  final budgetController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      destinationController.text = initial.destination;
      startDate = initial.startDate;
      endDate = initial.endDate;
    }
  }

  @override
  void dispose() {
    destinationController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final budget = parseTnd(budgetController.text);
    if (destinationController.text.trim().isEmpty ||
        budget == null ||
        budget <= 0) {
      return;
    }
    final repository = ref.read(budgetRepositoryProvider);
    if (widget.initial == null) {
      await repository.addTrip(
        destination: destinationController.text.trim(),
        startDate: startDate,
        endDate: endDate,
        budgetMinor: budget,
      );
    } else {
      await repository.updateTrip(
        trip: widget.initial!,
        destination: destinationController.text.trim(),
        startDate: startDate,
        endDate: endDate,
        budgetMinor: budget,
      );
    }
    ref.invalidate(tripsProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final budget = parseTnd(budgetController.text) ?? 0;
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add trip' : 'Edit trip'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: destinationController,
            decoration: const InputDecoration(labelText: 'Destination'),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: budgetController,
            decoration: const InputDecoration(labelText: 'Budget (TND)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Consumer(builder: (context, ref, _) {
            final curr = ref.watch(appCurrencyProvider);
            return Text(
              'Preview: ${destinationController.text.trim().isEmpty ? 'New trip' : destinationController.text.trim()}\n'
              'Budget ${formatAmount(budget, curr)} · Remaining ${formatAmount(budget, curr)} (no expenses yet)',
              style: const TextStyle(color: Colors.black54),
            );
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isStart: true),
                  child: Text('Start ${shortDate(startDate)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isStart: false),
                  child: Text('End ${shortDate(endDate)}'),
                ),
              ),
            ],
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

  Future<void> _pickDate({required bool isStart}) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: isStart ? startDate : endDate,
    );
    if (selected == null) return;
    setState(() {
      if (isStart) {
        startDate = selected;
        if (endDate.isBefore(startDate)) endDate = startDate;
      } else {
        endDate = selected.isBefore(startDate) ? startDate : selected;
      }
    });
  }
}

class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({required this.trip, super.key});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(tripBudgetProvider(trip.budgetId));
    final expenses = ref.watch(travelExpensesProvider(trip.id));
    return Scaffold(
      appBar: AppBar(title: Text(trip.destination)),
      body: budget.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load trip budget: $error')),
        data: (tripBudget) => expenses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Could not load expenses: $error')),
          data: (items) {
            final query =
                ref.watch(travelSearchProvider(trip.id)).toLowerCase();
            final visible = items
                .where((item) =>
                    query.isEmpty ||
                    item.title.toLowerCase().contains(query) ||
                    (item.subcategory?.toLowerCase().contains(query) ?? false))
                .toList();
            final spent = items.fold(
                0, (total, item) => total + item.convertedAmountMinor);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PhaseTwoSummary(
                  summary: CategorySummary(
                    category: Category(
                      id: 0,
                      type: 'travel',
                      name: trip.destination,
                      icon: 'flight_takeoff',
                      colorValue: 0,
                    ),
                    budgetMinor: tripBudget.amountMinor,
                    spentMinor: spent,
                  ),
                ),
                const SizedBox(height: 18),
                SpendingPieChart(items: items),
                if (items.isNotEmpty) const SizedBox(height: 18),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search travel expenses',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(travelSearchProvider(trip.id).notifier)
                      .state = value,
                ),
                const SizedBox(height: 18),
                if (visible.isEmpty)
                  const Center(child: Text('No trip expenses yet.'))
                else
                  ...visible.map(
                    (item) => Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: _deleteBackground(),
                      onDismissed: (_) async {
                        await ref
                            .read(budgetRepositoryProvider)
                            .deleteTravelExpense(item.id);
                        ref.invalidate(travelExpensesProvider(trip.id));
                      },
                      child: Card(
                        elevation: 0,
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.subcategory ?? 'General'),
                          trailing: Consumer(builder: (context, ref, _) {
                            final curr = ref.watch(appCurrencyProvider);
                            return Text(formatAmount(item.amountMinor, curr));
                          }),
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => AddTravelExpenseDialog(
                              tripId: trip.id,
                              initial: item,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add travel expense',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => AddTravelExpenseDialog(tripId: trip.id),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTravelExpenseDialog extends ConsumerStatefulWidget {
  const AddTravelExpenseDialog({
    required this.tripId,
    this.initial,
    super.key,
  });

  final int tripId;
  final BudgetTransaction? initial;

  @override
  ConsumerState<AddTravelExpenseDialog> createState() =>
      _AddTravelExpenseDialogState();
}

class _AddTravelExpenseDialogState
    extends ConsumerState<AddTravelExpenseDialog> {
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final amountController = TextEditingController();
  String currency = 'TND';
  double rate = 1;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      titleController.text = initial.title;
      categoryController.text = initial.subcategory ?? '';
      currency = initial.currency;
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
    final amount = parseCurrencyMinor(amountController.text, currency);
    if (titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      return;
    }
    final repository = ref.read(budgetRepositoryProvider);
    if (widget.initial == null) {
      await repository.addTravelExpense(
        tripId: widget.tripId,
        title: titleController.text.trim(),
        subcategory: categoryController.text.trim(),
        amountMinor: amount,
        currency: currency,
      );
    } else {
      await repository.updateTravelExpense(
        id: widget.initial!.id,
        title: titleController.text.trim(),
        subcategory: categoryController.text.trim(),
        amountMinor: amount,
        currency: currency,
      );
    }
    ref.invalidate(travelExpensesProvider(widget.tripId));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null ? 'Add travel expense' : 'Edit travel expense',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
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
          Text(
              'Converted preview: ${formatTnd(((parseCurrencyMinor(amountController.text, currency) ?? 0) * rate * (currency == 'TND' ? 1 : 10)).round())}'),
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Amount ($currency)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
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

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(savingsSummaryProvider);
    final records = ref.watch(savingsRecordsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load savings: $error')),
        data: (savingSummary) => records.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Could not load records: $error')),
          data: (items) {
            final query = ref.watch(savingsSearchProvider).toLowerCase();
            final visible = items
                .where((item) =>
                    query.isEmpty || item.title.toLowerCase().contains(query))
                .toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PhaseTwoSummary(
                  summary: savingSummary,
                  budgetLabel: 'Goals',
                  spentLabel: 'Saved',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add a new goal, then add money until it is complete. You can have many goals.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search savings',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      ref.read(savingsSearchProvider.notifier).state = value,
                ),
                const SizedBox(height: 18),
                if (visible.isEmpty)
                  const Center(child: Text('No savings goals yet. Add one.'))
                else
                  ...visible.map(
                    (item) => Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: _deleteBackground(),
                      onDismissed: (_) async {
                        await ref
                            .read(budgetRepositoryProvider)
                            .deleteSaving(item.id);
                        ref.invalidate(savingsSummaryProvider);
                        ref.invalidate(savingsRecordsProvider);
                        ref.invalidate(dashboardProvider);
                      },
                      child: _FundingItemCard(
                        item: item,
                        onAddMoney: () => showDialog<void>(
                          context: context,
                          builder: (_) => ContributeDialog(
                            item: item,
                            title: 'Add money to ${item.title}',
                            onSave: (amount) async {
                              await ref
                                  .read(budgetRepositoryProvider)
                                  .contributeToSaving(
                                    item: item,
                                    addMinor: amount,
                                  );
                              ref.invalidate(savingsSummaryProvider);
                              ref.invalidate(savingsRecordsProvider);
                              ref.invalidate(dashboardProvider);
                            },
                          ),
                        ),
                        onEdit: () => showDialog<void>(
                          context: context,
                          builder: (_) => AddSavingDialog(initial: item),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add savings goal',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AddSavingDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add goal'),
      ),
    );
  }
}

class AddSavingDialog extends ConsumerStatefulWidget {
  const AddSavingDialog({super.key, this.initial});

  final BudgetTransaction? initial;

  @override
  ConsumerState<AddSavingDialog> createState() => _AddSavingDialogState();
}

class _AddSavingDialogState extends ConsumerState<AddSavingDialog> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String currency = 'TND';
  double rate = 1;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      titleController.text = initial.title;
      currency = initial.currency;
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
    amountController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = parseCurrencyMinor(amountController.text, currency);
    final title = titleController.text.trim();
    if (title.isEmpty || amount == null || amount <= 0) return;
    final repository = ref.read(budgetRepositoryProvider);
    if (widget.initial == null) {
      await repository.addSavingGoal(
        title: title,
        amountMinor: amount,
        currency: currency,
      );
    } else {
      await repository.updateSaving(
        id: widget.initial!.id,
        title: title,
        amountMinor: amount,
        currency: currency,
      );
    }
    ref.invalidate(savingsSummaryProvider);
    ref.invalidate(savingsRecordsProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add savings goal' : 'Edit goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Goal name'),
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
            controller: amountController,
            decoration: InputDecoration(labelText: 'Amount ($currency)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          Consumer(builder: (context, ref, _) {
            final appCurr = ref.watch(appCurrencyProvider);
            return Text(
                'Converted preview: ${formatAmount(((parseCurrencyMinor(amountController.text, currency) ?? 0) * rate * (currency == 'TND' ? 1 : 10)).round(), appCurr)}');
          }),
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

class CategoryBudgetDialog extends ConsumerStatefulWidget {
  const CategoryBudgetDialog(
      {required this.type, required this.title, super.key});

  final String type;
  final String title;

  @override
  ConsumerState<CategoryBudgetDialog> createState() =>
      _CategoryBudgetDialogState();
}

class _CategoryBudgetDialogState extends ConsumerState<CategoryBudgetDialog> {
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final amount = parseTnd(amountController.text);
    if (amount == null || amount <= 0) return;
    await ref.read(budgetRepositoryProvider).setCategoryBudget(
          type: widget.type,
          amountMinor: amount,
          period: DateTime.now(),
        );
    ref.invalidate(specialSummaryProvider);
    ref.invalidate(savingsSummaryProvider);
    ref.invalidate(dashboardProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: amountController,
        decoration: const InputDecoration(labelText: 'Amount (TND)'),
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

class PhaseTwoSummary extends StatelessWidget {
  const PhaseTwoSummary({
    required this.summary,
    this.budgetLabel = 'Budget',
    this.spentLabel = 'Spent',
    super.key,
  });

  final CategorySummary summary;
  final String budgetLabel;
  final String spentLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(child: _summaryMetric(budgetLabel, summary.budgetMinor)),
            Expanded(child: _summaryMetric(spentLabel, summary.spentMinor)),
            Expanded(
                child: _summaryMetric('Remaining', summary.remainingMinor)),
          ],
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, int? amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 5),
        Consumer(builder: (context, ref, _) {
          final curr = ref.watch(appCurrencyProvider);
          return Text(
            amount == null ? 'Not set' : formatAmount(amount, curr),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          );
        }),
      ],
    );
  }
}

Widget _deleteBackground() {
  return Container(
    color: Colors.red.shade100,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: const Icon(Icons.delete_outline),
  );
}



String shortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
