import 'package:injectable/injectable.dart';
import 'package:collection/collection.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';

@injectable
class GetSelectedCountriesUseCase extends UseCase<Set<Country>, Set<Country>> {
  final FeedSettingsRepository _repository;

  GetSelectedCountriesUseCase(
    this._repository,
  );

  /// [param] represents a set of all supported countries
  /// As result it [yield] a Set of countries, has same country-language codes
  /// as [FeedMarkets] from the [FeedSettings]
  @override
  Stream<Set<Country>> transaction(Set<Country> param) async* {
    final settings = _repository.settings;

    yield _mapMarkets(settings.feedMarkets, param);
  }

  Set<Country> _mapMarkets(
    Set<FeedMarket> selectedMarkets,
    Set<Country> allCountries,
  ) {
    final selectedCountries = <Country>{};
    for (final market in selectedMarkets) {
      final country = allCountries.firstWhereOrNull(
        (country) =>
            country.countryCode == market.countryCode &&
            country.langCode == market.languageCode,
      );
      if (country != null) selectedCountries.add(country);
    }
    return selectedCountries;
  }
}
