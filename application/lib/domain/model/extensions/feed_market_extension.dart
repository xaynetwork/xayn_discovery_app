import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart'
    as local;
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart' as engine;

extension FeedMarketExtension on engine.FeedMarket {
  local.FeedMarket toLocal() => local.FeedMarket(
        countryCode: countryCode,
        languageCode: langCode,
      );
}
