import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/feed_market/feed_market.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/save_user_interaction_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/user_interactions_events.dart';

@injectable
class SaveSelectedCountriesUseCase extends UseCase<Set<Country>, None> {
  final FeedSettingsRepository _repository;
  final SaveUserInteractionUseCase _saveUserInteractionUseCase;

  SaveSelectedCountriesUseCase(
    this._repository,
    this._saveUserInteractionUseCase,
  );

  @override
  Stream<None> transaction(Set<Country> param) async* {
    if (param.isEmpty) {
      throw AssertionError('param should not be empty');
    }

    final localMarkets = param.map(
      (e) => FeedMarket(countryCode: e.countryCode, languageCode: e.langCode),
    );

    // update local storage with markets below
    final settings = _repository.settings;
    final updatedSettings =
        settings.copyWith(feedMarkets: localMarkets.toSet());
    _repository.save(updatedSettings);
    _saveUserInteractionUseCase
        .singleOutput(UserInteractionsEvents.changedCountry);

    yield none;
  }
}
