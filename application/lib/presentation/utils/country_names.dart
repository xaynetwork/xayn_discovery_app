import 'package:flutter_localized_countries/flutter_localized_countries.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';
import 'package:xayn_discovery_app/presentation/utils/app_locale.dart';

/// Key is country code, value is localized country name.
typedef CountryNames = Map<String, String>;

typedef GetCountryNamesCallback = Future<CountryNames> Function(
    AppLanguage appLanguage);

Future<CountryNames> getCountryNames(AppLanguage appLanguage) async {
  // ignore: deprecated_member_use_from_same_package
  final locale = appLanguage.flutterLocale;
  final names = await const CountryNamesLocalizationsDelegate().load(locale);
  return names.data;
}

extension CountryNameExtension on CountryNames {
  String countryNameForLocale(
    AppLocale locale,
  ) {
    final showLanguageCode = isCountryMultilingual(locale.countryCode);
    final countryCode = locale.countryCode;
    String resolvedCountryName;

    if (countryCode == null) {
      // fallback value
      resolvedCountryName = locale.toLanguageTag();
    } else {
      final maybeCountryName = this[countryCode];
      resolvedCountryName = maybeCountryName ?? locale.toLanguageTag();
    }

    return showLanguageCode
        ? '$resolvedCountryName ( ${locale.languageCode} )'
        : resolvedCountryName;
  }
}
