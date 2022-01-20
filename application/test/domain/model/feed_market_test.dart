import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';

void main() {
  test(
    'GIVEN 2 instances of FeedMarket with same country and language WHEN compare them THEN return true',
    () {
      const first = FeedMarket(countryCode: 'UA', languageCode: 'uk');
      const second = FeedMarket(countryCode: 'UA', languageCode: 'uk');

      final result = first == second;
      expect(result, isTrue);
    },
  );
  test(
    'GIVEN instance of FeedMarket THEN check its equatable',
    () {
      const market = FeedMarket(countryCode: 'UA', languageCode: 'uk');

      expect(market, isA<Equatable>());
    },
  );
  test(
    'GIVEN instance of FeedMarket THEN check props is correct',
    () {
      const market = FeedMarket(countryCode: 'UA', languageCode: 'uk');

      expect(
        market.props,
        [market.countryCode, market.languageCode],
      );
    },
  );
}
