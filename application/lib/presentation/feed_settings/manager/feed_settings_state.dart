import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';

part 'feed_settings_state.freezed.dart';

@freezed
class FeedSettingsState with _$FeedSettingsState {
  const factory FeedSettingsState.initial() = _Initial;

  const factory FeedSettingsState.ready({
    required int maxSelectedCountryAmount,
    required List<Country> selectedCountries,
    required List<Country> unSelectedCountries,
    @Default(ErrorObject()) ErrorObject error,
  }) = FeedSettingsStateReady;
}
