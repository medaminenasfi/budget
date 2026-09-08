import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'data/local/database.dart';
import 'data/models/default_categories.dart';
import 'data/repositories/budget_repository.dart';
import 'logic/budget_providers.dart';
import 'presentation/phase_two_screens.dart';
import 'presentation/phase_three_widgets.dart';
import 'presentation/phase_four_screens.dart';
import 'presentation/phase_five_screens.dart';
import 'presentation/auth_screens.dart';
import 'presentation/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: SmartBudgetApp()));
}

class SmartBudgetApp extends ConsumerWidget {
  const SmartBudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const _AppStartup(),
        '/home': (context) => const _AuthGuard(child: HomeScreen()),
      },
    );
  }
}

/// Handles first-launch routing: checks onboarding & session.
class _AppStartup extends ConsumerWidget {
  const _AppStartup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Widget>(
      future: _resolveStartScreen(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }

  Future<Widget> _resolveStartScreen(WidgetRef ref) async {
    final settingsRepo = ref.read(settingsRepositoryProvider);

    // 1. Restore session
    final profile = await settingsRepo.getProfile();
    if (profile != null) {
      ref.read(currentUserProvider.notifier).state = profile;

      // Load persisted currency
      final currency = await settingsRepo.getCurrency();
      await ref.read(appCurrencyProvider.notifier).setCurrency(currency);

      // 2. Check biometric
      final biometricEnabled = await settingsRepo.isBiometricEnabled();
      final biometricAvailable =
          await ref.read(biometricRepositoryProvider).isAvailable();

      if (biometricEnabled && biometricAvailable) {
        // We'll try biometric on the login screen — return login with biometric hint
        return const LoginScreen();
      }

      return const HomeScreen();
    }

    // 3. No session — check if onboarding done
    final onboardingDone = await settingsRepo.isOnboardingDone();
    if (onboardingDone) {
      return const LoginScreen();
    }

    return const OnboardingScreen();
  }
}

/// Wraps any screen that requires authentication.
class _AuthGuard extends ConsumerWidget {
  const _AuthGuard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    if (!isAuthenticated) return const LoginScreen();
    return child;
  }
}

// ---------------------------------------------------------------------------
// Home Screen
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final trend = ref.watch(sixMonthTrendProvider);
    final alerts = ref.watch(budgetAlertsProvider);
    final currency = ref.watch(appCurrencyProvider);

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
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
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
              Consumer(builder: (context, ref, _) {
                final user = ref.watch(currentUserProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null ? 'Hello, ${user.name.split(' ').first}!' : 'Your budget summary',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This month in $currency',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ],
                );
              }),
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

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.summary});

  final CategorySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(summary.category.colorValue);
    final currency = ref.watch(appCurrencyProvider);
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
                    Text('Spent ${formatAmount(summary.spentMinor, currency)}'),
                    Text(
                      summary.budgetMinor == null
                          ? 'No budget set'
                          : 'Remaining ${formatAmount(summary.remainingMinor, currency)}',
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

// ---------------------------------------------------------------------------
// Monthly Expenses Screen — with month selector + collapsible filters
// ---------------------------------------------------------------------------

class MonthlyExpensesScreen extends ConsumerWidget {
  const MonthlyExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final summary = ref.watch(monthlySummaryProvider);
    final expenses = ref.watch(filteredMonthlyExpensesProvider);
    final allExpenses = ref.watch(monthlyExpensesProvider);
    final filterVisible = ref.watch(filterVisibleProvider);
    final currency = ref.watch(appCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expenses'),
        actions: [
          // Filter toggle icon
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                tooltip: 'Filters',
                onPressed: () => ref
                    .read(filterVisibleProvider.notifier)
                    .state = !filterVisible,
                icon: Icon(
                  filterVisible
                      ? Icons.filter_list_off
                      : Icons.filter_list,
                ),
              ),
              if (_hasActiveFilters(ref))
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
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
              // ---- Month selector ----
              _MonthSelector(selectedMonth: selectedMonth),
              const SizedBox(height: 14),

              // ---- Budget summary ----
              _MonthlyBudgetSummary(summary: monthlySummary),
              const SizedBox(height: 18),

              // ---- Search bar ----
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
                ),
                onChanged: (value) =>
                    ref.read(monthlySearchProvider.notifier).state = value,
              ),
              const SizedBox(height: 10),

              // ---- Collapsible filter panel ----
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: filterVisible
                    ? _MonthlyFilterPanel(
                        allItems: allExpenses.valueOrNull ?? const [],
                      )
                    : const SizedBox.shrink(),
              ),
              if (filterVisible) const SizedBox(height: 14),

              // ---- Pie chart ----
              SpendingPieChart(items: items),
              if (items.isNotEmpty) const SizedBox(height: 18),

              // ---- Expense list ----
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
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFEF8354)
                                .withOpacity(0.15),
                            child: Text(
                              _categoryEmoji(item.subcategory),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          title: Text(item.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${item.subcategory ?? 'General'} · ${shortDate(item.date)}',
                            style: const TextStyle(color: Colors.black45),
                          ),
                          trailing: Text(
                            formatAmount(item.amountMinor, currency),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700),
                          ),
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) =>
                                AddExpenseDialog(initial: item),
                          ),
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

  bool _hasActiveFilters(WidgetRef ref) {
    return ref.watch(monthlyCategoryProvider) != null ||
        ref.watch(monthlyDateRangeProvider) != null ||
        ref.watch(monthlyMinAmountProvider).isNotEmpty ||
        ref.watch(monthlyMaxAmountProvider).isNotEmpty;
  }
}

