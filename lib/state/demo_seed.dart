import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';

/// Debug-only demo data. Never seeded in release builds — the call site
/// guards with [kDebugMode] and the button itself only exists in debug.
Future<void> seedDemoBills(WidgetRef ref) async {
  assert(kDebugMode, 'Demo seed must never run in release builds.');
  final bills = ref.read(savedBillsProvider.notifier);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  bills.upsert(
    providerId: 'lesco',
    reference: '04123456789012',
    nickname: 'Home',
    amountRs: 4820,
    dueDate: today.add(const Duration(days: 2)),
  );
  bills.upsert(
    providerId: 'sngpl',
    reference: '12345678901',
    nickname: 'Home gas',
    amountRs: 1230,
    dueDate: today.add(const Duration(days: 9)),
  );
  bills.upsert(
    providerId: 'kelectric',
    reference: '0400012345678',
    nickname: 'Karachi flat',
    amountRs: 9150,
    dueDate: today.subtract(const Duration(days: 1)),
  );
  bills.upsert(
    providerId: 'ptcl',
    reference: '0512345678',
    nickname: 'Office line',
    amountRs: 0,
    dueDate: today.add(const Duration(days: 20)),
  );
}
