import 'package:intl/locale.dart' as intl;
import 'package:test/test.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';
import 'package:xayn_discovery_app/presentation/utils/locale.dart';

void main() {
  test(
      'Given a Locale with an existing language code and an existing country code, expect to return the correct app language',
      () {
    final result = AppLanguageHelper.from(locale: createLocale('de', 'DE'));
    expect(result, AppLanguage.german);
  });

  test(
      'Given a Locale with an existing language code and unknown country code, expect to return the correct app language',
      () {
    final result = AppLanguageHelper.from(locale: createLocale('de', 'XX'));
    expect(result, AppLanguage.german);
  });

  test(
      'Given a Locale with an existing language code and a null country code, expect to return the correct app language',
      () {
    final result = AppLanguageHelper.from(
        locale: intl.Locale.fromSubtags(languageCode: 'de'));
    expect(result, AppLanguage.german);
  });

  test(
      'Given a Locale with an unknown language code and an existing country code, expect to return english as app language',
      () {
    final result = AppLanguageHelper.from(locale: createLocale('xx', 'DE'));
    expect(result, AppLanguage.english);
  });

  test(
      'Given a Locale with unknown language code and unknown country code, expect to return english as app language',
      () {
    final result = AppLanguageHelper.from(locale: createLocale('xx', 'YY'));
    expect(result, AppLanguage.english);
  });
}
