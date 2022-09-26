import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_supported_countries_use_case.dart';

@injectable
class GetSelectedCountriesListUseCase extends UseCase<None, Set<Country>> {
  final GetSupportedCountriesUseCase _getSupportedCountriesUseCase;
  final GetSelectedCountriesUseCase _getSelectedCountriesUseCase;

  GetSelectedCountriesListUseCase(
    this._getSupportedCountriesUseCase,
    this._getSelectedCountriesUseCase,
  );

  @override
  Stream<Set<Country>> transaction(None param) async* {
    final supportedCountries =
        await _getSupportedCountriesUseCase.singleOutput(none);
    final selectedCountries = await _getSelectedCountriesUseCase
        .singleOutput(supportedCountries.toSet());
    yield selectedCountries;
  }
}
