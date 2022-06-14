import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

typedef SupportedCountries = Iterable<Country>;

@injectable
class GetSupportedCountriesUseCase extends UseCase<None, SupportedCountries> {
  GetSupportedCountriesUseCase();

  @override
  Stream<SupportedCountries> transaction(None param) async* {
    final countryNames = await Strings.countryNames;
    final countries = SupportedMarkets.values.map((SupportedMarkets market) {
      final countryName = countryNames[market.countryCode]!;

      final language = market.languageName;

      return Country(
        name: countryName,
        svgFlagAssetPath: market.flag,
        countryCode: market.countryCode,
        langCode: market.languageCode,
        language: language,
      );
    }).toList();

    countries.sort((a, b) => a.name.compareTo(b.name));

    yield countries;
  }
}
