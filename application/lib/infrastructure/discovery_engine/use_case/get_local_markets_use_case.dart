import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_feed_market_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class GetLocalMarketsUseCase extends UseCase<None, Set<FeedMarket>> {
  final GetSelectedFeedMarketsUseCase _getSelectedFeedMarketsUseCase;

  GetLocalMarketsUseCase(this._getSelectedFeedMarketsUseCase);

  @override
  Stream<Set<FeedMarket>> transaction(None param) async* {
    final localMarkets =
        await _getSelectedFeedMarketsUseCase.singleOutput(none);

    yield localMarkets
        .sortedBy((it) => '${it.countryCode}|${it.languageCode}')
        .map((e) =>
            FeedMarket(countryCode: e.countryCode, langCode: e.languageCode))
        .toSet();
  }
}
