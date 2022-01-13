import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';

void main() {
  group('String Utils: ', () {
    test('GIVEN lower case string THEN Capitalize', () {
      const lowerCamelCase = 'lowerCase string. it should be capitalized.';
      const capitalized = 'Lowercase string. it should be capitalized.';
      const capitalizedAll = 'Lowercase String. It Should Be Capitalized.';
      expect(lowerCamelCase.capitalize(allWords: false), equals(capitalized));
      expect(lowerCamelCase.capitalize(allWords: true), equals(capitalizedAll));
    });

    test('GIVEN string THEN get if upper case', () {
      const notUpperCase = 'Lowercase string';
      const upperCase = 'LOWERCASE STRING';
      expect(notUpperCase.isUpperCase(), isFalse);
      expect(upperCase.isUpperCase(), isTrue);
    });

    test('GIVEN camelCase string THEN separate words', () {
      const camelCase = 'camelCaseVeryLongString';
      const camelCaseSeparatedBySpace = 'camel case very long string';
      const camelCaseSeparatedByUnderScore = 'camel_case_very_long_string';
      expect(camelCase.camelCaseToLowerCaseSeparatedBy(' '),
          equals(camelCaseSeparatedBySpace));
      expect(camelCase.camelCaseToLowerCaseSeparatedBy('_'),
          equals(camelCaseSeparatedByUnderScore));
    });
  });
}
