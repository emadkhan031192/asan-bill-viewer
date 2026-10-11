import 'package:asan_bill_viewer/core/data/providers.dart';
import 'package:asan_bill_viewer/services/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('digitsOnly', () {
    test('strips spaces, dashes and letters', () {
      expect(digitsOnly('1234 5678-9012 ab34'), '12345678901234');
    });

    test('keeps an already clean number', () {
      expect(digitsOnly('0400012345678'), '0400012345678');
    });
  });

  group('groupDigits', () {
    test('groups a 14-digit reference in fours', () {
      expect(groupDigits('12345678901234'), '1234 5678 9012 34');
    });

    test('groups a 13-digit account number', () {
      expect(groupDigits('0400012345678'), '0400 0123 4567 8');
    });

    test('handles short input', () {
      expect(groupDigits('123'), '123');
    });
  });

  group('isValidReference', () {
    BillProvider p(String id) => providerById(id)!;

    test('PITC providers require exactly 14 digits', () {
      for (final id in [
        'lesco', 'gepco', 'fesco', 'iesco', 'mepco',
        'pesco', 'hesco', 'sepco', 'qesco', 'tesco',
      ]) {
        final provider = p(id);
        expect(provider.minLength, 14, reason: id);
        expect(provider.maxLength, 14, reason: id);
        expect(isValidReference(provider, '12345678901234'), isTrue,
            reason: id);
        expect(isValidReference(provider, '1234567890123'), isFalse,
            reason: '$id too short');
        expect(isValidReference(provider, '123456789012345'), isFalse,
            reason: '$id too long');
        expect(isValidReference(provider, ''), isFalse, reason: id);
      }
    });

    test('K-Electric requires exactly 13 digits', () {
      final ke = p('kelectric');
      expect(isValidReference(ke, '0400012345678'), isTrue);
      expect(isValidReference(ke, '040001234567'), isFalse);
      expect(isValidReference(ke, '04000123456789'), isFalse);
    });

    test('SNGPL accepts 8 to 12 digits', () {
      final provider = p('sngpl');
      expect(isValidReference(provider, '12345678'), isTrue);
      expect(isValidReference(provider, '12345678901'), isTrue);
      expect(isValidReference(provider, '123456789012'), isTrue);
      expect(isValidReference(provider, '1234567'), isFalse);
      expect(isValidReference(provider, '1234567890123'), isFalse);
    });

    test('SSGC requires exactly 10 digits (verified on the official page)',
        () {
      final provider = p('ssgc');
      expect(isValidReference(provider, '1234567890'), isTrue);
      expect(isValidReference(provider, '123456789'), isFalse);
      expect(isValidReference(provider, '12345678901'), isFalse);
    });

    test('PTCL accepts 10 or 11 digits (landline with area code)', () {
      final ptcl = p('ptcl');
      expect(isValidReference(ptcl, '0512345678'), isTrue);
      expect(isValidReference(ptcl, '05123456789'), isTrue);
      expect(isValidReference(ptcl, '051234567'), isFalse);
    });

    test('WASA Lahore accepts 4 to 14 digits', () {
      final wasa = p('wasa_lahore');
      expect(isValidReference(wasa, '1234'), isTrue);
      expect(isValidReference(wasa, '12345678901234'), isTrue);
      expect(isValidReference(wasa, '123'), isFalse);
    });

    test('rejects non-digit input', () {
      final lesco = p('lesco');
      expect(isValidReference(lesco, '1234567890123a'), isFalse);
    });
  });

  group('provider data sanity', () {
    test('every provider URL is https and allowlist covers its host', () {
      for (final provider in kProviders) {
        final uri = Uri.parse(provider.url);
        expect(uri.scheme, 'https', reason: provider.id);
        expect(
          provider.allowedDomains.any((d) =>
              uri.host == d || uri.host.endsWith('.$d')),
          isTrue,
          reason: '${provider.id}: ${uri.host} not in allowlist',
        );
      }
    });

    test('provider ids are unique', () {
      final ids = kProviders.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('min length never exceeds max length', () {
      for (final provider in kProviders) {
        expect(provider.minLength <= provider.maxLength, isTrue,
            reason: provider.id);
      }
    });
  });
}
