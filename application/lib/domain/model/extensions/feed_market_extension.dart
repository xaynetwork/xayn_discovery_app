import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart'
    as local;
import 'package:xayn_discovery_app/domain/model/legacy/feed_market.dart'
    as engine;

extension FeedMarketExtension on engine.FeedMarket {
  local.InternalFeedMarket toLocal() => local.InternalFeedMarket(
        countryCode: countryCode,
        languageCode: langCode,
      );
}
