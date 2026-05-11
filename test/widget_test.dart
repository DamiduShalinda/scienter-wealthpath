import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthpath/features/spending/presentation/widgets/spending_header_widget.dart';

void main() {
  testWidgets('SpendingHeaderWidget renders total and count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpendingHeaderWidget(total: 1245.5, count: 32),
        ),
      ),
    );

    expect(find.text('Total Spent'), findsOneWidget);
    expect(find.text('\$1245.50'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('32'), findsOneWidget);
  });
}
