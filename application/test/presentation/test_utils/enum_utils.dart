import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/presentation/utils/enum_utils.dart';

enum testEnum { firstEnumToChoose, secondEnum }

void main() {
  group('Enum Utils: ', () {
    test('GIVEN enum THEN describe', () {
      expect(describeEnum(testEnum.firstEnumToChoose),
          equals('firstEnumToChoose'));
      expect(describeEnum(testEnum.secondEnum), equals('secondEnum'));
    });
    test('GIVEN string THEN describeEnum breaks', () {
      const String invalidEnumEntry = 'string';
      expect(() => describeEnum(invalidEnumEntry), throwsAssertionError);
    });

    test('GIVEN enum THEN return capitalized spaced string', () {
      expect(
          enumToSpacedString(testEnum.firstEnumToChoose, isCapitalized: true),
          'First enum to choose');
      expect(enumToSpacedString(testEnum.secondEnum, isCapitalized: true),
          'Second enum');
    });

    test('GIVEN enum THEN return spaced string', () {
      expect(
          enumToSpacedString(testEnum.firstEnumToChoose, isCapitalized: false),
          'first enum to choose');
      expect(enumToSpacedString(testEnum.secondEnum, isCapitalized: false),
          'second enum');
    });

    test('GIVEN string THEN enumToSpacedString breaks', () {
      const String invalidEnumEntry = 'string';
      expect(() => enumToSpacedString(invalidEnumEntry), throwsAssertionError);
    });
  });
}
