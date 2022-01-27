import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_use_case.dart';

import '../../../presentation/test_utils/utils.dart';

void main() {
  late GetSelectedCountriesUseCase useCase;
  late MockFeedSettingsRepository repository;

  const uaMarket = FeedMarket(countryCode: 'UA', languageCode: 'uk');
  const usMarket = FeedMarket(countryCode: 'US', languageCode: 'en');
  late final markets = {uaMarket, usMarket};

  const ukraine = Country(
    name: 'Ukraine',
    countryCode: 'UA',
    langCode: 'uk',
    svgFlagAssetPath: 'path',
  );
  const usa = Country(
    name: 'USA',
    countryCode: 'US',
    langCode: 'en',
    svgFlagAssetPath: 'path2',
  );
  late final countries = {ukraine, usa};

  setUp(() {
    repository = MockFeedSettingsRepository();
    useCase = GetSelectedCountriesUseCase(repository);

    when(repository.settings).thenReturn(FeedSettings(feedMarkets: markets));
  });

  test(
    'GIVEN feedSettings with empty feed markets THEN yield empty set',
    () async {
      when(repository.settings).thenReturn(FeedSettings(feedMarkets: {}));
      final output = await useCase.singleOutput(countries);

      expect(output, isEmpty);
    },
  );

  test(
    'GIVEN feedSettings with NON empty feed markets, but with empty allCountries set THEN yield empty set',
    () async {
      when(repository.settings).thenReturn(FeedSettings(feedMarkets: markets));
      final output = await useCase.singleOutput({});

      expect(output, isEmpty);
    },
  );

  test(
    'GIVEN feedSettings with NON empty feed markets and with NON empty allCountries set THEN yield correct set',
    () async {
      when(repository.settings).thenReturn(FeedSettings(feedMarkets: markets));
      final output = await useCase.singleOutput(countries);

      expect(output, equals(countries));
    },
  );

  test(
    'GIVEN feedSettings with NON empty feed markets and with NON empty allCountries set THEN yield correct set',
    () async {
      when(repository.settings)
          .thenReturn(FeedSettings(feedMarkets: {uaMarket}));
      final output = await useCase.singleOutput(countries);

      expect(output, equals({ukraine}));
    },
  );

  test(
    'GIVEN feedSettings with NON empty feed markets and with NON empty allCountries set THEN yield correct set',
    () async {
      when(repository.settings).thenReturn(FeedSettings(feedMarkets: markets));
      final output = await useCase.singleOutput({ukraine});

      expect(output, equals({ukraine}));
    },
  );
}
