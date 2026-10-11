import 'package:flutter/services.dart';

import '../core/data/providers.dart';

/// Keep digits only.
String digitsOnly(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

/// True when [digits] satisfies the provider's inclusive length rule.
bool isValidReference(BillProvider provider, String digits) {
  if (digits.isEmpty) return false;
  if (RegExp(r'[^0-9]').hasMatch(digits)) return false;
  return digits.length >= provider.minLength &&
      digits.length <= provider.maxLength;
}

/// Group digits in fours for display: "12345678901234" -> "1234 5678 9012 34".
String groupDigits(String digits) {
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && i % 4 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return buf.toString();
}

/// TextInputFormatter: digits only, grouped in fours, capped at [maxLength].
class ReferenceInputFormatter extends TextInputFormatter {
  ReferenceInputFormatter(this.maxLength);

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = digitsOnly(newValue.text);
    if (digits.length > maxLength) {
      digits = digits.substring(0, maxLength);
    }
    final grouped = groupDigits(digits);
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }
}
