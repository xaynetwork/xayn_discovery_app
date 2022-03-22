import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_type_markets/save_feed_type_markets_use_case.dart';

@injectable
class SaveInitialFeedMarketUseCase
    extends UseCase<SaveDefaultFeedMarketInput, None> {
  final FeedSettingsRepository _repository;
  final SaveFeedTypeMarketsUseCase _saveFeedTypeMarketsUseCase;
  SaveInitialFeedMarketUseCase(
    this._repository,
    this._saveFeedTypeMarketsUseCase,
  );

  @override
  Stream<None> transaction(SaveDefaultFeedMarketInput param) async* {
    final settings = _repository.settings;
    if (settings.feedMarkets.isEmpty) {
      final market = _getMarket(param);
      final updatedSettings = settings.copyWith(feedMarkets: {market});
      _repository.save(updatedSettings);
      // also save local-screen markets in this case
      _saveFeedTypeMarketsUseCase(FeedTypeMarkets.forFeed({market}));
      _saveFeedTypeMarketsUseCase(FeedTypeMarkets.forSearch({market}));
    }
    yield none;
  }

  FeedMarket _getMarket(SaveDefaultFeedMarketInput param) {
    final deviceCountryCode = param.deviceLocale.countryCode;
    if (deviceCountryCode == null) return param.defaultMarket;

    return param.supportedMarkets.firstWhere(
      (code) =>
          code.countryCode.toLowerCase() == deviceCountryCode.toLowerCase(),
      orElse: () => param.defaultMarket,
    );
  }
}

class SaveDefaultFeedMarketInput {
  final Locale deviceLocale;
  final FeedMarket defaultMarket;
  final FeedMarkets supportedMarkets;

  SaveDefaultFeedMarketInput(
    this.deviceLocale,
    this.defaultMarket,
    this.supportedMarkets,
  ) : assert(supportedMarkets.isNotEmpty);
}