String _categoryEmoji(String? subcategory) {
  const map = {
    'Food & Dining': '🍽️',
    'Groceries': '🛒',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Bills & Utilities': '📃',
    'Rent / Housing': '🏠',
    'Health': '💊',
    'Entertainment': '🎬',
    'Education': '📚',
    'Travel': '✈️',
    'Subscriptions': '📱',
    'Personal Care': '🧴',
    'Family': '👨‍👩‍👧',
    'Salary': '💼',
    'Freelance': '💻',
    'Business': '🏢',
    'Investment': '📈',
    'Gift': '🎁',
  };
  return map[subcategory] ?? '💰';
}

// ---------------------------------------------------------------------------
// Month Selector Widget
// ---------------------------------------------------------------------------

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final current = ref.read(selectedMonthProvider);
              ref.read(selectedMonthProvider.notifier).state =
                  DateTime(current.year, current.month - 1);
              // Clear filters when month changes
              ref.read(monthlySearchProvider.notifier).state = '';
              ref.read(monthlyCategoryProvider.notifier).state = null;
              ref.read(monthlyDateRangeProvider.notifier).state = null;
            },
          ),
          GestureDetector(
            onTap: () async {
              // Show month/year picker
              final picked = await _pickMonthYear(context, selectedMonth);
              if (picked != null) {
                ref.read(selectedMonthProvider.notifier).state = picked;
              }
            },
            child: Row(
              children: [
                Icon(Icons.calendar_month,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '${_monthName(selectedMonth.month)} ${selectedMonth.year}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down,
                    color: theme.colorScheme.primary),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            // Prevent going into the future
            onPressed: _isCurrentOrFuture(selectedMonth)
                ? null
                : () {
                    final current = ref.read(selectedMonthProvider);
                    ref.read(selectedMonthProvider.notifier).state =
                        DateTime(current.year, current.month + 1);
                    ref.read(monthlySearchProvider.notifier).state = '';
                    ref.read(monthlyCategoryProvider.notifier).state = null;
                    ref.read(monthlyDateRangeProvider.notifier).state = null;
                  },
          ),
        ],
      ),
    );
  }

  bool _isCurrentOrFuture(DateTime month) {
    final now = DateTime.now();
    return month.year > now.year ||
        (month.year == now.year && month.month >= now.month);
  }

  Future<DateTime?> _pickMonthYear(
      BuildContext context, DateTime initial) async {
    // Simple dialog to pick year/month
    final now = DateTime.now();
    DateTime selected = initial;
    return showDialog<DateTime>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Month'),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () =>
                            setState(() => selected = DateTime(
                                selected.year - 1, selected.month)),
                      ),
                      Text('${selected.year}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: selected.year >= now.year
                            ? null
                            : () => setState(() => selected =
                                DateTime(selected.year + 1, selected.month)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Month grid
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.4,
                    ),
                    itemBuilder: (context, i) {
                      final month = i + 1;
                      final isSelected = selected.month == month;
                      final isFuture = selected.year == now.year &&
                          month > now.month;
                      return GestureDetector(
                        onTap: isFuture
                            ? null
                            : () => setState(() => selected =
                                DateTime(selected.year, month)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _shortMonth(month),
                              style: TextStyle(
                                color: isFuture
                                    ? Colors.black26
                                    : isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, selected),
                  child: const Text('Select')),
            ],
          );
        },
      ),
    );
  }
}

