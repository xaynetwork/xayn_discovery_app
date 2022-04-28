import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/feed_countries_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_supported_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';

import 'country_feed_settings_state.dart';

const maxSelectedCountryAmount = 3;

@injectable
class CountryFeedSettingsManager extends Cubit<CountryFeedSettingsState>
    with UseCaseBlocHelper, OverlayManagerMixin<CountryFeedSettingsState> {
  final GetSupportedCountriesUseCase _getSupportedCountriesUseCase;
  final GetSelectedCountriesUseCase _getSelectedCountriesUseCase;
  final SaveSelectedCountriesUseCase _saveSelectedFeedMarketsUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;

  CountryFeedSettingsManager(
    this._getSupportedCountriesUseCase,
    this._getSelectedCountriesUseCase,
    this._saveSelectedFeedMarketsUseCase,
    this._sendAnalyticsUseCase,
  ) : super(const CountryFeedSettingsState.initial());

  final _allCountries = <Country>{};
  final _selectedCountries = <Country>{};

  Future<void> init() async {
    final countries = await _getSupportedCountriesUseCase.singleOutput(none);
    _allCountries.addAll(countries);
    final selectedMarkets =
        await _getSelectedCountriesUseCase.singleOutput(_allCountries);

    scheduleComputeState(() => _selectedCountries.addAll(selectedMarkets));
  }

  Future<void> onAddCountryPressed(Country country) async {
    if (_selectedCountries.length == maxSelectedCountryAmount) {
      return showOverlay(OverlayData.tooltipErrorMaxSelectedCountries(
          maxSelectedCountryAmount));
    }
    _selectedCountries.add(country);
    await _saveSelectedFeedMarketsUseCase.singleOutput({..._selectedCountries});
    _sendAnalyticsUseCase(
      FeedCountriesChangedEvent(countries: {..._selectedCountries}),
    );
    scheduleComputeState(() {});
  }

  Future<void> onRemoveCountryPressed(Country country) async {
    if (_selectedCountries.length == 1) {
      return showOverlay(OverlayData.tooltipErrorMinSelectedCountries());
    }
    _selectedCountries.remove(country);
    await _saveSelectedFeedMarketsUseCase.singleOutput({..._selectedCountries});
    _sendAnalyticsUseCase(
      FeedCountriesChangedEvent(countries: {..._selectedCountries}),
    );
    scheduleComputeState(() {});
  }

  @override
  Future<CountryFeedSettingsState> computeState() async {
    if (_allCountries.isEmpty) {
      return const CountryFeedSettingsState.initial();
    }
    final unSelectedCountries = List<Country>.from(_allCountries);
    unSelectedCountries
        .removeWhere((country) => _selectedCountries.contains(country));
    return CountryFeedSettingsState.ready(
      maxSelectedCountryAmount: maxSelectedCountryAmount,
      selectedCountries: _selectedCountries.toList(),
      unSelectedCountries: unSelectedCountries,
    );
  }
}
