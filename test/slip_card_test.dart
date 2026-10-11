import 'package:asan_bill_viewer/core/data/providers.dart';
import 'package:asan_bill_viewer/models/saved_bill.dart';
import 'package:asan_bill_viewer/widgets/slip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  final lesco = providerById('lesco')!;

  SavedBill bill({bool paid = false, DateTime? dueDate, int? amount}) =>
      SavedBill(
        id: 'b1',
        providerId: 'lesco',
        reference: '12345678901234',
        nickname: 'Home',
        amountRs: amount,
        dueDate: dueDate,
        paid: paid,
        updatedAt: DateTime(2026, 10, 11),
      );

  testWidgets('shows nickname, masked code and amount', (tester) async {
    await tester.pumpWidget(_wrap(SlipCard(
      bill: bill(amount: 4820),
      provider: lesco,
      onTap: () {},
      onTogglePaid: () {},
    )));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('LESCO ••••1234'), findsOneWidget);
    expect(find.text('Rs 4,820'), findsOneWidget);
  });

  testWidgets('amber chip when 2 days remain', (tester) async {
    final due = DateTime.now().add(const Duration(days: 2));
    await tester.pumpWidget(_wrap(SlipCard(
      bill: bill(dueDate: due),
      provider: lesco,
      onTap: () {},
      onTogglePaid: () {},
    )));

    expect(find.text('Due in 2 days left'), findsOneWidget);
  });

  testWidgets('red chip when overdue', (tester) async {
    final due = DateTime.now().subtract(const Duration(days: 3));
    await tester.pumpWidget(_wrap(SlipCard(
      bill: bill(dueDate: due),
      provider: lesco,
      onTap: () {},
      onTogglePaid: () {},
    )));

    expect(find.text('Overdue'), findsOneWidget);
  });

  testWidgets('green chip when paid', (tester) async {
    await tester.pumpWidget(_wrap(SlipCard(
      bill: bill(paid: true),
      provider: lesco,
      onTap: () {},
      onTogglePaid: () {},
    )));

    expect(find.text('Paid'), findsOneWidget);
  });

  testWidgets('tap opens the bill viewer', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(SlipCard(
      bill: bill(),
      provider: lesco,
      onTap: () => tapped = true,
      onTogglePaid: () {},
    )));

    await tester.tap(find.byType(SlipCard));
    expect(tapped, isTrue);
  });

  testWidgets('paid toggle button fires', (tester) async {
    var toggled = false;
    await tester.pumpWidget(_wrap(SlipCard(
      bill: bill(),
      provider: lesco,
      onTap: () {},
      onTogglePaid: () => toggled = true,
    )));

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    expect(toggled, isTrue);
  });
}