String _shortMonth(int month) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return names[month - 1];
}

// ---------------------------------------------------------------------------
// Collapsible Filter Panel
// ---------------------------------------------------------------------------

class _MonthlyFilterPanel extends ConsumerStatefulWidget {
  const _MonthlyFilterPanel({required this.allItems});

  final List<BudgetTransaction> allItems;

  @override
  ConsumerState<_MonthlyFilterPanel> createState() =>
      _MonthlyFilterPanelState();
}

class _MonthlyFilterPanelState
    extends ConsumerState<_MonthlyFilterPanel> {
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.allItems
        .map((item) => item.subcategory)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Also add default expense subcategories
    for (final cat in kExpenseSubcategories) {
      final name = cat['name'] as String;
      if (!categories.contains(name)) categories.add(name);
    }

    final selected = ref.watch(monthlyCategoryProvider);
    final dateRange = ref.watch(monthlyDateRangeProvider);
    final hasFilters = selected != null ||
        dateRange != null ||
        ref.watch(monthlyMinAmountProvider).isNotEmpty ||
        ref.watch(monthlyMaxAmountProvider).isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined,
                  size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              const Text('Filters',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.black54)),
              const Spacer(),
              if (hasFilters)
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(monthlyCategoryProvider.notifier)
                        .state = null;
                    ref
                        .read(monthlyDateRangeProvider.notifier)
                        .state = null;
                    ref
                        .read(monthlyMinAmountProvider.notifier)
                        .state = '';
                    ref
                        .read(monthlyMaxAmountProvider.notifier)
                        .state = '';
                    _minCtrl.clear();
                    _maxCtrl.clear();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear all'),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: EdgeInsets.zero),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Category dropdown
          DropdownButtonFormField<String>(
            value: selected,
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
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
            onChanged: (value) =>
                ref.read(monthlyCategoryProvider.notifier).state = value,
          ),
          const SizedBox(height: 10),
          // Amount range
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Min amount',
                    prefixIcon: Icon(Icons.arrow_downward, size: 18),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  onChanged: (value) => ref
                      .read(monthlyMinAmountProvider.notifier)
                      .state = parseTnd(value)?.toString() ?? '',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _maxCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Max amount',
                    prefixIcon: Icon(Icons.arrow_upward, size: 18),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  onChanged: (value) => ref
                      .read(monthlyMaxAmountProvider.notifier)
                      .state = parseTnd(value)?.toString() ?? '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Date range
          OutlinedButton.icon(
            onPressed: () async {
              final selectedRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(DateTime.now().year - 2),
                lastDate: DateTime.now(),
                initialDateRange: dateRange,
                builder: (context, child) => Theme(
                  data: Theme.of(context),
                  child: child!,
                ),
              );
              if (selectedRange != null) {
                ref.read(monthlyDateRangeProvider.notifier).state =
                    selectedRange;
              }
            },
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(
              dateRange == null
                  ? 'Date range'
                  : '${shortDate(dateRange.start)} → ${shortDate(dateRange.end)}',
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly Budget Summary
// ---------------------------------------------------------------------------

class _MonthlyBudgetSummary extends ConsumerWidget {
  const _MonthlyBudgetSummary({required this.summary});

  final CategorySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = summary.remainingMinor;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final currency = ref.watch(appCurrencyProvider);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_monthName(selectedMonth.month)} ${selectedMonth.year}',
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
                      : formatAmount(summary.budgetMinor!, currency),
                ),
                _BudgetMetric(
                  label: 'Spent',
                  value: formatAmount(summary.spentMinor, currency),
                ),
                _BudgetMetric(
                  label: 'Remaining',
                  value: summary.budgetMinor == null
                      ? 'Not set'
                      : formatAmount(remaining, currency),
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
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return names[month - 1];
}

