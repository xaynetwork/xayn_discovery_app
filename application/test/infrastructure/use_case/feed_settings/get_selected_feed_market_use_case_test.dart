import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';

import '../../../presentation/test_utils/utils.dart';

void main() {
  late GetSelectedFeedMarketsUseCase useCase;
  late MockFeedSettingsRepository repository;

  const uaMarket = FeedMarket(countryCode: 'UA', languageCode: 'uk');
  const usaMarket = FeedMarket(countryCode: 'US', languageCode: 'en');
  late final markets = {uaMarket, usaMarket};

  setUp(() {
    repository = MockFeedSettingsRepository();
    useCase = GetSelectedFeedMarketsUseCase(repository);

    when(repository.settings).thenReturn(FeedSettings(feedMarkets: markets));
  });

  test(
    'GIVEN feedSettings with empty feed markets WHEN get settings THEN return set of markets',
    () async {
      when(repository.settings).thenReturn(FeedSettings(feedMarkets: {}));
      final output = await useCase.singleOutput(none);

      expect(output, isEmpty);
    },
  );

  test(
    'GIVEN feedSettings with non empty feed markets WHEN get settings THEN return set of markets',
    () async {
      final output = await useCase.singleOutput(none);

      expect(output, equals(markets));
    },
  );
}
