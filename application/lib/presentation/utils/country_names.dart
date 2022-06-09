import 'package:flutter_localized_countries/flutter_localized_countries.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';

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
