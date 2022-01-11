import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/locale.dart' as intl;
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

final _listOfCountryCodes =
    supportedMarkets.map((e) => e.locale.countryCode).toList(growable: false);
final _needToShowLanguageCode = Map.fromEntries(supportedMarkets.map((e) =>
    MapEntry(
        e.locale.countryCode,
        _listOfCountryCodes
                .where((element) => e.locale.countryCode == element)
                .length >
            1)));

intl.Locale? convertLanguageTagToLocale(String? languageTag) {
  return languageTag != null ? intl.Locale.tryParse(languageTag) : null;
}

String countryNameForLanguageTag(
  BuildContext context,
  intl.Locale locale,
  CountryNames countryNames,
) {
  final showLanguageCode = _needToShowLanguageCode[locale.countryCode] == true;
  final countryCode = locale.countryCode;
  String resolvedCountryName;

  if (countryCode == null) {
    // fallback value
    resolvedCountryName = locale.toLanguageTag();
  } else {
    final maybeCountryName = countryNames[countryCode];
    resolvedCountryName = maybeCountryName ?? locale.toLanguageTag();
  }

  return showLanguageCode
      ? '$resolvedCountryName ( ${locale.languageCode} )'
      : resolvedCountryName;
}

intl.Locale getFallbackLocale(intl.Locale locale) {
  return supportedMarkets
      .firstWhere(
        (market) => market.locale.countryCode == locale.countryCode,
        orElse: () => supportedMarkets.firstWhere(
          (market) => market.locale.languageCode == locale.languageCode,
          orElse: () => DiscoveryEngineMarket(createLocale('en', 'US')),
        ),
      )
      .locale;
}

intl.Locale getSupportedLocale(intl.Locale locale) {
  return supportedMarkets
              .firstWhereOrNull((market) => market.locale == locale) !=
          null
      ? locale
      : getFallbackLocale(locale);
}

intl.Locale createLocale(String languageCode, String countryCode) =>
    intl.Locale.fromSubtags(
        languageCode: languageCode, countryCode: countryCode);

extension LocaleExtension on Locale {
  intl.Locale toIntlLocale() => intl.Locale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
      scriptCode: scriptCode);
}
