import 'package:asan_bill_viewer/services/ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('extractCandidates', () {
    test('14 digits -> PITC electricity reference', () {
      final out = extractCandidates('Ref No: 12345678901234');
      expect(out, hasLength(1));
      expect(out.first.digits, '12345678901234');
      expect(out.first.kind, OcrKind.pitc14);
    });

    test('13 digits -> K-Electric account number', () {
      final out = extractCandidates('Account No 0400012345678');
      expect(out.first.kind, OcrKind.kelectric13);
    });

    test('8-12 digits -> gas consumer number', () {
      final out = extractCandidates('Consumer No: 12345678901');
      expect(out.first.kind, OcrKind.gas);
    });

    test('joins groups split by spaces or dashes', () {
      final out = extractCandidates('1234 5678 9012 34');
      expect(out.first.digits, '12345678901234');
      expect(out.first.kind, OcrKind.pitc14);
    });

    test('ignores runs shorter than 8 digits', () {
      expect(extractCandidates('Bill for 1234567 units'), isEmpty);
    });

    test('dedupes repeated numbers', () {
      final out =
          extractCandidates('12345678901234 and again 12345678901234');
      expect(out, hasLength(1));
    });

    test('prefers longer numbers first', () {
      final out = extractCandidates(
          'meter 12345678 ref 12345678901234');
      expect(out.first.digits, '12345678901234');
      expect(out, hasLength(2));
    });

    test('returns empty when nothing looks like a number', () {
      expect(extractCandidates('Lahore Electric Supply Company'), isEmpty);
    });
  });
}
