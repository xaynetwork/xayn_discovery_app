import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_selected_countries_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late SaveSelectedCountriesUseCase useCase;
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
    useCase = SaveSelectedCountriesUseCase(repository);

    when(repository.settings).thenReturn(FeedSettings.initial());
  });

  test(
    'GIVEN empty set of countries THEN throw assert error',
    () async {
      final result = await useCase.call({});
      dynamic error;
      result.first.fold(
        defaultOnError: (e, __) => error = e,
        onValue: (_) {},
      );
      expect(error, isA<AssertionError>());
    },
  );

  test(
    'GIVEN NON empty set of countries THEN verify calls of mocked objects is correct',
    () async {
      await useCase.singleOutput(countries);
      verifyInOrder([
        repository.settings,
        repository.save(any),
      ]);

      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'GIVEN NON empty set of countries THEN verify correct markets saved locally',
    () async {
      await useCase.singleOutput(countries);
      verify(
        repository.save(FeedSettings.initial().copyWith(feedMarkets: markets)),
      );
    },
  );
}
