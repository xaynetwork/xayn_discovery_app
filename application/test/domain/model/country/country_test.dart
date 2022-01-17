import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';

void main() {
  const name = 'USA';
  const flagPath = 'packages/xayn_design/assets/illustrations/flag_usa.svg';
  const countryCode = 'USA';
  const langCode = 'en';
  const language = 'English';

  Country create({String? language, Key? key}) => Country(
        name: name,
        svgFlagAssetPath: flagPath,
        countryCode: countryCode,
        langCode: langCode,
        language: language,
        key: key,
      );

  test(
    'GIVEN nullable language WHEN create Country THEN verify all params is correct',
    () {
      // ARRANGE
      final country = create(language: null);

      // ASSERT
      expect(country.name, equals(name));
      expect(country.svgFlagAssetPath, equals(flagPath));
      expect(country.countryCode, equals(countryCode));
      expect(country.langCode, equals(langCode));
      expect(country.language, isNull);
    },
  );

  test(
    'GIVEN non-nullable language WHEN create Country THEN verify all params is correct',
    () {
      // ARRANGE
      final country = create(language: language);

      // ASSERT
      expect(country.name, equals(name));
      expect(country.svgFlagAssetPath, equals(flagPath));
      expect(country.countryCode, equals(countryCode));
      expect(country.langCode, equals(langCode));
      expect(country.language, equals(language));
    },
  );

  test(
    'GIVEN Country object THEN verify it is Equatable',
    () {
      // ARRANGE
      final country = create(language: language);

      // ASSERT
      expect(country, isA<Equatable>());
      expect(country.props, [
        name,
        language,
        flagPath,
        countryCode,
        langCode,
      ]);
    },
  );

  test(
    'WHEN create country with key THEN verify the key is correct',
    () async {
      // ARRANGE
      const expected = ValueKey('My custom key');
      final country = create(key: expected);

      // ACT

      // ASSERT
      expect(country.key, equals(expected));
    },
  );
}
