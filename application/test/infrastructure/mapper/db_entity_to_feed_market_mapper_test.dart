import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';

abstract class _Fields {
  _Fields._();

  static const int countryCode = 0;
  static const int languageCode = 1;
}

const langCodeUA = 'uk';
const countryCodeUA = 'UA';
const uaMarket = FeedMarket(
  countryCode: countryCodeUA,
  languageCode: langCodeUA,
);

void main() {
  final fromMapMapper = DbEntityMapToFeedMarketMapper();
  final toMapMapper = FeedMarketToDbEntityMapMapper();

  late Map<int, String> uaMap;

  setUp(() {
    uaMap = {
      _Fields.languageCode: langCodeUA,
      _Fields.countryCode: countryCodeUA,
    };
  });

  group('from map', () {
    test(
      'GIVEN nullable map THEN return null',
      () {
        expect(
          fromMapMapper.map(null),
          isNull,
        );
      },
    );
    test(
      'GIVEN map without country code THEN return null',
      () {
        expect(
          fromMapMapper.map(uaMap..remove(_Fields.countryCode)),
          isNull,
        );
      },
    );
    test(
      'GIVEN map without language code THEN return null',
      () {
        expect(
          fromMapMapper.map(uaMap..remove(_Fields.languageCode)),
          isNull,
        );
      },
    );
    test(
      'GIVEN map with language and country codes THEN return FeedMarket',
      () {
        final map = {
          _Fields.countryCode: countryCodeUA,
          _Fields.languageCode: langCodeUA,
        };
        expect(fromMapMapper.map(map), equals(uaMarket));
      },
    );
  });
  group('toMap', () {
    test(
      'GIVEN market THEN return map with language and country codes',
      () {
        expect(toMapMapper.map(uaMarket), equals(uaMap));
      },
    );
  });
}
