import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';

import '../../presentation/test_utils/utils.dart';

void main() {
  const uaMap = {0: 'UA', 1: 'uk'};
  const usaMap = {0: 'US', 1: 'en'};
  const marketsMap = [uaMap, usaMap];

  const uaMarket = FeedMarket(countryCode: 'UA', languageCode: 'uk');
  const usaMarket = FeedMarket(countryCode: 'US', languageCode: 'en');
  late final markets = {uaMarket, usaMarket};
  late final feedSettings = FeedSettings(feedMarkets: markets);

  late FeedSettingsMapper mapper;
  late MockFeedMarketToDbEntityMapMapper marketToMapMapper;
  late MockDbEntityMapToFeedMarketMapper marketFromMapMapper;

  setUp(() {
    marketToMapMapper = MockFeedMarketToDbEntityMapMapper();
    marketFromMapMapper = MockDbEntityMapToFeedMarketMapper();
    mapper = FeedSettingsMapper(marketFromMapMapper, marketToMapMapper);

    when(marketToMapMapper.map(uaMarket)).thenReturn(uaMap);
    when(marketToMapMapper.map(usaMarket)).thenReturn(usaMap);

    when(marketFromMapMapper.map(uaMap)).thenReturn(uaMarket);
    when(marketFromMapMapper.map(usaMap)).thenReturn(usaMarket);
  });

  group('fromMap', () {
    test(
      'GIVEN null THEN return null',
      () {
        expect(mapper.fromMap(null), isNull);
      },
    );
    test(
      'GIVEN map without markets THEN return null',
      () {
        expect(mapper.fromMap({}), isNull);
      },
    );
    test(
      'GIVEN map with markets THEN return correct feedSettings',
      () {
        expect(
          mapper.fromMap({0: marketsMap}),
          equals(feedSettings),
        );
      },
    );
  });

  group('toMap', () {
    test(
      'GIVEN feedSettings THEN return correct map',
      () {
        expect(mapper.toMap(feedSettings), {0: marketsMap});
      },
    );
  });
}
