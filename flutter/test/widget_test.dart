import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_budget_manager/main.dart';

void main() {
  testWidgets('app shell loads', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartBudgetApp()));
    await tester.pump();

    expect(find.text('Smart Budget'), findsOneWidget);
  });
}
