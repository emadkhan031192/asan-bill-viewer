import 'package:asan_bill_viewer/core/data/providers.dart';
import 'package:asan_bill_viewer/screens/lookup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget-level coverage for the Lookup length validation:
/// "View bill" is enabled only when the provider's length rule passes.
void main() {
  Future<void> pumpLookup(WidgetTester tester, String id) async {
    await tester.pumpWidget(
      MaterialApp(home: LookupScreen(provider: providerById(id)!)),
    );
    await tester.pumpAndSettle();
  }

  Finder viewBillButton() => find.widgetWithText(FilledButton, 'View bill');

  testWidgets('LESCO: button disabled until 14 digits entered',
      (tester) async {
    await pumpLookup(tester, 'lesco');

    expect(viewBillButton(), findsOneWidget);
    expect(tester.widget<FilledButton>(viewBillButton()).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '1234567890123'); // 13
    await tester.pump();
    expect(tester.widget<FilledButton>(viewBillButton()).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '12345678901234'); // 14
    await tester.pump();
    expect(tester.widget<FilledButton>(viewBillButton()).onPressed,
        isNotNull);
  });

  testWidgets('counter shows live digit count', (tester) async {
    await pumpLookup(tester, 'kelectric');

    expect(find.text('0/13'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '0400012345678');
    await tester.pump();
    expect(find.text('13/13'), findsOneWidget);
  });

  testWidgets('PTCL accepts 10 or 11 digits', (tester) async {
    await pumpLookup(tester, 'ptcl');

    await tester.enterText(find.byType(TextField), '051234567'); // 9
    await tester.pump();
    expect(tester.widget<FilledButton>(viewBillButton()).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '0512345678'); // 10
    await tester.pump();
    expect(tester.widget<FilledButton>(viewBillButton()).onPressed,
        isNotNull);
  });

  testWidgets('prefills a scanned number', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LookupScreen(
        provider: providerById('sngpl')!,
        initialNumber: '123-456 78901',
      ),
    ));
    await tester.pumpAndSettle();

    // Digits kept, grouped for display; 11 digits is valid for SNGPL.
    expect(find.text('1234 5678 901'), findsOneWidget);
    expect(tester.widget<FilledButton>(viewBillButton()).onPressed,
        isNotNull);
  });
}
