// Small formatting helpers. Numbers always use Western digits,
// even in Urdu mode.

/// 1234567 -> "Rs 1,234,567"
String formatRs(int amount) {
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return 'Rs ${amount < 0 ? '-' : ''}${buf.toString()}';
}

/// 2048 -> "2.0 MB", 512 -> "512 KB", 900 -> "900 B"
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}

/// 2026-10-11 -> "11 Oct 2026" (English short month names; Urdu callers
/// should use [formatDateLocalized] with month names from Strings).
String formatDateShort(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

/// "11 اکتوبر 2026" style using a caller-supplied month name.
String formatDateLocalized(DateTime d, String monthName) =>
    '${d.day} $monthName ${d.year}';