// ---------------------------------------------------------------------------
// Add Expense Dialog — now with category dropdown
// ---------------------------------------------------------------------------

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key, this.initial});

  final BudgetTransaction? initial;

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String currency = 'TND';
  String? selectedCategory;
  double rate = 1;
  String? receiptPhotoPath;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      currency = initial.currency;
      selectedCategory = initial.subcategory;
      receiptPhotoPath = initial.receiptPhotoPath;
      titleController.text = initial.title;
      amountController.text =
          (initial.amountMinor / (currency == 'TND' ? 1000 : 100))
              .toStringAsFixed(2);
    }
    // Default currency from app settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initial == null) {
        currency = ref.read(appCurrencyProvider);
      }
      _loadRate();
    });
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
    final amountMinor = parseCurrencyMinor(amountController.text, currency);
    if (titleController.text.trim().isEmpty ||
        amountMinor == null ||
        amountMinor <= 0) {
      return;
    }
    final repository = ref.read(budgetRepositoryProvider);
    final selectedMonth = ref.read(selectedMonthProvider);
    if (widget.initial == null) {
      await repository.addMonthlyExpense(
        title: titleController.text.trim(),
        subcategory: selectedCategory ?? '',
        amountMinor: amountMinor,
        currency: currency,
        receiptPhotoPath: receiptPhotoPath,
        date: DateTime(
          selectedMonth.year,
          selectedMonth.month,
          DateTime.now().day,
        ),
      );
    } else {
      await repository.updateMonthlyExpense(
        id: widget.initial!.id,
        title: titleController.text.trim(),
        subcategory: selectedCategory ?? '',
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
    final allCategories = [
      ...kExpenseSubcategories.map((c) => c['name'] as String),
    ];

    return AlertDialog(
      title: Text(
          widget.initial == null ? 'Add expense' : 'Edit expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                  labelText: 'Category'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('— Select category —'),
                ),
                ...allCategories.map(
                  (c) =>
                      DropdownMenuItem(value: c, child: Text(c)),
                ),
              ],
              onChanged: (value) =>
                  setState(() => selectedCategory = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: currency,
              decoration: const InputDecoration(
                  labelText: 'Currency'),
              items: kSupportedCurrencies
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() => currency = value ?? 'TND');
                _loadRate();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                  labelText: 'Amount ($currency)'),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              'Converted: ${formatAmount(((parseCurrencyMinor(amountController.text, currency) ?? 0) * rate * (currency == 'TND' ? 1 : 10)).round(), ref.read(appCurrencyProvider))}',
              style: const TextStyle(
                  color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final file = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (file != null) {
                  setState(() => receiptPhotoPath = file.path);
                }
              },
              icon: const Icon(Icons.receipt_long),
              label: Text(receiptPhotoPath == null
                  ? 'Attach receipt'
                  : 'Receipt attached ✓'),
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

// ---------------------------------------------------------------------------
// Set Budget Dialog
// ---------------------------------------------------------------------------

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
    final amount =
        double.tryParse(amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;
    final selectedMonth = ref.read(selectedMonthProvider);
    await ref.read(budgetRepositoryProvider).setMonthlyBudget(
          amountMinor: (amount * 1000).round(),
          period: selectedMonth,
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
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
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

// ---------------------------------------------------------------------------
// Icon & navigation helpers
// ---------------------------------------------------------------------------

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
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => screen));
}
