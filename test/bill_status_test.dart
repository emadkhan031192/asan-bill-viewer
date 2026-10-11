import 'package:asan_bill_viewer/models/bill_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 11, 15, 30);
  DateTime day(int y, int m, int d) => DateTime(y, m, d);

  group('dueStatusOf', () {
    test('paid always wins, even when overdue', () {
      expect(
        dueStatusOf(
            paid: true, dueDate: day(2026, 9, 1), now: now),
        DueStatus.paid,
      );
    });

    test('overdue when the due date has passed', () {
      expect(
        dueStatusOf(
            paid: false, dueDate: day(2026, 10, 10), now: now),
        DueStatus.overdue,
      );
    });

    test('due today', () {
      expect(
        dueStatusOf(
            paid: false, dueDate: day(2026, 10, 11), now: now),
        DueStatus.dueToday,
      );
    });

    test('due soon for 1-3 days remaining (amber)', () {
      for (final days in [1, 2, 3]) {
        expect(
          dueStatusOf(
            paid: false,
            dueDate: day(2026, 10, 11).add(Duration(days: days)),
            now: now,
          ),
          DueStatus.dueSoon,
          reason: '$days days',
        );
      }
    });

    test('upcoming for 4+ days remaining (muted)', () {
      expect(
        dueStatusOf(
          paid: false,
          dueDate: day(2026, 10, 15),
          now: now,
        ),
        DueStatus.upcoming,
      );
    });

    test('no due date', () {
      expect(
        dueStatusOf(paid: false, dueDate: null, now: now),
        DueStatus.noDueDate,
      );
    });

    test('compares calendar days, not exact timestamps', () {
      // Due "today" at 00:00 while now is 15:30 -> still due today.
      expect(
        dueStatusOf(
            paid: false, dueDate: day(2026, 10, 11), now: now),
        DueStatus.dueToday,
      );
    });
  });

  group('daysRemaining', () {
    test('positive, zero and negative values', () {
      expect(daysRemaining(day(2026, 10, 13), now), 2);
      expect(daysRemaining(day(2026, 10, 11), now), 0);
      expect(daysRemaining(day(2026, 10, 9), now), -2);
    });

    test('null without a due date', () {
      expect(daysRemaining(null, now), isNull);
    });
  });
}
