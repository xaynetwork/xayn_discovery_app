import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/save_initial_feed_market_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/save_feed_type_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';

import '../../../test_utils/utils.dart';

void main() {
  late SaveInitialFeedMarketUseCase useCase;
  late MockFeedSettingsRepository repository;
  late SaveFeedTypeMarketsUseCase feedTypeMarketsUseCase;
  late MockFeedTypeMarketsRepository feedTypeMarketsRepository;

  const nullableLocale = Locale.fromSubtags(
    languageCode: 'en',
    countryCode: null,
  );
  const nonNullableLocale = Locale.fromSubtags(
    languageCode: 'en',
    countryCode: 'DE',
  );
  final FeedMarket defaultMarket = supportedFeedMarkets.first;

  setUp(() {
    repository = MockFeedSettingsRepository();
    feedTypeMarketsRepository = MockFeedTypeMarketsRepository();
    feedTypeMarketsUseCase =
        SaveFeedTypeMarketsUseCase(feedTypeMarketsRepository);
    useCase = SaveInitialFeedMarketUseCase(
      repository,
      feedTypeMarketsUseCase,
    );
    when(repository.settings).thenReturn(FeedSettings(feedMarkets: {}));
    when(feedTypeMarketsRepository.save(any)).thenReturn(null);
  });

  FeedSettings getSettings([FeedMarket? market]) =>
      FeedSettings(feedMarkets: {market ?? defaultMarket});

  SaveDefaultFeedMarketInput getInput(Locale local) =>
      SaveDefaultFeedMarketInput(
        local,
        defaultMarket,
        supportedFeedMarkets,
      );

  test(
    'GIVEN settings with non empty markets WHEN getting settings THEN save() not called',
    () async {
      when(repository.settings).thenReturn(getSettings());

      final input = getInput(nullableLocale);
      final result = await useCase.singleOutput(input);

      expect(result, isA<None>());
      verify(repository.settings);
      verifyNever(feedTypeMarketsRepository.save(any));
      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(feedTypeMarketsRepository);
    },
  );

  test(
    'GIVEN locale with the nullable country_code WHEN getting settings THEN save() default market',
    () async {
      final input = getInput(nullableLocale);
      final result = await useCase.singleOutput(input);

      expect(result, isA<None>());
      verifyInOrder([
        repository.settings,
        repository.save(getSettings(defaultMarket)),
        feedTypeMarketsRepository
            .save(FeedTypeMarkets.forFeed({defaultMarket})),
        feedTypeMarketsRepository
            .save(FeedTypeMarkets.forSearch({defaultMarket})),
      ]);
      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(feedTypeMarketsRepository);
    },
  );

  test(
    'GIVEN locale with the NON-nullable country_code WHEN getting settings THEN save() market with the same country code',
    () async {
      const deviceLocale = nonNullableLocale;
      final expectedMarket = supportedFeedMarkets.firstWhere(
          (element) => element.countryCode == deviceLocale.countryCode);

      final input = getInput(deviceLocale);
      final result = await useCase.singleOutput(input);

      expect(result, isA<None>());
      verifyInOrder([
        repository.settings,
        repository.save(getSettings(expectedMarket)),
        feedTypeMarketsRepository
            .save(FeedTypeMarkets.forFeed({expectedMarket})),
        feedTypeMarketsRepository
            .save(FeedTypeMarkets.forSearch({expectedMarket})),
      ]);
      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(feedTypeMarketsRepository);
    },
  );
}
