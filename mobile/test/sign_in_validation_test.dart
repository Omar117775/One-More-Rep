import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/sign_in_validators.dart';

void main() {
  group('sign-in validation', () {
    test('accepts a well-formed email', () {
      expect(validateEmailField('l@example.com'), isNull);
      expect(
        validateEmailField(' LEONIDAS.EXAMPLE@sub.domain.io '.trim()),
        isNull,
      );
    });

    test('rejects empty and malformed emails', () {
      expect(validateEmailField(''), isNotNull);
      expect(validateEmailField(null), isNotNull);
      expect(validateEmailField('missing-at-sign'), isNotNull);
      expect(validateEmailField('a@b'), isNotNull);
      expect(validateEmailField('a b@c.com'), isNotNull);
    });

    test('requires a non-empty password of at least 6 characters', () {
      expect(validatePasswordField(''), 'empty');
      expect(validatePasswordField(null), 'empty');
      expect(validatePasswordField('abc'), 'short');
      expect(validatePasswordField('hunter2x'), isNull);
    });
  });
}
