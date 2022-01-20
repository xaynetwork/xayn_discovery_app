import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/language_code_to_language_name_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';

void main() {
  final mapper = LanguageCodeToLanguageNameMapper();
  test(
    'GIVEN language code WHEN mapping them to language name THEN return correct values',
    () {
      final expected = [
        'Dutch',
        'English',
        'French',
        'German',
        'Polish',
        'Spanish',
      ];

      final languages = SupportedLanguageCodes.allValues.toList();
      for (int i = 0; i < languages.length; i++) {
        final result = mapper.map(languages[i]);
        expect(expected[i], result, reason: 'Index: $i');
      }
    },
  );
}
