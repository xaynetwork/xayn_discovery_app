import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import 'feed_settings_state.dart';

abstract class FeedSettingsNavActions {
  void onBackNavPressed();
}

const maxSelectedCountryAmount = 3;

@injectable
class FeedSettingsManager extends Cubit<FeedSettingsState>
    with UseCaseBlocHelper
    implements FeedSettingsNavActions {
  final FeedSettingsNavActions _navActions;

  FeedSettingsManager(
    this._navActions,
  ) : super(const FeedSettingsState.initial());

  final _allCountries = <Country>{};
  final _selectedCountries = <Country>{};

  void init() {
    _allCountries.addAll([
      Country(
        name: 'USA',
        countryCode: 'US',
        svgFlagAssetPath: R.assets.illustrations.flagUSA,
        langCode: 'en',
      ),
      Country(
        name: 'Germany',
        countryCode: 'DE',
        svgFlagAssetPath: R.assets.illustrations.flagGermany,
        langCode: 'de',
      ),
      Country(
        name: 'Austria',
        countryCode: 'AU',
        svgFlagAssetPath: R.assets.illustrations.flagAustria,
        langCode: 'de',
      ),
      Country(
        name: 'France',
        countryCode: 'FR',
        svgFlagAssetPath: R.assets.illustrations.flagFrance,
        langCode: 'fr',
      ),
      Country(
        name: 'Belgium',
        countryCode: 'BE',
        svgFlagAssetPath: R.assets.illustrations.flagBelgium,
        langCode: 'fr',
        language: 'French',
      ),
      Country(
        name: 'Belgium',
        countryCode: 'BE',
        svgFlagAssetPath: R.assets.illustrations.flagBelgium,
        langCode: 'nl',
        language: 'Dutch',
      ),
      Country(
        name: 'Spain',
        countryCode: 'SP',
        svgFlagAssetPath: R.assets.illustrations.flagSpain,
        langCode: 'SP',
      ),
    ]);
    scheduleComputeState(() => _selectedCountries.add(_allCountries.first));
  }

  void onAddCountryPressed(Country country) {
    if (_selectedCountries.length == maxSelectedCountryAmount) {
      // todo add error here
      return;
    }
    scheduleComputeState(() => _selectedCountries.add(country));
  }

  void onRemoveCountryPressed(Country country) {
    if (_selectedCountries.length == 1) {
      // todo add error here
      return;
    }
    scheduleComputeState(() => _selectedCountries.remove(country));
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
