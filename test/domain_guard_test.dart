import 'package:asan_bill_viewer/services/domain_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pitc = ['bill.pitc.com.pk', 'pitc.com.pk'];

  group('isAllowedUrl', () {
    test('allows the exact official host', () {
      expect(
          isAllowedUrl('https://bill.pitc.com.pk/lescobill', pitc), isTrue);
    });

    test('allows subdomains of an allowed domain', () {
      expect(isAllowedUrl('https://www.pitc.com.pk/x', pitc), isTrue);
    });

    test('allows the parent domain itself', () {
      expect(isAllowedUrl('https://pitc.com.pk/', pitc), isTrue);
    });

    test('blocks lookalike domains', () {
      // "bill.pitc.com.pk.evil.com" ends with the string but is not a subdomain.
      expect(isAllowedUrl('https://bill.pitc.com.pk.evil.com/', pitc),
          isFalse);
      expect(
          isAllowedUrl('https://bill-pitc-com-pk.phish.example/', pitc),
          isFalse);
    });

    test('blocks unrelated hosts', () {
      expect(isAllowedUrl('https://ads.example.com/', pitc), isFalse);
      expect(isAllowedUrl('https://google.com/', pitc), isFalse);
    });

    test('blocks non-http schemes', () {
      expect(isAllowedUrl('javascript:alert(1)', pitc), isFalse);
      expect(isAllowedUrl('intent://bill.pitc.com.pk/#x', pitc), isFalse);
      expect(isAllowedUrl('about:blank', pitc), isFalse);
    });

    test('blocks malformed URLs', () {
      expect(isAllowedUrl('::::', pitc), isFalse);
      expect(isAllowedUrl('', pitc), isFalse);
    });

    test('host matching is case-insensitive', () {
      expect(
          isAllowedUrl('https://BILL.PITC.COM.PK/lescobill', pitc), isTrue);
    });

    test('http (non-TLS) official host still loads in the viewer', () {
      expect(isAllowedUrl('http://bill.pitc.com.pk/lescobill', pitc), isTrue);
    });
  });
}
