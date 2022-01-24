import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_market_to_flag_path_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';

void main() {
  final mapper = FeedMarketToFlagAssetPathMapper();

  test(
    'GIVEN country code WHEN mapping them to flag path THEN return correct values',
    () {
      final expected = [
        'packages/xayn_design/assets/illustrations/flag_austria.svg',
        'packages/xayn_design/assets/illustrations/flag_belgium.svg',
        'packages/xayn_design/assets/illustrations/flag_belgium.svg',
        'packages/xayn_design/assets/illustrations/flag_canada.svg',
        'packages/xayn_design/assets/illustrations/flag_switzerland.svg',
        'packages/xayn_design/assets/illustrations/flag_germany.svg',
        'packages/xayn_design/assets/illustrations/flag_spain.svg',
        'packages/xayn_design/assets/illustrations/flag_uk.svg',
        'packages/xayn_design/assets/illustrations/flag_ireland.svg',
        'packages/xayn_design/assets/illustrations/flag_netherlands.svg',
        'packages/xayn_design/assets/illustrations/flag_poland.svg',
        'packages/xayn_design/assets/illustrations/flag_usa.svg',
      ];

      final markets = supportedFeedMarkets.toList();
      for (int i = 0; i < markets.length; i++) {
        final market = markets[i];
        final result = mapper.map(market);
        expect(expected[i], result, reason: 'Index: $i');
      }
    },
  );
}
