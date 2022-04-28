import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';

part 'country_feed_settings_state.freezed.dart';

@freezed
class CountryFeedSettingsState with _$CountryFeedSettingsState {
  const factory CountryFeedSettingsState.initial() = _Initial;

  const factory CountryFeedSettingsState.ready({
    required int maxSelectedCountryAmount,
    required List<Country> selectedCountries,
    required List<Country> unSelectedCountries,
    @Default(ErrorObject()) ErrorObject error,
  }) = CountryFeedSettingsStateReady;
}
