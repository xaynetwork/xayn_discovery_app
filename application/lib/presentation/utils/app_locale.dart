import 'package:flutter/material.dart';
import 'package:intl/locale.dart' as intl;
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';

/// The intl.locale so that we don't need to import it always as intl
typedef AppLocale = intl.Locale;

late final _listOfCountryCodes =
    supportedMarkets.map((e) => e.locale.countryCode).toList(growable: false);
late final needToShowLanguageCode = Map.fromEntries(supportedMarkets.map((e) =>
    MapEntry(
        e.locale.countryCode,
        _listOfCountryCodes
                .where((element) => e.locale.countryCode == element)
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
