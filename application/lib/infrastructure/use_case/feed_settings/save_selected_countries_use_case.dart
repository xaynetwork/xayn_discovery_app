import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart' as engine;

@injectable
class SaveSelectedCountriesUseCase extends UseCase<Set<Country>, None> {
  final FeedSettingsRepository _repository;
  final engine.DiscoveryEngine _discoveryEngine;

  SaveSelectedCountriesUseCase(
    this._repository,
    this._discoveryEngine,
  );

  @override
  Stream<None> transaction(Set<Country> param) async* {
    if (param.isEmpty) {
      throw AssertionError('param should not be empty');
    }

    final localMarkets = param.map(
      (e) => FeedMarket(countryCode: e.countryCode, languageCode: e.langCode),
    );

    // update discovery engine values below
    final engineMarkets = localMarkets
        .map((e) => engine.FeedMarket(
            countryCode: e.countryCode, langCode: e.languageCode))
        .toSet();
    await _discoveryEngine.changeConfiguration(feedMarkets: engineMarkets);

    // update local storage with markets below
    final settings = _repository.settings;
    final updatedSettings =
        settings.copyWith(feedMarkets: localMarkets.toSet());
    _repository.save(updatedSettings);

    yield none;
  }
}
