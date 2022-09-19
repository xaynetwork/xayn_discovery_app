import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/can_display_push_notifications_card_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/survey_banner/can_display_survey_banner_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/user_interactions_events.dart';

import '../../../domain/model/user_interactions/user_interactions.dart';

@injectable
class SaveUserInteractionUseCase extends UseCase<UserInteractionsEvents, None> {
  final UserInteractionsRepository _userInteractionsRepository;
  final CanDisplaySurveyBannerUseCase _canDisplaySurveyBannerUseCase;
  final CanDisplayPushNotificationsCardUseCase
      _canDisplayPushNotificationsCardUseCase;
  late UserInteractions _userInteractions;

  SaveUserInteractionUseCase(
    this._userInteractionsRepository,
    this._canDisplaySurveyBannerUseCase,
    this._canDisplayPushNotificationsCardUseCase,
  );

  @override
  Stream<None> transaction(UserInteractionsEvents param) async* {
    final canDisplaySurveyBanner =
        await _canDisplaySurveyBannerUseCase.singleOutput(none);
    final canDisplayPushNotificationsCard =
        await _canDisplayPushNotificationsCardUseCase.singleOutput(none);

    if (canDisplaySurveyBanner ||
        (canDisplayPushNotificationsCard &&
            param == UserInteractionsEvents.cardScrolled)) {
      _userInteractions = _userInteractionsRepository.userInteractions;
      switch (param) {
        case UserInteractionsEvents.cardScrolled:
          _onScrollingEvent();
          break;
        case UserInteractionsEvents.readArticle:
          _onReadArticleEvent();
          break;
        case UserInteractionsEvents.bookmarkedArticle:
          _onBookmarkedArticleEvent();
          break;
        case UserInteractionsEvents.likeOrDislikedArticle:
          _onLikeOrDislikedArticleEvent();
          break;
        case UserInteractionsEvents.excludedSource:
          _onExcludedSource();
          break;
        case UserInteractionsEvents.changedCountry:
          _onChangedCountryEvent();
          break;
        case UserInteractionsEvents.searchExecuted:
          _onSearchExecutedEvent();
          break;
      }
    }

    yield none;
  }

  void _onScrollingEvent() {
    final updatedNumberOfScrolls = _userInteractions.numberOfScrolls + 1;
    final updatedNumberOfScrollsPerSession =
        _userInteractions.numberOfScrollsPerSession + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
      numberOfScrolls: updatedNumberOfScrolls,
      numberOfScrollsPerSession: updatedNumberOfScrollsPerSession,
    );
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onReadArticleEvent() {
    final updatedNumberOfArticlesRead =
        _userInteractions.numberOfArticlesRead + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfArticlesRead: updatedNumberOfArticlesRead);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onBookmarkedArticleEvent() {
    final updatedNumberOfArticlesBookmarked =
        _userInteractions.numberOfArticlesBookmarked + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfArticlesBookmarked: updatedNumberOfArticlesBookmarked);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onLikeOrDislikedArticleEvent() {
    final updatedNumberOfArticlesLikedOrDisliked =
        _userInteractions.numberOfArticlesLikedOrDisliked + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfArticlesLikedOrDisliked:
            updatedNumberOfArticlesLikedOrDisliked);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onExcludedSource() {
    final updatedNumberOfSourcesExcluded =
        _userInteractions.numberOfSourcesExcluded + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfSourcesExcluded: updatedNumberOfSourcesExcluded);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onChangedCountryEvent() {
    final updatedNumberOfCountriesChanged =
        _userInteractions.numberOfCountriesChanged + 1;
    final updatedUserInteractions = _userInteractions.copyWith(
        numberOfCountriesChanged: updatedNumberOfCountriesChanged);
    _userInteractionsRepository.save(updatedUserInteractions);
  }

  void _onSearchExecutedEvent() {
    final updatedNumberOfSearches = _userInteractions.numberOfSearches + 1;
    final updatedUserInteractions =
        _userInteractions.copyWith(numberOfSearches: updatedNumberOfSearches);
    _userInteractionsRepository.save(updatedUserInteractions);
  }
}
