import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';

const String _kEventType = 'feedCountriesChanged';
const String _kParamSelectedCountries = 'selectedCountries';
const String _kParamCountryName = 'country';
const String _kParamLangCode = 'langCode';
const String _kParamCountryCode = 'countryCode';

class FeedCountriesChangedEvent extends AnalyticsEvent {
  FeedCountriesChangedEvent({
    required Set<Country> countries,
  }) : super(
          _kEventType,
          properties: {
            _kParamSelectedCountries: countries.map((it) => {
                  _kParamCountryName: it.name,
                  _kParamLangCode: it.langCode,
                  _kParamCountryCode: it.countryCode,
                }),
          },
        );
}
