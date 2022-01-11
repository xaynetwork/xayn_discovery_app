import 'dart:ui';

import 'package:flutter_localized_countries/flutter_localized_countries.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

extension CountryNames on AppLanguage {
  GetCountryNamesCallback get countryNames => (AppLanguage appLanguage) async {
        final locale =
            Locale.fromSubtags(languageCode: appLanguage.languageCode);
        return (await const CountryNamesLocalizationsDelegate().load(locale))
            .data;
      };
}
