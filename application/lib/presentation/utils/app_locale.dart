import 'package:flutter/material.dart';
import 'package:intl/locale.dart' as intl;
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';

/// The intl.locale so that we don't need to import it always as intl
typedef AppLocale = intl.Locale;

late final _listOfCountryCodes =
    supportedFeedMarkets.map((e) => e.countryCode).toList();
late final needToShowLanguageCode = Map.fromEntries(supportedFeedMarkets.map(
    (e) => MapEntry(
        e.countryCode,
        _listOfCountryCodes
                .where((element) => e.countryCode == element)
                .length >
            1)));

AppLocale createLocale(String languageCode, String countryCode) =>
    intl.Locale.fromSubtags(
        languageCode: languageCode, countryCode: countryCode);

extension LocaleExtension on Locale {
  AppLocale toAppLocale() => AppLocale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
      scriptCode: scriptCode);
}
