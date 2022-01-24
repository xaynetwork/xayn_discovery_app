import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_supported_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_selected_countries_use_case.dart';

import 'feed_settings_state.dart';

abstract class FeedSettingsNavActions {
  void onBackNavPressed();
}

const maxSelectedCountryAmount = 3;

@injectable
class FeedSettingsManager extends Cubit<FeedSettingsState>
    with UseCaseBlocHelper
    implements FeedSettingsNavActions {
  final GetSupportedCountriesUseCase _getSupportedCountriesUseCase;
  final GetSelectedCountriesUseCase _getSelectedCountriesUseCase;
  final SaveSelectedCountriesUseCase _saveSelectedFeedMarketsUseCase;
  final FeedSettingsNavActions _navActions;

  FeedSettingsManager(
    this._navActions,
    this._getSupportedCountriesUseCase,
    this._getSelectedCountriesUseCase,
    this._saveSelectedFeedMarketsUseCase,
  ) : super(const FeedSettingsState.initial());

  final _allCountries = <Country>{};
  final _selectedCountries = <Country>{};

  Future<void> init() async {
    final countries = await _getSupportedCountriesUseCase.singleOutput(none);
    _allCountries.addAll(countries);
    final selectedMarkets =
        await _getSelectedCountriesUseCase.singleOutput(_allCountries);

    scheduleComputeState(() => _selectedCountries.addAll(selectedMarkets));
  }

  /// return [true], if [country] was added successfully
  Future<bool> onAddCountryPressed(Country country) async {
    if (_selectedCountries.length == maxSelectedCountryAmount) {
      return false;
    }
    _selectedCountries.add(country);
    await _saveSelectedFeedMarketsUseCase.singleOutput(_selectedCountries);
    scheduleComputeState(() {});
    return true;
  }

  /// return [true], if [country] was removed successfully
  Future<bool> onRemoveCountryPressed(Country country) async {
    if (_selectedCountries.length == 1) {
      return false;
    }
    _selectedCountries.remove(country);
    await _saveSelectedFeedMarketsUseCase.singleOutput(_selectedCountries);
    scheduleComputeState(() {});
    return true;
  }

  @override
  Future<FeedSettingsState> computeState() async {
    if (_allCountries.isEmpty) {
      return const FeedSettingsState.initial();
    }
    final unSelectedCountries = List<Country>.from(_allCountries);
    unSelectedCountries
        .removeWhere((country) => _selectedCountries.contains(country));
    return FeedSettingsState.ready(
      maxSelectedCountryAmount: maxSelectedCountryAmount,
      selectedCountries: _selectedCountries.toList(),
      unSelectedCountries: unSelectedCountries,
    );
  }

  @override
  void onBackNavPressed() => _navActions.onBackNavPressed();
}
